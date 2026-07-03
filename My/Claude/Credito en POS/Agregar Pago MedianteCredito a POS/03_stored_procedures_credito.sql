-- ============================================================================
-- MODULO: CREDITO / FIADO EN POS
-- Fase: STORED PROCEDURES, FUNCIONES, TIPOS Y VISTA
-- Orden de ejecucion:
--   0) CREATE TYPE (2 tipos tabla, usados como parametro en varios SP)
--   1) VISTA vw_creditoCargosPendientes (antiguedad FIFO, la reutilizan 2 SP de lectura)
--   A) Configuracion (2 SP)
--   B) Cliente / limite (2 SP)
--   C) Nucleo transaccional (1 funcion + 4 SP)
--   D) Consulta / lectura (5 SP)
--   E) ALTER a SP existente (sp_in_movimentosInventarios) para reversa automatica
--
-- Convencion importante: en proc_movimientosCredito el campo [monto] SIEMPRE se
-- guarda en positivo (incluso para AJUSTE). La direccion (aumenta/disminuye el
-- saldo) se infiere comparando [saldoNuevo] contra [saldoAnterior], no del signo
-- de [monto]. Esto es lo que permite que vw_creditoCargosPendientes y los SP de
-- dashboard funcionen igual sin importar el tipo de movimiento.
--
-- Todos los SP transaccionales siguen el patron ya usado en el proyecto
-- (sp_ui_agendaReprogramacion): SET NOCOUNT ON, SET XACT_ABORT ON,
-- BEGIN TRY / BEGIN TRAN ... COMMIT, BEGIN CATCH / ROLLBACK + RAISERROR,
-- validaciones explicitas con RAISERROR antes de tocar datos, y
-- WITH (UPDLOCK, HOLDLOCK) al leer cat_personas / proc_movimientosCredito para
-- evitar condiciones de carrera (dos cajas cobrando al mismo cliente casi al
-- mismo tiempo).
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 0) TIPOS TABLA
-- ----------------------------------------------------------------------------
CREATE TYPE [dbo].[tvp_creditoCarritoItem] AS TABLE
(
	[idProductoServicio] [int] NOT NULL,
	[cantidad] [decimal](13, 4) NOT NULL,
	[precio] [decimal](18, 4) NOT NULL
)
GO

CREATE TYPE [dbo].[tvp_creditoPago] AS TABLE
(
	[idTipoPago] [int] NOT NULL,
	[montoPago] [decimal](18, 2) NOT NULL,
	[numeroAutorizacion] [varchar](250) NOT NULL
)
GO


-- ----------------------------------------------------------------------------
-- 1) VISTA: vw_creditoCargosPendientes
-- Antiguedad de cartera con regla FIFO confirmada: los Abonos/Liquidaciones
-- pagan primero los Cargos mas antiguos. Un Cargo ya revertido (REVERSA_CARGO
-- con folioMovimientoCreditoOrigen apuntandole) sale del calculo por completo.
-- Simplificacion conocida: los AJUSTE no se incorporan al "pool" de pagos de
-- este waterfall (no estan atados a un Cargo especifico); si en el futuro se
-- necesita que un Ajuste negativo tambien libere antiguedad, se agrega aqui.
-- ----------------------------------------------------------------------------
CREATE VIEW [dbo].[vw_creditoCargosPendientes]
AS
WITH CargosActivos AS
(
	SELECT
		mc.[folioMovimientoCredito],
		mc.[idPersona],
		mc.[idEntidad],
		mc.[idSucursal],
		mc.[monto],
		mc.[fechaVencimiento],
		mc.[fechaAlta]
	FROM [dbo].[proc_movimientosCredito] mc
	INNER JOIN [dbo].[cat_tipoMovimientoCredito] tm
		ON tm.[id] = mc.[idTipoMovimientoCredito] AND tm.[idEntidad] = mc.[idEntidad]
	WHERE tm.[clave] = 'CARGO'
	  AND NOT EXISTS
	  (
			SELECT 1
			FROM [dbo].[proc_movimientosCredito] r
			INNER JOIN [dbo].[cat_tipoMovimientoCredito] tmr
				ON tmr.[id] = r.[idTipoMovimientoCredito] AND tmr.[idEntidad] = r.[idEntidad]
			WHERE tmr.[clave] = 'REVERSA_CARGO'
			  AND r.[folioMovimientoCreditoOrigen] = mc.[folioMovimientoCredito]
			  AND r.[idEntidad] = mc.[idEntidad]
	  )
),
PagosPorCliente AS
(
	SELECT
		mc.[idPersona],
		mc.[idEntidad],
		SUM(mc.[monto]) AS [totalPagos]
	FROM [dbo].[proc_movimientosCredito] mc
	INNER JOIN [dbo].[cat_tipoMovimientoCredito] tm
		ON tm.[id] = mc.[idTipoMovimientoCredito] AND tm.[idEntidad] = mc.[idEntidad]
	WHERE tm.[clave] IN ('ABONO','LIQUIDACION')
	GROUP BY mc.[idPersona], mc.[idEntidad]
),
CargosConAcumulado AS
(
	SELECT
		ca.[folioMovimientoCredito],
		ca.[idPersona],
		ca.[idEntidad],
		ca.[idSucursal],
		ca.[monto],
		ca.[fechaVencimiento],
		ca.[fechaAlta],
		SUM(ca.[monto]) OVER
		(
			PARTITION BY ca.[idPersona], ca.[idEntidad]
			ORDER BY ca.[fechaAlta] ASC, ca.[folioMovimientoCredito] ASC
			ROWS UNBOUNDED PRECEDING
		) AS [acumuladoHasta],
		ISNULL(p.[totalPagos], 0) AS [totalPagosCliente]
	FROM CargosActivos ca
	LEFT JOIN PagosPorCliente p
		ON p.[idPersona] = ca.[idPersona] AND p.[idEntidad] = ca.[idEntidad]
)
SELECT
	[folioMovimientoCredito],
	[idPersona],
	[idEntidad],
	[idSucursal],
	[monto],
	[fechaVencimiento],
	[fechaAlta],
	CASE
		WHEN [totalPagosCliente] >= [acumuladoHasta] THEN CAST(0 AS decimal(18,2))
		WHEN [totalPagosCliente] <= ([acumuladoHasta] - [monto]) THEN [monto]
		ELSE [acumuladoHasta] - [totalPagosCliente]
	END AS [montoPendiente]
FROM CargosConAcumulado
GO


-- ============================================================================
-- A) CONFIGURACION
-- ============================================================================

CREATE PROCEDURE [dbo].[sp_ui_creditoConfiguracionGet]
(
	@idEntidad int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		[id], [tipoValorRecargo], [nivelAplicacion], [valorRecargo], [diasVencimientoCargo],
		[limiteCreditoDefaultExpress], [vigenteDesde], [vigenteHasta], [comentarios], [activo], [idEntidad]
	FROM [dbo].[cat_configuracionCredito]
	WHERE [idEntidad] = @idEntidad
	  AND [vigenteHasta] IS NULL;
END
GO

CREATE PROCEDURE [dbo].[sp_ui_creditoConfiguracionGuardar]
(
	@idEntidad int,
	@tipoValorRecargo varchar(20),
	@nivelAplicacion varchar(20),
	@valorRecargo decimal(18,4),
	@diasVencimientoCargo int,
	@limiteCreditoDefaultExpress decimal(18,2),
	@idUsuarioAlta int
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRY
		IF @tipoValorRecargo NOT IN ('Fijo','Porcentaje')
			RAISERROR('tipoValorRecargo invalido. Use Fijo o Porcentaje.',16,1);

		IF @nivelAplicacion NOT IN ('Producto','Carrito')
			RAISERROR('nivelAplicacion invalido. Use Producto o Carrito.',16,1);

		IF @valorRecargo < 0
			RAISERROR('valorRecargo no puede ser negativo.',16,1);

		IF @diasVencimientoCargo < 0
			RAISERROR('diasVencimientoCargo no puede ser negativo.',16,1);

		IF @limiteCreditoDefaultExpress < 0
			RAISERROR('limiteCreditoDefaultExpress no puede ser negativo.',16,1);

		BEGIN TRAN;

		UPDATE [dbo].[cat_configuracionCredito]
		   SET [vigenteHasta] = dbo.fn_GetDateMX(),
		       [fechaModificacion] = dbo.fn_GetDateMX(),
		       [idUsuarioModifica] = @idUsuarioAlta
		 WHERE [idEntidad] = @idEntidad
		   AND [vigenteHasta] IS NULL;

		INSERT INTO [dbo].[cat_configuracionCredito]
		(
			[tipoValorRecargo],[nivelAplicacion],[valorRecargo],[diasVencimientoCargo],
			[limiteCreditoDefaultExpress],[vigenteDesde],[vigenteHasta],[activo],[idEntidad],
			[fechaAlta],[idUsuarioAlta]
		)
		VALUES
		(
			@tipoValorRecargo, @nivelAplicacion, @valorRecargo, @diasVencimientoCargo,
			@limiteCreditoDefaultExpress, dbo.fn_GetDateMX(), NULL, 1, @idEntidad,
			dbo.fn_GetDateMX(), @idUsuarioAlta
		);

		COMMIT TRAN;

		SELECT * FROM [dbo].[cat_configuracionCredito] WHERE [idEntidad] = @idEntidad AND [vigenteHasta] IS NULL;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		DECLARE @ErrorMessage varchar(4000) = ERROR_MESSAGE();
		RAISERROR('Error en sp_ui_creditoConfiguracionGuardar: %s',16,1,@ErrorMessage);
	END CATCH
END
GO


-- ============================================================================
-- B) CLIENTE / CREDITO HABILITADO / LIMITE
-- ============================================================================

CREATE PROCEDURE [dbo].[sp_ui_creditoClienteHabilitar]
(
	@idPersona int,
	@creditoHabilitado bit,
	@limiteCredito decimal(18,2) = NULL,
	@idEntidad int,
	@idUsuarioAlta int
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	-- Nota de diseno confirmada: se permite deshabilitar el credito de un cliente
	-- aunque tenga saldoActual > 0 (cliente moroso). Deshabilitar SOLO bloquea
	-- nuevos Cargos (ver validacion en sp_ui_creditoInsertCargo); el cliente
	-- siempre puede seguir abonando/liquidando lo que ya debe, sin importar este
	-- flag. Por eso aqui no se valida saldoActual en absoluto.

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM [dbo].[cat_personas] WHERE [id] = @idPersona AND [idEntidad] = @idEntidad)
			RAISERROR('Cliente no encontrado.',16,1);

		DECLARE @limiteFinal decimal(18,2) = @limiteCredito;

		IF @creditoHabilitado = 1 AND @limiteFinal IS NULL
		BEGIN
			SELECT @limiteFinal = [limiteCreditoDefaultExpress]
			FROM [dbo].[cat_configuracionCredito]
			WHERE [idEntidad] = @idEntidad AND [vigenteHasta] IS NULL;

			IF @limiteFinal IS NULL
				RAISERROR('No existe configuracion de credito activa para tomar el limite por defecto.',16,1);
		END

		BEGIN TRAN;

		UPDATE [dbo].[cat_personas]
		   SET [creditoHabilitado] = @creditoHabilitado,
		       [limiteCredito] = ISNULL(@limiteFinal, [limiteCredito]),
		       [fechaModificacion] = dbo.fn_GetDateMX(),
		       [idUsuarioModifica] = @idUsuarioAlta
		 WHERE [id] = @idPersona AND [idEntidad] = @idEntidad;

		COMMIT TRAN;

		SELECT [id], [creditoHabilitado], [limiteCredito], [saldoActual]
		FROM [dbo].[cat_personas] WHERE [id] = @idPersona AND [idEntidad] = @idEntidad;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		DECLARE @ErrorMessage varchar(4000) = ERROR_MESSAGE();
		RAISERROR('Error en sp_ui_creditoClienteHabilitar: %s',16,1,@ErrorMessage);
	END CATCH
END
GO

CREATE PROCEDURE [dbo].[sp_ui_creditoLimiteActualizar]
(
	@idPersona int,
	@limiteNuevo decimal(18,2),
	@motivo varchar(450),
	@idEntidad int,
	@idSucursal int,
	@idUsuarioAlta int
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @limiteAnterior decimal(18,2);

	BEGIN TRY
		IF @limiteNuevo < 0
			RAISERROR('El limite no puede ser negativo.',16,1);

		IF ISNULL(LTRIM(RTRIM(@motivo)),'') = ''
			RAISERROR('El motivo es obligatorio.',16,1);

		BEGIN TRAN;

		SELECT @limiteAnterior = [limiteCredito]
		FROM [dbo].[cat_personas] WITH (UPDLOCK, HOLDLOCK)
		WHERE [id] = @idPersona AND [idEntidad] = @idEntidad;

		IF @@ROWCOUNT = 0
			RAISERROR('Cliente no encontrado.',16,1);

		SET @limiteAnterior = ISNULL(@limiteAnterior, 0);

		INSERT INTO [dbo].[proc_creditoLimiteHistorial]
		(
			[idPersona],[limiteAnterior],[limiteNuevo],[motivo],[idEntidad],[idSucursal],
			[fechaAlta],[idUsuarioAlta]
		)
		VALUES
		(
			@idPersona, @limiteAnterior, @limiteNuevo, @motivo, @idEntidad, @idSucursal,
			dbo.fn_GetDateMX(), @idUsuarioAlta
		);

		UPDATE [dbo].[cat_personas]
		   SET [limiteCredito] = @limiteNuevo,
		       [fechaModificacion] = dbo.fn_GetDateMX(),
		       [idUsuarioModifica] = @idUsuarioAlta
		 WHERE [id] = @idPersona AND [idEntidad] = @idEntidad;

		COMMIT TRAN;

		SELECT [id], [limiteCredito], [saldoActual] FROM [dbo].[cat_personas] WHERE [id] = @idPersona AND [idEntidad] = @idEntidad;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		DECLARE @ErrorMessage varchar(4000) = ERROR_MESSAGE();
		RAISERROR('Error en sp_ui_creditoLimiteActualizar: %s',16,1,@ErrorMessage);
	END CATCH
END
GO


-- ============================================================================
-- C) NUCLEO TRANSACCIONAL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn_creditoCalcularRecargo: aplica la configuracion activa de la Entidad al
-- carrito recibido. Si no hay configuracion activa, regresa 0 filas (el llamador
-- debe validar esto, igual que sp_ui_creditoInsertCargo lo hace por su cuenta).
-- ----------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fn_creditoCalcularRecargo]
(
	@idEntidad int,
	@carrito [dbo].[tvp_creditoCarritoItem] READONLY
)
RETURNS TABLE
AS
RETURN
(
	WITH Config AS
	(
		SELECT TOP (1) [tipoValorRecargo], [nivelAplicacion], [valorRecargo]
		FROM [dbo].[cat_configuracionCredito]
		WHERE [idEntidad] = @idEntidad AND [vigenteHasta] IS NULL
	),
	Totales AS
	(
		SELECT
			ISNULL(SUM(c.[cantidad] * c.[precio]), 0) AS [totalSinRecargo],
			ISNULL(SUM(c.[cantidad]), 0) AS [cantidadTotal]
		FROM @carrito c
	)
	SELECT
		t.[totalSinRecargo],
		CASE
			WHEN cfg.[nivelAplicacion] = 'Carrito'  AND cfg.[tipoValorRecargo] = 'Fijo'       THEN cfg.[valorRecargo]
			WHEN cfg.[nivelAplicacion] = 'Carrito'  AND cfg.[tipoValorRecargo] = 'Porcentaje' THEN t.[totalSinRecargo] * cfg.[valorRecargo] / 100.0
			WHEN cfg.[nivelAplicacion] = 'Producto' AND cfg.[tipoValorRecargo] = 'Fijo'       THEN t.[cantidadTotal] * cfg.[valorRecargo]
			WHEN cfg.[nivelAplicacion] = 'Producto' AND cfg.[tipoValorRecargo] = 'Porcentaje' THEN t.[totalSinRecargo] * cfg.[valorRecargo] / 100.0
			ELSE 0
		END AS [montoRecargo],
		t.[totalSinRecargo] +
		CASE
			WHEN cfg.[nivelAplicacion] = 'Carrito'  AND cfg.[tipoValorRecargo] = 'Fijo'       THEN cfg.[valorRecargo]
			WHEN cfg.[nivelAplicacion] = 'Carrito'  AND cfg.[tipoValorRecargo] = 'Porcentaje' THEN t.[totalSinRecargo] * cfg.[valorRecargo] / 100.0
			WHEN cfg.[nivelAplicacion] = 'Producto' AND cfg.[tipoValorRecargo] = 'Fijo'       THEN t.[cantidadTotal] * cfg.[valorRecargo]
			WHEN cfg.[nivelAplicacion] = 'Producto' AND cfg.[tipoValorRecargo] = 'Porcentaje' THEN t.[totalSinRecargo] * cfg.[valorRecargo] / 100.0
			ELSE 0
		END AS [totalConRecargo]
	FROM Totales t
	CROSS JOIN Config cfg
);
GO

-- ----------------------------------------------------------------------------
-- sp_ui_creditoInsertCargo
-- Enganche con la venta: la API lo llama como paso adicional, dentro de la misma
-- transaccion ADO.NET que ya usa para sp_in_entradasSalidas /
-- sp_in_entradasSalidasDetalles / sp_in_EntradasSalidaPago, justo despues de
-- insertar en proc_entradasSalidaPago la fila con idTipoPago = Credito.
-- ----------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_ui_creditoInsertCargo]
(
	@folioEntradaSalida int,
	@idPersona int,
	@montoConRecargo decimal(18,2),
	@idEntidad int,
	@idSucursal int,
	@idUsuarioAlta int
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE
		@saldoActual decimal(18,2),
		@limiteCredito decimal(18,2),
		@creditoHabilitado bit,
		@saldoDisponible decimal(18,2),
		@diasVencimientoCargo int,
		@idTipoMovimientoCredito int,
		@folioMovimientoCredito int,
		@saldoNuevo decimal(18,2),
		@fechaVencimiento datetime,
		@msg varchar(300);

	BEGIN TRY
		IF @montoConRecargo <= 0
			RAISERROR('El monto del cargo debe ser mayor a cero.',16,1);

		IF EXISTS (SELECT 1 FROM [dbo].[proc_movimientosCredito] WHERE [folioEntradaSalidaRelacionado] = @folioEntradaSalida AND [idEntidad] = @idEntidad)
			RAISERROR('Ya existe un cargo de credito registrado para esta venta.',16,1);

		BEGIN TRAN;

		SELECT
			@saldoActual = ISNULL([saldoActual],0),
			@limiteCredito = ISNULL([limiteCredito],0),
			@creditoHabilitado = ISNULL([creditoHabilitado],0)
		FROM [dbo].[cat_personas] WITH (UPDLOCK, HOLDLOCK)
		WHERE [id] = @idPersona AND [idEntidad] = @idEntidad;

		IF @@ROWCOUNT = 0
			RAISERROR('Cliente no encontrado.',16,1);

		IF @creditoHabilitado = 0
			RAISERROR('El cliente no tiene credito habilitado.',16,1);

		SET @saldoDisponible = @limiteCredito - @saldoActual;

		IF @montoConRecargo > @saldoDisponible
		BEGIN
			SET @msg = 'Saldo de credito insuficiente. Disponible: ' + CONVERT(varchar(30),@saldoDisponible) + ', requerido: ' + CONVERT(varchar(30),@montoConRecargo) + '.';
			RAISERROR(@msg,16,1);
		END

		SELECT @diasVencimientoCargo = [diasVencimientoCargo]
		FROM [dbo].[cat_configuracionCredito]
		WHERE [idEntidad] = @idEntidad AND [vigenteHasta] IS NULL;

		IF @diasVencimientoCargo IS NULL
			RAISERROR('No existe configuracion de credito activa para esta Entidad.',16,1);

		SELECT @idTipoMovimientoCredito = [id]
		FROM [dbo].[cat_tipoMovimientoCredito]
		WHERE [clave] = 'CARGO' AND [idEntidad] = @idEntidad AND ISNULL([activo],1) = 1;

		IF @idTipoMovimientoCredito IS NULL
			RAISERROR('No existe el tipo de movimiento CARGO configurado para esta Entidad.',16,1);

		SET @fechaVencimiento = DATEADD(DAY, @diasVencimientoCargo, dbo.fn_GetDateMX());
		SET @saldoNuevo = @saldoActual + @montoConRecargo;

		SELECT @folioMovimientoCredito = ISNULL(MAX([folioMovimientoCredito]),0) + 1
		FROM [dbo].[proc_movimientosCredito] WITH (UPDLOCK, HOLDLOCK)
		WHERE [idEntidad] = @idEntidad AND [idSucursal] = @idSucursal;

		INSERT INTO [dbo].[proc_movimientosCredito]
		(
			[folioMovimientoCredito],[idPersona],[idTipoMovimientoCredito],[monto],[saldoAnterior],[saldoNuevo],
			[folioEntradaSalidaRelacionado],[fechaVencimiento],[activo],[idEntidad],[idSucursal],
			[fechaAlta],[idUsuarioAlta]
		)
		VALUES
		(
			@folioMovimientoCredito, @idPersona, @idTipoMovimientoCredito, @montoConRecargo, @saldoActual, @saldoNuevo,
			@folioEntradaSalida, @fechaVencimiento, 1, @idEntidad, @idSucursal,
			dbo.fn_GetDateMX(), @idUsuarioAlta
		);

		UPDATE [dbo].[cat_personas]
		   SET [saldoActual] = @saldoNuevo,
		       [fechaUltimoMovimientoCredito] = dbo.fn_GetDateMX(),
		       [fechaModificacion] = dbo.fn_GetDateMX(),
		       [idUsuarioModifica] = @idUsuarioAlta
		 WHERE [id] = @idPersona AND [idEntidad] = @idEntidad;

		COMMIT TRAN;

		SELECT * FROM [dbo].[proc_movimientosCredito]
		WHERE [folioMovimientoCredito] = @folioMovimientoCredito AND [idEntidad] = @idEntidad AND [idSucursal] = @idSucursal;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		DECLARE @ErrorMessage varchar(4000) = ERROR_MESSAGE();
		DECLARE @ErrorLine int = ERROR_LINE();
		RAISERROR('Error en sp_ui_creditoInsertCargo. Linea: %d. Mensaje: %s',16,1,@ErrorLine,@ErrorMessage);
	END CATCH
END
GO

CREATE PROCEDURE [dbo].[sp_ui_creditoInsertAbono]
(
	@idPersona int,
	@pagos [dbo].[tvp_creditoPago] READONLY,
	@esLiquidacion bit = 0,
	@idEntidad int,
	@idSucursal int,
	@idUsuarioAlta int
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE
		@saldoActual decimal(18,2),
		@montoAbono decimal(18,2),
		@idTipoMovimientoCredito int,
		@folioMovimientoCredito int,
		@saldoNuevo decimal(18,2),
		@claveTipo varchar(30),
		@msg varchar(300);

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM @pagos)
			RAISERROR('Debe capturar al menos una forma de pago.',16,1);

		IF EXISTS (SELECT 1 FROM @pagos p WHERE NOT EXISTS (SELECT 1 FROM [dbo].[cat_tiposPago] tp WHERE tp.[id] = p.[idTipoPago] AND tp.[idEntidad] = @idEntidad))
			RAISERROR('Una de las formas de pago capturadas no existe para esta Entidad.',16,1);

		SELECT @montoAbono = SUM([montoPago]) FROM @pagos;

		IF @montoAbono <= 0
			RAISERROR('El monto del abono debe ser mayor a cero.',16,1);

		BEGIN TRAN;

		SELECT @saldoActual = ISNULL([saldoActual],0)
		FROM [dbo].[cat_personas] WITH (UPDLOCK, HOLDLOCK)
		WHERE [id] = @idPersona AND [idEntidad] = @idEntidad;

		IF @@ROWCOUNT = 0
			RAISERROR('Cliente no encontrado.',16,1);

		IF @esLiquidacion = 1 AND @montoAbono <> @saldoActual
		BEGIN
			SET @msg = 'Para liquidar, el monto capturado (' + CONVERT(varchar(30),@montoAbono) + ') debe ser igual al saldo actual (' + CONVERT(varchar(30),@saldoActual) + ').';
			RAISERROR(@msg,16,1);
		END

		IF @montoAbono > @saldoActual
		BEGIN
			SET @msg = 'El abono (' + CONVERT(varchar(30),@montoAbono) + ') no puede ser mayor al saldo pendiente (' + CONVERT(varchar(30),@saldoActual) + ').';
			RAISERROR(@msg,16,1);
		END

		SET @claveTipo = CASE WHEN @esLiquidacion = 1 THEN 'LIQUIDACION' ELSE 'ABONO' END;

		SELECT @idTipoMovimientoCredito = [id]
		FROM [dbo].[cat_tipoMovimientoCredito]
		WHERE [clave] = @claveTipo AND [idEntidad] = @idEntidad AND ISNULL([activo],1) = 1;

		IF @idTipoMovimientoCredito IS NULL
		BEGIN
			SET @msg = 'No existe el tipo de movimiento ' + @claveTipo + ' configurado para esta Entidad.';
			RAISERROR(@msg,16,1);
		END

		SET @saldoNuevo = @saldoActual - @montoAbono;

		SELECT @folioMovimientoCredito = ISNULL(MAX([folioMovimientoCredito]),0) + 1
		FROM [dbo].[proc_movimientosCredito] WITH (UPDLOCK, HOLDLOCK)
		WHERE [idEntidad] = @idEntidad AND [idSucursal] = @idSucursal;

		INSERT INTO [dbo].[proc_movimientosCredito]
		(
			[folioMovimientoCredito],[idPersona],[idTipoMovimientoCredito],[monto],[saldoAnterior],[saldoNuevo],
			[activo],[idEntidad],[idSucursal],[fechaAlta],[idUsuarioAlta]
		)
		VALUES
		(
			@folioMovimientoCredito, @idPersona, @idTipoMovimientoCredito, @montoAbono, @saldoActual, @saldoNuevo,
			1, @idEntidad, @idSucursal, dbo.fn_GetDateMX(), @idUsuarioAlta
		);

		INSERT INTO [dbo].[proc_movimientosCreditoPago]
		(
			[folioMovimientoCredito],[idTipoPago],[montoPago],[numeroAutorizacion],[activo],[idEntidad],[idSucursal],
			[fechaAlta],[idUsuarioAlta]
		)
		SELECT
			@folioMovimientoCredito, p.[idTipoPago], p.[montoPago], p.[numeroAutorizacion], 1, @idEntidad, @idSucursal,
			dbo.fn_GetDateMX(), @idUsuarioAlta
		FROM @pagos p;

		UPDATE [dbo].[cat_personas]
		   SET [saldoActual] = @saldoNuevo,
		       [fechaUltimoMovimientoCredito] = dbo.fn_GetDateMX(),
		       [fechaModificacion] = dbo.fn_GetDateMX(),
		       [idUsuarioModifica] = @idUsuarioAlta
		 WHERE [id] = @idPersona AND [idEntidad] = @idEntidad;

		COMMIT TRAN;

		SELECT * FROM [dbo].[proc_movimientosCredito]
		WHERE [folioMovimientoCredito] = @folioMovimientoCredito AND [idEntidad] = @idEntidad AND [idSucursal] = @idSucursal;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		DECLARE @ErrorMessage varchar(4000) = ERROR_MESSAGE();
		DECLARE @ErrorLine int = ERROR_LINE();
		RAISERROR('Error en sp_ui_creditoInsertAbono. Linea: %d. Mensaje: %s',16,1,@ErrorLine,@ErrorMessage);
	END CATCH
END
GO

CREATE PROCEDURE [dbo].[sp_ui_creditoInsertAjuste]
(
	@idPersona int,
	@monto decimal(18,2),
	@motivo varchar(450),
	@idEntidad int,
	@idSucursal int,
	@idUsuarioAlta int
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE
		@saldoActual decimal(18,2),
		@saldoNuevo decimal(18,2),
		@idTipoMovimientoCredito int,
		@folioMovimientoCredito int;

	BEGIN TRY
		IF @monto = 0
			RAISERROR('El monto del ajuste no puede ser cero.',16,1);

		IF ISNULL(LTRIM(RTRIM(@motivo)),'') = ''
			RAISERROR('El motivo es obligatorio para un ajuste.',16,1);

		BEGIN TRAN;

		SELECT @saldoActual = ISNULL([saldoActual],0)
		FROM [dbo].[cat_personas] WITH (UPDLOCK, HOLDLOCK)
		WHERE [id] = @idPersona AND [idEntidad] = @idEntidad;

		IF @@ROWCOUNT = 0
			RAISERROR('Cliente no encontrado.',16,1);

		SET @saldoNuevo = @saldoActual + @monto;

		IF @saldoNuevo < 0
			RAISERROR('El ajuste dejaria el saldo en negativo.',16,1);

		SELECT @idTipoMovimientoCredito = [id]
		FROM [dbo].[cat_tipoMovimientoCredito]
		WHERE [clave] = 'AJUSTE' AND [idEntidad] = @idEntidad AND ISNULL([activo],1) = 1;

		IF @idTipoMovimientoCredito IS NULL
			RAISERROR('No existe el tipo de movimiento AJUSTE configurado para esta Entidad.',16,1);

		SELECT @folioMovimientoCredito = ISNULL(MAX([folioMovimientoCredito]),0) + 1
		FROM [dbo].[proc_movimientosCredito] WITH (UPDLOCK, HOLDLOCK)
		WHERE [idEntidad] = @idEntidad AND [idSucursal] = @idSucursal;

		INSERT INTO [dbo].[proc_movimientosCredito]
		(
			[folioMovimientoCredito],[idPersona],[idTipoMovimientoCredito],[monto],[saldoAnterior],[saldoNuevo],
			[motivo],[activo],[idEntidad],[idSucursal],[fechaAlta],[idUsuarioAlta]
		)
		VALUES
		(
			@folioMovimientoCredito, @idPersona, @idTipoMovimientoCredito, ABS(@monto), @saldoActual, @saldoNuevo,
			@motivo, 1, @idEntidad, @idSucursal, dbo.fn_GetDateMX(), @idUsuarioAlta
		);

		UPDATE [dbo].[cat_personas]
		   SET [saldoActual] = @saldoNuevo,
		       [fechaUltimoMovimientoCredito] = dbo.fn_GetDateMX(),
		       [fechaModificacion] = dbo.fn_GetDateMX(),
		       [idUsuarioModifica] = @idUsuarioAlta
		 WHERE [id] = @idPersona AND [idEntidad] = @idEntidad;

		COMMIT TRAN;

		SELECT * FROM [dbo].[proc_movimientosCredito]
		WHERE [folioMovimientoCredito] = @folioMovimientoCredito AND [idEntidad] = @idEntidad AND [idSucursal] = @idSucursal;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		DECLARE @ErrorMessage varchar(4000) = ERROR_MESSAGE();
		DECLARE @ErrorLine int = ERROR_LINE();
		RAISERROR('Error en sp_ui_creditoInsertAjuste. Linea: %d. Mensaje: %s',16,1,@ErrorLine,@ErrorMessage);
	END CATCH
END
GO

-- ----------------------------------------------------------------------------
-- sp_ui_creditoReversaCargo
-- Sin parametro de monto parcial (no existe devolucion parcial en el flujo
-- actual). Se ejecuta vía EXEC anidado desde sp_in_movimentosInventarios (ver
-- seccion E) dentro de la transaccion ambiente que ya abre la API para
-- cancelaciones; BEGIN TRAN/COMMIT TRAN aqui son anidados y seguros: si algo
-- falla, el ROLLBACK revierte toda la transaccion ambiente, no solo esta parte.
-- ----------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_ui_creditoReversaCargo]
(
	@folioEntradaSalida int,
	@idEntidad int,
	@idSucursal int,
	@idUsuarioAlta int
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE
		@idPersona int,
		@folioCargoOrigen int,
		@montoCargo decimal(18,2),
		@saldoActual decimal(18,2),
		@saldoNuevo decimal(18,2),
		@idTipoMovimientoCredito int,
		@folioMovimientoCredito int;

	BEGIN TRY
		SELECT
			@idPersona = mc.[idPersona],
			@folioCargoOrigen = mc.[folioMovimientoCredito],
			@montoCargo = mc.[monto]
		FROM [dbo].[proc_movimientosCredito] mc
		INNER JOIN [dbo].[cat_tipoMovimientoCredito] tm
			ON tm.[id] = mc.[idTipoMovimientoCredito] AND tm.[idEntidad] = mc.[idEntidad]
		WHERE mc.[folioEntradaSalidaRelacionado] = @folioEntradaSalida
		  AND mc.[idEntidad] = @idEntidad
		  AND tm.[clave] = 'CARGO';

		IF @folioCargoOrigen IS NULL
			RAISERROR('No existe un Cargo de credito relacionado a esta venta.',16,1);

		IF EXISTS
		(
			SELECT 1
			FROM [dbo].[proc_movimientosCredito] r
			INNER JOIN [dbo].[cat_tipoMovimientoCredito] tmr
				ON tmr.[id] = r.[idTipoMovimientoCredito] AND tmr.[idEntidad] = r.[idEntidad]
			WHERE tmr.[clave] = 'REVERSA_CARGO'
			  AND r.[folioMovimientoCreditoOrigen] = @folioCargoOrigen
			  AND r.[idEntidad] = @idEntidad
		)
			RAISERROR('Este Cargo ya fue revertido anteriormente.',16,1);

		BEGIN TRAN;

		SELECT @saldoActual = ISNULL([saldoActual],0)
		FROM [dbo].[cat_personas] WITH (UPDLOCK, HOLDLOCK)
		WHERE [id] = @idPersona AND [idEntidad] = @idEntidad;

		IF @@ROWCOUNT = 0
			RAISERROR('Cliente del Cargo original no encontrado.',16,1);

		SET @saldoNuevo = @saldoActual - @montoCargo;

		SELECT @idTipoMovimientoCredito = [id]
		FROM [dbo].[cat_tipoMovimientoCredito]
		WHERE [clave] = 'REVERSA_CARGO' AND [idEntidad] = @idEntidad AND ISNULL([activo],1) = 1;

		IF @idTipoMovimientoCredito IS NULL
			RAISERROR('No existe el tipo de movimiento REVERSA_CARGO configurado para esta Entidad.',16,1);

		SELECT @folioMovimientoCredito = ISNULL(MAX([folioMovimientoCredito]),0) + 1
		FROM [dbo].[proc_movimientosCredito] WITH (UPDLOCK, HOLDLOCK)
		WHERE [idEntidad] = @idEntidad AND [idSucursal] = @idSucursal;

		INSERT INTO [dbo].[proc_movimientosCredito]
		(
			[folioMovimientoCredito],[idPersona],[idTipoMovimientoCredito],[monto],[saldoAnterior],[saldoNuevo],
			[folioEntradaSalidaRelacionado],[folioMovimientoCreditoOrigen],[activo],[idEntidad],[idSucursal],
			[fechaAlta],[idUsuarioAlta]
		)
		VALUES
		(
			@folioMovimientoCredito, @idPersona, @idTipoMovimientoCredito, @montoCargo, @saldoActual, @saldoNuevo,
			@folioEntradaSalida, @folioCargoOrigen, 1, @idEntidad, @idSucursal,
			dbo.fn_GetDateMX(), @idUsuarioAlta
		);

		UPDATE [dbo].[cat_personas]
		   SET [saldoActual] = @saldoNuevo,
		       [fechaUltimoMovimientoCredito] = dbo.fn_GetDateMX(),
		       [fechaModificacion] = dbo.fn_GetDateMX(),
		       [idUsuarioModifica] = @idUsuarioAlta
		 WHERE [id] = @idPersona AND [idEntidad] = @idEntidad;

		COMMIT TRAN;

		SELECT * FROM [dbo].[proc_movimientosCredito]
		WHERE [folioMovimientoCredito] = @folioMovimientoCredito AND [idEntidad] = @idEntidad AND [idSucursal] = @idSucursal;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		DECLARE @ErrorMessage varchar(4000) = ERROR_MESSAGE();
		DECLARE @ErrorLine int = ERROR_LINE();
		RAISERROR('Error en sp_ui_creditoReversaCargo. Linea: %d. Mensaje: %s',16,1,@ErrorLine,@ErrorMessage);
	END CATCH
END
GO


-- ============================================================================
-- D) CONSULTA / LECTURA
-- ============================================================================

CREATE PROCEDURE [dbo].[sp_ui_creditoGetSaldoCliente]
(
	@idPersona int,
	@idEntidad int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		p.[id] AS [idPersona],
		p.[nombre], p.[apellidoPaterno], p.[apellidoMaterno],
		ISNULL(p.[creditoHabilitado],0) AS [creditoHabilitado],
		ISNULL(p.[limiteCredito],0) AS [limiteCredito],
		ISNULL(p.[saldoActual],0) AS [saldoActual],
		ISNULL(p.[limiteCredito],0) - ISNULL(p.[saldoActual],0) AS [saldoDisponible],
		p.[fechaUltimoMovimientoCredito]
	FROM [dbo].[cat_personas] p
	WHERE p.[id] = @idPersona AND p.[idEntidad] = @idEntidad;
END
GO

CREATE PROCEDURE [dbo].[sp_ui_creditoGetHistorialCliente]
(
	@idPersona int,
	@idEntidad int,
	@fechaInicio datetime = NULL,
	@fechaFin datetime = NULL,
	@clave varchar(30) = NULL,
	@pagina int = 1,
	@tamanoPagina int = 50
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		mc.[folioMovimientoCredito], mc.[idSucursal], tm.[clave] AS [tipoMovimiento], tm.[descripcion] AS [tipoMovimientoDescripcion],
		mc.[monto], mc.[saldoAnterior], mc.[saldoNuevo], mc.[folioEntradaSalidaRelacionado],
		mc.[fechaVencimiento], mc.[motivo], mc.[folioMovimientoCreditoOrigen], mc.[fechaAlta], mc.[idUsuarioAlta]
	FROM [dbo].[proc_movimientosCredito] mc
	INNER JOIN [dbo].[cat_tipoMovimientoCredito] tm ON tm.[id] = mc.[idTipoMovimientoCredito] AND tm.[idEntidad] = mc.[idEntidad]
	WHERE mc.[idPersona] = @idPersona
	  AND mc.[idEntidad] = @idEntidad
	  AND (@fechaInicio IS NULL OR mc.[fechaAlta] >= @fechaInicio)
	  AND (@fechaFin IS NULL OR mc.[fechaAlta] < DATEADD(DAY,1,@fechaFin))
	  AND (@clave IS NULL OR tm.[clave] = @clave)
	ORDER BY mc.[fechaAlta] DESC
	OFFSET (@pagina - 1) * @tamanoPagina ROWS FETCH NEXT @tamanoPagina ROWS ONLY;
END
GO

CREATE PROCEDURE [dbo].[sp_ui_creditoGetHistorialGlobal]
(
	@idEntidad int,
	@idSucursal int = NULL,
	@idUsuarioAlta int = NULL,
	@clave varchar(30) = NULL,
	@fechaInicio datetime = NULL,
	@fechaFin datetime = NULL,
	@pagina int = 1,
	@tamanoPagina int = 50
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		mc.[folioMovimientoCredito], mc.[idSucursal], mc.[idPersona],
		p.[nombre], p.[apellidoPaterno], p.[apellidoMaterno],
		tm.[clave] AS [tipoMovimiento], tm.[descripcion] AS [tipoMovimientoDescripcion],
		mc.[monto], mc.[saldoAnterior], mc.[saldoNuevo], mc.[folioEntradaSalidaRelacionado],
		mc.[fechaVencimiento], mc.[motivo], mc.[fechaAlta], mc.[idUsuarioAlta]
	FROM [dbo].[proc_movimientosCredito] mc
	INNER JOIN [dbo].[cat_tipoMovimientoCredito] tm ON tm.[id] = mc.[idTipoMovimientoCredito] AND tm.[idEntidad] = mc.[idEntidad]
	INNER JOIN [dbo].[cat_personas] p ON p.[id] = mc.[idPersona] AND p.[idEntidad] = mc.[idEntidad]
	WHERE mc.[idEntidad] = @idEntidad
	  AND (@idSucursal IS NULL OR mc.[idSucursal] = @idSucursal)
	  AND (@idUsuarioAlta IS NULL OR mc.[idUsuarioAlta] = @idUsuarioAlta)
	  AND (@clave IS NULL OR tm.[clave] = @clave)
	  AND (@fechaInicio IS NULL OR mc.[fechaAlta] >= @fechaInicio)
	  AND (@fechaFin IS NULL OR mc.[fechaAlta] < DATEADD(DAY,1,@fechaFin))
	ORDER BY mc.[fechaAlta] DESC
	OFFSET (@pagina - 1) * @tamanoPagina ROWS FETCH NEXT @tamanoPagina ROWS ONLY;
END
GO

CREATE PROCEDURE [dbo].[sp_ui_creditoGetListadoClientes]
(
	@idEntidad int
)
AS
BEGIN
	SET NOCOUNT ON;

	;WITH Rezago AS
	(
		SELECT
			[idPersona],
			MIN([fechaVencimiento]) AS [fechaVencimientoMasAntigua]
		FROM [dbo].[vw_creditoCargosPendientes]
		WHERE [idEntidad] = @idEntidad AND [montoPendiente] > 0
		GROUP BY [idPersona]
	)
	SELECT
		p.[id] AS [idPersona],
		p.[nombre], p.[apellidoPaterno], p.[apellidoMaterno], p.[numeroTelefono],
		ISNULL(p.[limiteCredito],0) AS [limiteCredito],
		ISNULL(p.[saldoActual],0) AS [saldoActual],
		CASE WHEN ISNULL(p.[limiteCredito],0) = 0 THEN 0 ELSE ISNULL(p.[saldoActual],0) / p.[limiteCredito] END AS [porcentajeUso],
		p.[fechaUltimoMovimientoCredito],
		CASE
			WHEN r.[fechaVencimientoMasAntigua] IS NULL THEN 'Al dia'
			WHEN r.[fechaVencimientoMasAntigua] < dbo.fn_GetDateMX() THEN 'Vencido'
			ELSE 'Al dia'
		END AS [estado]
	FROM [dbo].[cat_personas] p
	LEFT JOIN Rezago r ON r.[idPersona] = p.[id]
	WHERE p.[idEntidad] = @idEntidad
	  AND ISNULL(p.[creditoHabilitado],0) = 1
	ORDER BY p.[nombre];
END
GO

CREATE PROCEDURE [dbo].[sp_ui_creditoGetDashboard]
(
	@idEntidad int,
	@fechaInicio datetime,
	@fechaFin datetime
)
AS
BEGIN
	SET NOCOUNT ON;

	-- 1) Total en cartera
	SELECT ISNULL(SUM([saldoActual]),0) AS [totalCartera]
	FROM [dbo].[cat_personas]
	WHERE [idEntidad] = @idEntidad AND ISNULL([creditoHabilitado],0) = 1;

	-- 2) Otorgado vs cobrado en el rango
	SELECT
		tm.[clave] AS [tipoMovimiento],
		SUM(mc.[monto]) AS [total],
		COUNT(*) AS [numMovimientos]
	FROM [dbo].[proc_movimientosCredito] mc
	INNER JOIN [dbo].[cat_tipoMovimientoCredito] tm ON tm.[id] = mc.[idTipoMovimientoCredito] AND tm.[idEntidad] = mc.[idEntidad]
	WHERE mc.[idEntidad] = @idEntidad
	  AND mc.[fechaAlta] >= @fechaInicio
	  AND mc.[fechaAlta] < DATEADD(DAY,1,@fechaFin)
	GROUP BY tm.[clave];

	-- 3) Clientes con mayor rezago (dias de atraso x saldo pendiente = prioridad de cobro)
	SELECT TOP (50)
		p.[id] AS [idPersona], p.[nombre], p.[apellidoPaterno], p.[apellidoMaterno], p.[numeroTelefono],
		SUM(v.[montoPendiente]) AS [saldoPendiente],
		MIN(v.[fechaVencimiento]) AS [fechaVencimientoMasAntigua],
		DATEDIFF(DAY, MIN(v.[fechaVencimiento]), dbo.fn_GetDateMX()) AS [diasAtraso],
		SUM(v.[montoPendiente]) * DATEDIFF(DAY, MIN(v.[fechaVencimiento]), dbo.fn_GetDateMX()) AS [prioridadCobro]
	FROM [dbo].[vw_creditoCargosPendientes] v
	INNER JOIN [dbo].[cat_personas] p ON p.[id] = v.[idPersona] AND p.[idEntidad] = v.[idEntidad]
	WHERE v.[idEntidad] = @idEntidad
	  AND v.[montoPendiente] > 0
	  AND v.[fechaVencimiento] < dbo.fn_GetDateMX()
	GROUP BY p.[id], p.[nombre], p.[apellidoPaterno], p.[apellidoMaterno], p.[numeroTelefono]
	ORDER BY [prioridadCobro] DESC;
END
GO


-- ============================================================================
-- E) MODIFICACION A SP EXISTENTE: sp_in_movimentosInventarios
-- Aditivo: se agrega el disparo de la reversa de credito dentro del bloque que
-- ya existe para idTipoMovimientoInventario = 1004 (Cancelacion de Ticket),
-- justo despues del UPDATE de idEstadoTicket. El resto del SP queda igual al
-- que compartio Victor. Tickets pagados en efectivo/tarjeta no tienen fila
-- CARGO relacionada, asi que el EXISTS es falso y no cambia nada para ellos.
-- ============================================================================
ALTER PROCEDURE [dbo].[sp_in_movimentosInventarios]
(
     @folioMovimientoInventario INT,
     @idTipoMovimientoInventario INT,
     @idDocumentoReferencia INT = NULL,
     @idAlmacen INT = NULL,
     @idMotivoMovimiento INT = NULL,
     @idEstadoMovimiento INT = NULL,
     @idPersona INT = NULL,
     @comentarios VARCHAR(450) = '',
     @activo BIT,
     @idEntidad INT,
     @idUsuarioModifica INT,
     @idSucursal int = null
)
AS
BEGIN

    BEGIN TRY

        INSERT INTO proc_movimientosInventarios
        (
            folioMovimientoInventario,
            idTipoMovimientoInventario,
            idDocumentoReferencia,
            idAlmacen,
            idMotivoMovimiento,
            idEstadoMovimiento,
            idPersona,
            comentarios,
            activo,
            idEntidad,
            fechaAlta,
            idUsuarioAlta ,
            idSucursal
        )
        VALUES
        (
            @folioMovimientoInventario,
            @idTipoMovimientoInventario,
            @idDocumentoReferencia,
            @idAlmacen,
            @idMotivoMovimiento,
            @idEstadoMovimiento,
            @idPersona,
            @comentarios,
            @activo,
            @idEntidad,
            dbo.fn_GetDateMX(),
            @idUsuarioModifica,
            ISNULL(@idSucursal,0)
        );

  IF(@idTipoMovimientoInventario = 1004)
  BEGIN
   UPDATE proc_entradasSalidas
   SET idEstadoTicket = 4,
   idUsuarioModifica = @idUsuarioModifica,
   fechaModificacion = dbo.fn_GetDateMX()
   WHERE folioEntradaSalida = @idDocumentoReferencia
   AND idEntidad = @idEntidad
   AND ISNULL(@idSucursal,0) = ISNULL(idSucursal,0)

   -- === INICIO ADICION MODULO CREDITO ===
   IF EXISTS
   (
       SELECT 1
       FROM proc_movimientosCredito mc
       INNER JOIN cat_tipoMovimientoCredito tm
           ON tm.id = mc.idTipoMovimientoCredito AND tm.idEntidad = mc.idEntidad
       WHERE mc.folioEntradaSalidaRelacionado = @idDocumentoReferencia
         AND mc.idEntidad = @idEntidad
         AND tm.clave = 'CARGO'
   )
   BEGIN
       EXEC dbo.sp_ui_creditoReversaCargo
           @folioEntradaSalida = @idDocumentoReferencia,
           @idEntidad = @idEntidad,
           @idSucursal = @idSucursal,
           @idUsuarioAlta = @idUsuarioModifica;
   END
   -- === FIN ADICION MODULO CREDITO ===

  END

        SELECT * FROM proc_movimientosInventarios WHERE folioMovimientoInventario = @folioMovimientoInventario AND idEntidad = @idEntidad;

    END TRY
    BEGIN CATCH
         ROLLBACK TRANSACTION;

  DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        RAISERROR ('Ocurrió un error en el SP. Detalles: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO
