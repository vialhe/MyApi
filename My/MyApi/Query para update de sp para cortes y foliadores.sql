ALTER PROCEDURE [dbo].[sp_in_corteCaja]
(
    @folioCorteCaja int,
    @folioCorteTienda int,
	@idCaja int,
	@idEstatusCorte int,
	@idUsuarioIniciaCorte int,
	@fechaInicio datetime,
	@idUsuarioCierraCorte int = null,
	@fechaFin datetime = null,
	@saldoInicial decimal (18,6) = 0,
	@saldoFinal decimal (18,6) = null,
	@Faltante decimal (18,6) = 0,
	@Sobrante decimal (18,6) = 0,
	@montoSistema decimal (18,6) = 0, 
	@comentarios varchar(450) = '',
	@activo bit,
	@idEntidad int ,
	@idUsuarioModifica int ,
	@idSucursal int = NULL
)
AS
BEGIN
    BEGIN TRY
		IF Exists(Select 1 From proc_corteCaja where folioCorteCaja = @folioCorteCaja And idEntidad = @idEntidad and ISNULL(idSucursal,0) = ISNULL(@idSucursal,0))
			BEGIN
				Raiserror('Folio corte caja duplicado',16,1)
				return
			END
		ELSE
			BEGIN
			INSERT INTO 
					proc_corteCaja
					(
						folioCorteCaja,
						folioCorteTienda,
						idCaja,
						idEstatusCorte,
						idUsuarioIniciaCorte,
						fechaInicio,
						idUsuarioCierraCorte,
						fechaFin,
						saldoInicial,
						saldoFinal,
						Faltante,
						Sobrante,
						montoSistema,
						comentarios,
						activo,
						idEntidad,
						fechaAlta,
						idUsuarioAlta,
						idSucursal
					)
				VALUES 
					(
						@folioCorteCaja,
						@folioCorteTienda,
						@idcaja,
						@idEstatusCorte,
						@idUsuarioIniciaCorte,
						@fechaInicio,
						@idUsuarioCierraCorte,
						@fechaFin,
						@saldoInicial,
						@saldoFinal,
						@Faltante,
						@Sobrante,
						@montoSistema,
						@comentarios,
						@activo,
						@idEntidad,
						dbo.fn_GetDateMX(),
						@idUsuarioModifica,
						ISNULL(@idSucursal,0)
					);
					SELECT * FROM proc_corteCaja where folioCorteCaja = @folioCorteCaja And idEntidad = @idEntidad And ISNULL(idSucursal,0) = ISNULL(@idSucursal,0)
			END
    
	END TRY
    BEGIN CATCH
		Declare @message varchar(max) 

		SELECT @message = 'Error: ' + ERROR_MESSAGE();
		raiserror(@message,16,1)

	END CATCH;
END;


GO

ALTER PROCEDURE [dbo].[sp_in_corteTienda]
(
    @folioCorteTienda int,
	@idEstatusCorte int,
	@idUsuarioIniciaCorte int,
	@fechaInicio datetime,
	@idUsuarioCierraCorte int = null,
	@fechaFin datetime = null,
	@saldoInicial decimal (18,6) = 0,
	@saldoFinal decimal (18,6) = null,
	@Faltante decimal (18,6) = 0,
	@Sobrante decimal (18,6) = 0,
	@montoSistema decimal (18,6) = 0, 
	@comentarios varchar(450) = '',
	@activo bit,
	@idEntidad int ,
	@idUsuarioModifica int ,
	@idSucursal int = null
)
AS
BEGIN
   
    BEGIN TRY
		IF Exists(Select 1 From proc_corteTienda where folioCorteTienda = @folioCorteTienda And idEntidad = @idEntidad And ISNULL(idSucursal,0) = ISNULL(@idSucursal,0))
			BEGIN
				Raiserror('Folio venta duplicado',16,1)
				return
			END
		ELSE
			BEGIN
			INSERT INTO 
					proc_corteTienda
					(
						folioCorteTienda,
						idEstatusCorte,
						idUsuarioIniciaCorte,
						fechaInicio,
						idUsuarioCierraCorte,
						fechaFin,
						saldoInicial,
						saldoFinal,
						Faltante,
						Sobrante,
						montoSistema,
						comentarios,
						activo,
						idEntidad,
						fechaAlta,
						idUsuarioAlta,
						idSucursal
					)
				VALUES 
					(
						@folioCorteTienda,
						@idEstatusCorte,
						@idUsuarioIniciaCorte,
						@fechaInicio,
						@idUsuarioCierraCorte,
						@fechaFin,
						@saldoInicial,
						@saldoFinal,
						@Faltante,
						@Sobrante,
						@montoSistema,
						@comentarios,
						@activo,
						@idEntidad,
						dbo.fn_GetDateMX(),
						@idUsuarioModifica,
						ISNULL(@idSucursal,0)
					);
					SELECT * FROM proc_corteTienda where folioCorteTienda = @folioCorteTienda And idEntidad = @idEntidad ANd ISNULL(@idSucursal,0) = ISNULL(idSucursal,0)

				
			END
    
	END TRY
    BEGIN CATCH
		Declare @message varchar(max) 

		SELECT @message = 'Error: ' + ERROR_MESSAGE();
		raiserror(@message,16,1)

	END CATCH;
END;

GO

ALTER PROCEDURE [dbo].[proc_CierreCorteCaja]
  @idUsuario INT,
  @idCaja INT,
  @saldoFinal DECIMAL(18,6),
  @idEntidad INT,
  @folioCorteCaja INT ,
  @folioCorteTienda INT ,
  @comentarios varchar (450) = '',
  @idSucursal int = 0
AS
BEGIN
	BEGIN TRY
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @FechaAlta datetime;
		SET @FechaAlta = dbo.fn_GetDateMX()

	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Validaciones
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
			IF EXISTS
			(
				SELECT 1
				FROM 
					proc_corteCaja
				WHERE 
					idEstatusCorte = 1 
					AND idCaja = @idCaja
					AND activo = 1
					AND idEntidad = @idEntidad
					AND folioCorteCaja = @folioCorteCaja
					AND folioCorteTienda = @folioCorteTienda
					AND ISNULL(idSucursal,0)= ISNULL(@idSucursal,0)
			)
			BEGIN
				RAISERROR('El corte ya está cerrado, no se puede cerrar nuevamente.',16,1)
			END

			IF @saldoFinal < 0
			BEGIN
				RAISERROR('No se puede cerrar un corte con saldo final negativo.', 16, 1)
				RETURN
			END

		
		
		Declare		
			@SaldoSistema decimal (18,6)

		Select
			@SaldoSistema = ISNULL(SUM(montoTotalTicket),0)
		From
			proc_entradasSalidas
		Where 
			folioCorteCaja = @folioCorteCaja 
			AND folioCorteTienda = @folioCorteTienda
			AND ISNULL(idSucursal,0)= ISNULL(@idSucursal,0)

		/*Le suma el saldo inicial*/
		Select
			@SaldoSistema  = @SaldoSistema + saldoInicial
		From
			proc_corteCaja
		Where 
			folioCorteCaja = @folioCorteCaja 
			AND folioCorteTienda = @folioCorteTienda
			AND ISNULL(idSucursal,0)= ISNULL(@idSucursal,0)
		UPDATE
			proc_corteCaja
		SET
			idEstatusCorte = 1
			,idUsuarioCierraCorte = @idUsuario
			,fechaFin = @FechaAlta
			,saldoFinal = @saldoFinal
			,Faltante = CASE WHEN @saldoFinal >= @SaldoSistema THEN 0 ELSE ABS(@saldoFinal - @SaldoSistema) END
			,Sobrante = CASE WHEN @saldoFinal <= @SaldoSistema THEN 0 ELSE ABS(@saldoFinal - @SaldoSistema) END
			,montoSistema = @SaldoSistema
			,comentarios = @comentarios
			,fechaModificacion =@FechaAlta
			,idUsuarioModifica = @idUsuario
		WHERE
			folioCorteCaja = @folioCorteCaja
			AND folioCorteTienda = @folioCorteTienda
			AND idEntidad = @idEntidad
			AND ISNULL(idSucursal,0)= ISNULL(@idSucursal,0)

	END TRY
	BEGIN CATCH
		Declare @message varchar(max) 

		SELECT @message = 'Error: ' + ERROR_MESSAGE();
		raiserror(@message,16,1)
	END CATCH
END
GO

ALTER PROCEDURE [dbo].[proc_CierreCorteTienda]
  @idUsuario INT,
  @saldoFinal DECIMAL(18,6),
  @idEntidad INT,
  @folioCorteTienda INT ,
  @idSucursal int = 0
AS
BEGIN
	BEGIN TRY
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @FechaAlta datetime;
		SET @FechaAlta = dbo.fn_GetDateMX()

	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Validaciones
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
			IF EXISTS
			(
				SELECT 1
				FROM 
					proc_corteCaja
				WHERE 
					idEstatusCorte = 0 
					AND activo = 1
					AND idEntidad = @idEntidad
					AND folioCorteTienda = @folioCorteTienda
					AND ISNULL(idSucursal,0)= ISNULL(@idSucursal,0)
					
			)
			BEGIN
				RAISERROR('Es necesario cerrar TODOS los corte de caja antes de cerrar la tienda',16,1)
			END

			IF EXISTS
			(
				SELECT 1
				FROM 
					proc_corteTienda
				WHERE 
					idEstatusCorte = 1 
					AND activo = 1
					AND idEntidad = @idEntidad
					AND folioCorteTienda = @folioCorteTienda
					AND ISNULL(idSucursal,0)= ISNULL(@idSucursal,0)

			)
			BEGIN
				RAISERROR('La tienda ya está cerrada, no se puede cerrar nuevamente.',16,1)
			END

			IF @saldoFinal < 0
			BEGIN
				RAISERROR('No se puede cerrar la tienda con saldo final negativo.', 16, 1)
				RETURN
			END
		
		Declare 
			@SaldoSistema decimal (18,6)

		Select
			@SaldoSistema = ISNULL(SUM(montoTotalTicket),0)
		From
			proc_entradasSalidas
		Where 
			folioCorteTienda = @folioCorteTienda
			AND idEstadoTicket = 1
			AND idEntidad = @idEntidad
			AND ISNULL(idSucursal,0)= ISNULL(@idSucursal,0)


		/*Le suma el saldo inicial*/
		Select
			@SaldoSistema  = @SaldoSistema + saldoInicial
		From
			proc_corteTienda
		Where 
			folioCorteTienda = @folioCorteTienda
			AND idEntidad = @idEntidad
			AND ISNULL(idSucursal,0)= ISNULL(@idSucursal,0)



		UPDATE
			proc_corteTienda
		SET
			idEstatusCorte = 1
			,idUsuarioCierraCorte = @idUsuario
			,fechaFin = @FechaAlta
			,saldoFinal = @saldoFinal
			,Faltante = CASE WHEN @saldoFinal >= @SaldoSistema THEN 0 ELSE ABS(@saldoFinal - @SaldoSistema) END
			,Sobrante = CASE WHEN @saldoFinal <= @SaldoSistema THEN 0 ELSE ABS(@saldoFinal - @SaldoSistema) END
			,montoSistema = @SaldoSistema
			,comentarios = ''
			,fechaModificacion =@FechaAlta
			,idUsuarioModifica = @idUsuario
		WHERE
			folioCorteTienda = @folioCorteTienda
			AND idEntidad = @idEntidad
			AND ISNULL(idSucursal,0)= ISNULL(@idSucursal,0)

	END TRY
	BEGIN CATCH
		Declare @message varchar(max) 

		SELECT @message = 'Error: ' + ERROR_MESSAGE();
		raiserror(@message,16,1)
	END CATCH
END

GO

ALTER PROCEDURE [dbo].[sp_proc_generaFolio]  
(  
	@idFolio int ,  
	@idEntidad int,  
	@idUsuarioModifica int,
	@idSucursal int = 0
)  
AS  
BEGIN  
 -- Declara variables  
	Declare @folio Varchar(30)  
     
    BEGIN TRY  
		IF(@idFolio > 0 and @idFolio is not null)  
		BEGIN  
	
			If Not Exists( 
				Select 1 
				From sys_foliosContador 
				where idFolio=@idFolio 
				and idEntidad = @idEntidad 
				and ISNULL(@idSucursal,0) = ISNULL(idSucursal,0) 
			)
			BEGIN	
				Insert into sys_foliosContador (idFolio,contador,activo,idEntidad,fechaAlta,idUsuarioAlta,idSucursal)
				Select @idFolio,0,1,@idEntidad,dbo.fn_GetDateMX(),@idUsuarioModifica, @idSucursal
			END

			Update sys_foliosContador   
			Set   
				contador = contador + 1,  
				idUsuarioModifica = @idUsuarioModifica,  
				fechaModificacion = dbo.fn_GetDateMX()
			Output  
				RIGHT('000000' + Cast(inserted.contador as varchar(12)), 13) AS NuevoFolio  
			Where   
				idFolio = @idFolio   
				And idEntidad =  @idEntidad  
				And  ISNULL(@idSucursal,0) = ISNULL(idSucursal,0)
		END  
     
      
	END TRY  
    BEGIN CATCH  
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

			Raiserror(@ErrorMessage, @ErrorSeverity, @ErrorState);
 END CATCH  
END 

GO

ALTER PROCEDURE [dbo].[sp_se_corteCaja]
	@idUsuarioIniciaCorte int,
	@idEntidad int,
    @idSucursal int = null
As
Begin
		
	SELECT 
		a.folioCorteTienda,
		b.folioCorteCaja,
		b.idUsuarioIniciaCorte,
		b.saldoInicial,
		b.fechaInicio,
		b.fechaFin
	From
		proc_corteTienda a
		JOIN proc_corteCaja b
			On a.folioCorteTienda = b.folioCorteTienda
			And a.idEntidad =  b.idEntidad
	Where
		b.fechaFin is null
		and b.idUsuarioIniciaCorte = @idUsuarioIniciaCorte
		and b.idEntidad =  @idEntidad
		AND (@idSucursal IS NULL OR b.idSucursal = @idSucursal)
		AND (@idSucursal IS NULL OR a.idSucursal = @idSucursal)
End

GO

ALTER PROCEDURE [dbo].[proc_IniciaCorteCaja]
  @idUsuario INT,
  @idCaja INT,
  @saldoInicial DECIMAL(18,6),
  @idEntidad INT,
  @folioCorteCaja INT = null,
  @folioCorteTienda INT = null,
  @idSucursal int = NULL
AS
BEGIN
	BEGIN TRY
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @FechaAlta datetime2(0) =
		CONVERT(datetime2(0), SYSDATETIMEOFFSET() AT TIME ZONE 'Mountain Standard Time (Mexico)');

		-- Asigna como siempre caja 0 por si alguien trae la version anterior, no deberia pero es para no romper productivo.
		set @idCaja = 0
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Define el siguiente corte a abrir
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
			IF @idCaja = 0
			BEGIN
				SELECT @idCaja = ISNULL(MAX(idCaja), 0) + 1
				FROM proc_corteCaja
				WHERE idEntidad = @idEntidad
				  AND idEstatusCorte = 0  -- solo entre cortes abiertos
				  AND activo = 1
				  AND ISNULL(idSucursal,0) = ISNULL(@idSucursal,0)
			END
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Buscar si ya hay un corte caja abierto.
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
			IF EXISTS
			(
				SELECT 1
				FROM 
					proc_corteCaja
				WHERE 
					idEstatusCorte = 0 -- Abierto
					--AND idCaja = @idCaja
					AND idUsuarioAlta = @idUsuario
					AND activo = 1
					AND idEntidad = @idEntidad
					AND ISNULL(idSucursal,0) = ISNULL(@idSucursal,0)

			)
			BEGIN
				RAISERROR('Ya existe un corte abierto en esta caja',16,1)
				RETURN;
			END
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Buscar si ya hay un corte tienda abierto
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
			SELECT TOP 1 
				--case when @folioCorteTienda is null Then folioCorteTienda else @folioCorteTienda end
				@folioCorteTienda = folioCorteTienda
			FROM 
				proc_corteTienda
			WHERE 
				idEstatusCorte = 0 -- Abierto
				AND activo = 1
				AND idEntidad = @idEntidad
				AND ISNULL(idSucursal,0) = ISNULL(@idSucursal,0)

			ORDER BY 
				fechaInicio DESC;
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Valida si es necesario abrir tienda
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
		IF ISNULL(@folioCorteTienda,0) = 0
		BEGIN
			-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
			-- Abre tienda
			-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------

			CREATE TABLE #FolioTienda (folio INT);

			INSERT INTO #FolioTienda
			EXEC sp_proc_generaFolio 6, @idEntidad, @idUsuario, @idSucursal;

			SELECT @folioCorteTienda = folio FROM #FolioTienda;

			DROP TABLE #FolioTienda;

			Exec sp_in_corteTienda
				@folioCorteTienda
				,0 --Estatus abierto
				,@idUsuario
				,@FechaAlta
				,null
				,null
				,@saldoInicial
				,null
				,null
				,null
				,null
				,null
				,1
				,@idEntidad
				,@idUsuario
				,@idSucursal
		END
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- valida corte de caja
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------

		IF ISNULL(@folioCorteCaja,0) = 0
		Begin 
			
			IF @idCaja = 0
			SELECT @idCaja = ISNULL(MAX(idCaja), 0) + 1
			FROM proc_corteCaja
			WHERE idEntidad = @idEntidad AND idEstatusCorte = 0;

			CREATE TABLE #FolioCaja (folio INT);

			INSERT INTO #FolioCaja
			EXEC sp_proc_generaFolio 7, @idEntidad, @idUsuario, @idSucursal;

			SELECT @folioCorteCaja = folio FROM #FolioCaja;

			DROP TABLE #FolioCaja;
			-----------------------------------------------------------------------------------------------------------------------------------------------------------------
			-- Abre la caja
			-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
			Exec sp_in_corteCaja
			@folioCorteCaja
			,@folioCorteTienda
			,@idCaja
			,0 --Estatus abierto
			,@idUsuario
			,@FechaAlta
			,null
			,null
			,@saldoInicial
			,null
			,null
			,null
			,null
			,null
			,1
			,@idEntidad
			,@idUsuario
			,@idSucursal
		End
			--Select @folioCorteCaja,@folioCorteTienda,@idCaja,@idUsuario
		
	END TRY
	BEGIN CATCH
		Declare @message varchar(max) 

		SELECT @message = 'Error: ' + ERROR_MESSAGE();
		raiserror(@message,16,1)
	END CATCH
END
GO

exec [sp_se_corteTienda] 10007,null,'20260601','20260626',null
GO


ALTER PROC [dbo].[sp_se_corteTienda]
(
--Declare
    @idEntidad INT,
    @idUsuarioIniciaCorte INT = NULL,
    @fechaInicio DATETIME = NULL,
    @fechaFin DATETIME = NULL,
    @idSucursal int = null
)
AS
BEGIN
    SET NOCOUNT ON;
	Select @idSucursal = Case WHen @idSucursal = 0 Then null Else @idSucursal End
    --Select @idEntidad = 10007 , @fechaInicio = '20260619', @fechaFin = '20260619 23:59:59', @idUsuarioIniciaCorte = 80
    ;WITH CorteBase AS
    (
        SELECT
            a.folioCorteTienda,
            b.idEstatusCorte,
            b.folioCorteCaja,
            b.idUsuarioIniciaCorte,
            ISNULL(pers.nombre, '') + ' ' + 
            ISNULL(pers.apellidoPaterno, '') + ' ' + 
            ISNULL(pers.apellidoMaterno, '') AS Nombre,
            b.saldoInicial AS SaldoInicialCaja,
            a.saldoInicial AS SaldoInicialTienda,
            b.fechaInicio AS FechaInicioCaja,
            b.fechaFin AS FechaFinCaja,
            ISNULL(b.idCaja, 0) AS caja,
            ISNULL(b.saldoFinal, 0) AS saldoFinalCaja,
            ISNULL(b.comentarios, 0) AS comentarios,
            a.idEntidad
        FROM proc_corteTienda a
        LEFT JOIN proc_corteCaja b
            ON  a.folioCorteTienda = b.folioCorteTienda
            AND a.idEntidad = b.idEntidad
             AND (@idSucursal IS NULL OR b.idSucursal = @idSucursal)
        LEFT JOIN sys_usuarios us
            ON us.id = b.idUsuarioIniciaCorte
        LEFT JOIN cat_personas pers
            ON pers.id = us.idPersona
        WHERE a.idEntidad = @idEntidad
          AND (@idSucursal IS NULL OR a.idSucursal = @idSucursal)
          AND (
                @idUsuarioIniciaCorte IS NULL
                OR b.idUsuarioIniciaCorte = @idUsuarioIniciaCorte
              )
          AND (
                @fechaInicio IS NULL
                OR b.fechaInicio >= @fechaInicio
              )
          AND (
                @fechaFin IS NULL
                OR b.fechaInicio < DATEADD(DAY, 1, CAST(@fechaFin AS DATE))
              )
    ),

    ------------------------------------------------------------
    -- MOVIMIENTOS POS / TICKETS
    ------------------------------------------------------------
    MovimientosPOS AS
    (
        SELECT
            ticketH.folioCorteTienda,
            ticketH.folioCorteCaja,
            ticketH.idEntidad,
            ISNULL(ticketH.folioEntradaSalida, 0) AS folioEntradaSalida,
            ISNULL(CAST(ticketH.montoTotalTicket AS DECIMAL(18,2)), 0) AS montoTotalTicket,
            ISNULL(CAST(ticketP.montoPago AS DECIMAL(18,2)), 0) AS montoPago,
            ISNULL(catPago.descripcion, 'NA') AS formaPago,
            ISNULL(catPago.id, 0) AS idFormaPago
        FROM proc_entradasSalidas ticketH
        LEFT JOIN proc_entradasSalidaPago ticketP
            ON  ticketP.folioEntradaSalida = ticketH.folioEntradaSalida
            AND ticketP.idEntidad = ticketH.idEntidad
        LEFT JOIN cat_tiposPago catPago
            ON catPago.id = ticketP.idTipoPago
        WHERE ticketH.idEntidad = @idEntidad
          AND ticketH.idEstadoTicket = 3
          AND (@idSucursal IS NULL OR ticketH.idSucursal = @idSucursal)
    ),

    ------------------------------------------------------------
    -- MOVIMIENTOS AGENDA / PAGOS APLICADOS
    ------------------------------------------------------------
    MovimientosAgenda AS
    (
        SELECT
            ap.folioCorteTienda,
            ap.folioCorteCaja,
            ap.idEntidad,
            0 AS folioEntradaSalida,
            ISNULL(CAST(ap.montoTotal AS DECIMAL(18,2)), 0) AS montoTotalTicket,
            ISNULL(CAST(apd.montoPago AS DECIMAL(18,2)), 0) AS montoPago,
            ISNULL(catPago.descripcion, 'NA') AS formaPago,
            ISNULL(catPago.id, 0) AS idFormaPago
        FROM proc_agendaPago ap
        INNER JOIN proc_agendaPagoDetalle apd
            ON  apd.folioAgendaPago = ap.folioAgendaPago
            AND apd.idEntidad = ap.idEntidad
        INNER JOIN cat_estatusPagoAgenda est
            ON  est.idEstatusPagoAgenda = ap.idEstatusPagoAgenda
            AND est.idEntidad = ap.idEntidad
            AND est.clave = 'APLICADO'
        LEFT JOIN cat_tiposPago catPago
            ON catPago.id = apd.idTipoPago
        WHERE ap.idEntidad = @idEntidad
          AND ap.activo = 1
          AND apd.activo = 1
          AND (@idSucursal IS NULL OR ap.idSucursal = @idSucursal)
    ),

    ------------------------------------------------------------
    -- MOVIMIENTOS UNIFICADOS
    ------------------------------------------------------------
    Movimientos AS
    (
        SELECT
            folioCorteTienda,
            folioCorteCaja,
            idEntidad,
            folioEntradaSalida,
            montoTotalTicket,
            montoPago,
            formaPago,
            idFormaPago
        FROM MovimientosPOS

        UNION ALL

        SELECT
            folioCorteTienda,
            folioCorteCaja,
            idEntidad,
            folioEntradaSalida,
            montoTotalTicket,
            montoPago,
            formaPago,
            idFormaPago
        FROM MovimientosAgenda
    )

    ------------------------------------------------------------
    -- RESULTADO FINAL
    ------------------------------------------------------------
    SELECT
        cb.folioCorteTienda,
        cb.idEstatusCorte,
        cb.folioCorteCaja,
        cb.idUsuarioIniciaCorte,
        cb.Nombre,
        cb.SaldoInicialCaja,
        cb.SaldoInicialTienda,
        cb.FechaInicioCaja,
        cb.FechaFinCaja,
        ISNULL(mv.folioEntradaSalida, 0) AS folioEntradaSalida,
        ISNULL(mv.montoTotalTicket, 0) AS montoTotalTicket,
        ISNULL(mv.montoPago, 0) AS montoPago,
        ISNULL(mv.formaPago, 'NA') AS formaPago,
        ISNULL(mv.idFormaPago, 0) AS idFormaPago,
        cb.caja,
        cb.saldoFinalCaja,
        cb.comentarios
    FROM CorteBase cb
    LEFT JOIN Movimientos mv
        ON  mv.folioCorteTienda = cb.folioCorteTienda
        AND mv.folioCorteCaja = cb.folioCorteCaja
        AND mv.idEntidad = cb.idEntidad
    ORDER BY
        cb.idEstatusCorte,
        cb.FechaInicioCaja DESC;

END;
