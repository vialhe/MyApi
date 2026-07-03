-- ============================================================================
-- MODULO: CREDITO / FIADO EN POS
-- Fase: SETUP DE CREDITO PARA UNA ENTIDAD NUEVA (autocontenido)
--
-- Por que existe este SP: cat_tipoMovimientoCredito y cat_configuracionCredito
-- son catalogos idEntidad-scoped. El seed original (dentro de
-- 01_create_tables_credito.sql) solo sembro las entidades que YA existian al
-- momento de correr el script de tablas. Cada entidad nueva que se cree despues
-- necesita este mismo seed, y a diferencia de los catalogos de agenda en
-- "QUERY CREAR USUARIOS POS v2.sql" (que se copian con
-- INSERT...SELECT...WHERE idEntidad=@idEntidadCopy), aqui NO copiamos de
-- ninguna entidad "molde": los valores van fijos en el propio SP. Si la
-- entidad copia llegara a no existir o a no tener esas filas, ese patron falla
-- en silencio (0 filas, sin error); este SP no tiene ese riesgo porque no
-- depende de que exista nada mas que la propia entidad nueva.
--
-- Idempotente: cada bloque valida IF NOT EXISTS antes de insertar, igual que
-- el resto de "QUERY CREAR USUARIOS POS v2.sql", asi que es seguro volver a
-- ejecutarlo sobre una entidad que ya tiene algunas de estas filas.
--
-- Uso sugerido: agregar una linea mas dentro de tu script de alta de entidad
-- (justo despues de validar que @idEntidad existe en sys_entidades):
--
--   EXEC dbo.sp_ui_creditoSetupEntidad @idEntidad = @idEntidad, @idUsuarioAlta = @idUsuarioSistema;
--
-- No se modifico "QUERY CREAR USUARIOS POS v2.sql" -- queda a tu criterio
-- donde pegar esa linea.
-- ============================================================================

CREATE PROCEDURE [dbo].[sp_ui_creditoSetupEntidad]
(
	@idEntidad int,
	@idUsuarioAlta int
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	IF NOT EXISTS (SELECT 1 FROM [dbo].[sys_entidades] WHERE [id] = @idEntidad)
	BEGIN
		RAISERROR('La entidad %d no existe en sys_entidades.',16,1,@idEntidad);
		RETURN;
	END

	BEGIN TRY
		BEGIN TRAN;

		-- ------------------------------------------------------------------
		-- 1) cat_tipoMovimientoCredito: 5 filas fijas (no se copian de nadie)
		-- ------------------------------------------------------------------
		IF NOT EXISTS (SELECT 1 FROM [dbo].[cat_tipoMovimientoCredito] WHERE [idEntidad] = @idEntidad AND [clave] = 'CARGO')
			INSERT INTO [dbo].[cat_tipoMovimientoCredito] ([clave],[descripcion],[signo],[activo],[idEntidad],[fechaAlta],[idUsuarioAlta])
			VALUES ('CARGO','Cargo (venta a credito)',1,1,@idEntidad,dbo.fn_GetDateMX(),@idUsuarioAlta);

		IF NOT EXISTS (SELECT 1 FROM [dbo].[cat_tipoMovimientoCredito] WHERE [idEntidad] = @idEntidad AND [clave] = 'ABONO')
			INSERT INTO [dbo].[cat_tipoMovimientoCredito] ([clave],[descripcion],[signo],[activo],[idEntidad],[fechaAlta],[idUsuarioAlta])
			VALUES ('ABONO','Abono (pago parcial de saldo)',-1,1,@idEntidad,dbo.fn_GetDateMX(),@idUsuarioAlta);

		IF NOT EXISTS (SELECT 1 FROM [dbo].[cat_tipoMovimientoCredito] WHERE [idEntidad] = @idEntidad AND [clave] = 'LIQUIDACION')
			INSERT INTO [dbo].[cat_tipoMovimientoCredito] ([clave],[descripcion],[signo],[activo],[idEntidad],[fechaAlta],[idUsuarioAlta])
			VALUES ('LIQUIDACION','Liquidacion (pago total del saldo)',-1,1,@idEntidad,dbo.fn_GetDateMX(),@idUsuarioAlta);

		IF NOT EXISTS (SELECT 1 FROM [dbo].[cat_tipoMovimientoCredito] WHERE [idEntidad] = @idEntidad AND [clave] = 'AJUSTE')
			INSERT INTO [dbo].[cat_tipoMovimientoCredito] ([clave],[descripcion],[signo],[activo],[idEntidad],[fechaAlta],[idUsuarioAlta])
			VALUES ('AJUSTE','Ajuste manual (condonacion / correccion)',NULL,1,@idEntidad,dbo.fn_GetDateMX(),@idUsuarioAlta);

		IF NOT EXISTS (SELECT 1 FROM [dbo].[cat_tipoMovimientoCredito] WHERE [idEntidad] = @idEntidad AND [clave] = 'REVERSA_CARGO')
			INSERT INTO [dbo].[cat_tipoMovimientoCredito] ([clave],[descripcion],[signo],[activo],[idEntidad],[fechaAlta],[idUsuarioAlta])
			VALUES ('REVERSA_CARGO','Reversa de cargo (cancelacion/devolucion)',-1,1,@idEntidad,dbo.fn_GetDateMX(),@idUsuarioAlta);

		-- ------------------------------------------------------------------
		-- 2) cat_configuracionCredito: fila inicial inerte (recargo en 0).
		-- Solo se inserta si la entidad no tiene ya una configuracion activa
		-- (no pisa una configuracion real si el SP se vuelve a correr).
		-- ------------------------------------------------------------------
		IF NOT EXISTS (SELECT 1 FROM [dbo].[cat_configuracionCredito] WHERE [idEntidad] = @idEntidad AND [vigenteHasta] IS NULL)
			INSERT INTO [dbo].[cat_configuracionCredito]
			(
				[tipoValorRecargo],[nivelAplicacion],[valorRecargo],[diasVencimientoCargo],
				[limiteCreditoDefaultExpress],[vigenteDesde],[vigenteHasta],[activo],[idEntidad],
				[fechaAlta],[idUsuarioAlta]
			)
			VALUES
			(
				'Porcentaje','Carrito',0,15,500,dbo.fn_GetDateMX(),NULL,1,@idEntidad,
				dbo.fn_GetDateMX(),@idUsuarioAlta
			);

		-- ------------------------------------------------------------------
		-- 3) cat_tiposPago: alta de "Credito" como forma de pago
		-- ------------------------------------------------------------------
		IF NOT EXISTS (SELECT 1 FROM [dbo].[cat_tiposPago] WHERE [idEntidad] = @idEntidad AND [descripcion] = 'Credito')
			INSERT INTO [dbo].[cat_tiposPago] ([descripcion],[comentarios],[activo],[idEntidad],[fechaAlta],[idUsuarioAlta])
			VALUES ('Credito','Pago mediante credito/fiado del cliente',1,@idEntidad,dbo.fn_GetDateMX(),@idUsuarioAlta);

		COMMIT TRAN;

		SELECT 'cat_tipoMovimientoCredito' AS bloque, * FROM [dbo].[cat_tipoMovimientoCredito] WHERE [idEntidad] = @idEntidad;
		SELECT 'cat_configuracionCredito' AS bloque, * FROM [dbo].[cat_configuracionCredito] WHERE [idEntidad] = @idEntidad AND [vigenteHasta] IS NULL;
		SELECT 'cat_tiposPago' AS bloque, * FROM [dbo].[cat_tiposPago] WHERE [idEntidad] = @idEntidad AND [descripcion] = 'Credito';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		DECLARE @ErrorMessage varchar(4000) = ERROR_MESSAGE();
		RAISERROR('Error en sp_ui_creditoSetupEntidad: %s',16,1,@ErrorMessage);
	END CATCH
END
GO
