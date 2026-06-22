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
     --declare @stockAntesMovimiento DECIMAL(18, 2) = NULL  
   
 --Select @stockAntesMovimiento = sum( From proc_inventario Where idProductoServicio = @i  
   
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
  

Go

ALTER PROCEDURE [dbo].[sp_in_movimentosInventariosDetalles]
(
    @folioMovimientoInventario INT,
    @idProductoServicio INT,
    @cantidad DECIMAL(16, 4),
    @idUnidadMedida INT,
    @costoUnitario DECIMAL(18, 2) = NULL,
    @precioVentaUnitario DECIMAL(18, 2) = NULL,
    @lote VARCHAR(50) = '',
    @serie VARCHAR(50) = '',
    @numeracion decimal(16,2) = 0,
    @fechaVencimiento DATE = '1900-01-01',
    @comentarios VARCHAR(450) = '',
    @activo BIT,
    @idEntidad INT,
    @idUsuarioModifica INT,
    @idSucursal int = null
)
AS
BEGIN
    BEGIN TRY
        INSERT INTO proc_movimientosInventariosDetalles
        (
            folioMovimientoInventario,
            idProductoServicio,
            cantidad,
            idUnidadMedida,
            costoUnitario,
            precioVentaUnitario,
            lote,
            serie,
            fechaVencimiento,
			numeracion,
            comentarios,
            activo,
            idEntidad,
            fechaAlta,
            idUsuarioAlta,
            idSucursal
        )
        VALUES
        (
            @folioMovimientoInventario,
            @idProductoServicio,
            @cantidad,
            @idUnidadMedida,
            @costoUnitario,
            @precioVentaUnitario,
            @lote,
            @serie,
            @fechaVencimiento,
			@numeracion,  
            @comentarios,
            @activo,
            @idEntidad,
            dbo.fn_GetDateMX(),
            @idUsuarioModifica,
            ISNULL(@idSucursal,0)
        );

		Select * From proc_movimientosInventariosDetalles where folioMovimientoInventario = @folioMovimientoInventario and ISNULL(@idSucursal,0) = idSucursal and idEntidad = @idEntidad
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        RAISERROR ('Ocurrió un error en el SP. Detalles: %s', 16, 1, @ErrorMessage);
    END CATCH
END;

go

ALTER PROCEDURE [dbo].[sp_in_entradasSalidas]
(
	@folioEntradaSalida int,
	@folioMovimientoInventario int,
	@idTipoEntradaSalida int,
	@comentarios varchar(450) = '',
	@activo bit ,
	@idEntidad int ,
	@idUsuarioModifica int,
	@montoTotalTicket decimal (16,4),
	@totalDescuento decimal(16,4),
	@montoSinDescuento decimal(15,3),
	@pagoTotal decimal(16,4),
	@suCambio decimal (16,4),
	@folioCorteCaja int,
	@folioCorteTienda int,
    @idSucursal int = null
)
AS
BEGIN
   
    BEGIN TRY
		IF Exists(	Select 1 From proc_entradasSalidas 
					where folioEntradaSalida = @folioEntradaSalida And 
					folioCorteCaja = @folioCorteCaja And 
					folioCorteTienda = @folioCorteTienda And 
					idEntidad = @idEntidad
				)
			BEGIN
				Raiserror('Folio venta duplicado',16,1)
				return
			END
		ELSE
			BEGIN
			INSERT INTO 
					proc_entradasSalidas
					(
						folioEntradaSalida,
						folioMovimientoInventario,
						idTipoEntradaSalida,
						comentarios,
						activo,
						idEntidad,
						fechaAlta,
						idUsuarioAlta,
						montoTotalTicket,
						pagoTotal,
						suCambio,
						folioCorteCaja,
						folioCorteTienda,
						idEstadoTicket,
						totalDescuento,
						montoSinDescuento,
                        idSucursal
					)
				VALUES 
					(
						@folioEntradaSalida,
						@folioMovimientoInventario,
						@idTipoEntradaSalida,
						@comentarios,
						@activo,
						@idEntidad,
						dbo.fn_GetDateMX(),
						@idUsuarioModifica,
						@montoTotalTicket,
						@pagoTotal,
						@sucambio,
						@folioCorteCaja,
						@folioCorteTienda,
						3, --Concluido
						@totalDescuento,
						@montoSinDescuento,
                        ISNULL(@idSucursal,0)
					);
					SELECT * FROM proc_entradasSalidas where folioEntradaSalida = @folioEntradaSalida And idEntidad = @idEntidad

				
			END
    
	END TRY
    BEGIN CATCH

		Declare @message varchar(max) 

		SELECT @message = 'Error: ' + ERROR_MESSAGE();
		raiserror(@message,16,1)

	END CATCH;
END;

GO

ALTER PROCEDURE [dbo].[sp_in_entradasSalidasDetalles]    
(    
  @folioEntradaSalida int ,    
  @idProductoServicio int ,    
  @cantidad decimal(13, 4),    
  @precioFinal decimal(13, 4),    
  @idUnidadMedida int ,    
  @comentarios varchar(450) = '',    
  @activo bit ,    
  @idEntidad int ,    
  @idUsuarioModifica int,    
  @precio decimal (31,4),    
  @serie varchar(100) = '',    
  @lote varchar(50) = '',    
  @fechaVencimiento DateTime = '19000101',    
  @numeracion decimal (12,3) = 0    ,
  @costo decimal(14,2) = 0,
  @idSucursal int = null
)    
AS    
BEGIN    
    
    BEGIN TRY    
   BEGIN    
    INSERT INTO     
     proc_entradasSalidasDetalles    
     (    
      folioEntradaSalida,    
      idProductoServicio,    
      cantidad,    
      precioFinal,    
      idUnidadMedida,    
      comentarios,    
      activo,    
      idEntidad,    
      fechaAlta,    
      idUsuarioAlta,    
      precio,    
      lote,    
      serie,    
      fechaVencimiento,    
      numeracion    ,
      costo,
      idSucursal
     )    
    VALUES     
     (    
      @folioEntradaSalida,    
      @idProductoServicio,    
      @cantidad,    
      @precioFinal,    
      @idUnidadMedida,    
      @comentarios,    
      @activo,    
      @idEntidad,    
      dbo.fn_GetDateMX(),    
      @idUsuarioModifica,    
      @precio,    
      @lote,    
      @serie,    
      @fechaVencimiento,    
      @numeracion    ,
      @costo,
      ISNULL(@idSucursal,0)
     );    
   END    
        
 END TRY    
    BEGIN CATCH    
        DECLARE @ErrorMessage NVARCHAR(4000);    
        DECLARE @ErrorSeverity INT;    
        DECLARE @ErrorState INT;    
    
        SET @ErrorMessage = ERROR_MESSAGE();    
        SET @ErrorSeverity = ERROR_SEVERITY();    
        SET @ErrorState = ERROR_STATE();    
    
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);    
        RAISERROR ('Ocurrió un error en el SP. Detalles: %s', 16, 1, @ErrorMessage);    
    END CATCH    
END; 
GO


ALTER PROCEDURE [dbo].[sp_in_EntradasSalidasPago]
(
     @folioEntradaSalida int,
	 @idTipoPago int,
	 @montoPago decimal(16,4),
	 @numeroAutorizacion varchar(250),
	 @comentarios varchar(450) = '',
	 @activo bit ,
	 @idEntidad int ,
	 @idUsuarioModifica int,
     @idSucursal int = null
)
AS
BEGIN
   
    BEGIN TRY
		IF Exists
				(
					Select 
                        1 
                    From 
                        proc_entradasSalidaPago 
					where 
                        folioEntradaSalida = @folioEntradaSalida And 
                        idEntidad = @idEntidad And 
                        @idSucursal = @idSucursal And
					    idTipoPago = @idTipoPago And 
                        numeroAutorizacion =@numeroAutorizacion

				)
			BEGIN
				Raiserror('Folio de pago duplicado',16,1)
				return
			END
		ELSE
			BEGIN
			INSERT INTO 
					proc_entradasSalidaPago
					(
						folioEntradaSalida,
						idTipoPago,
						montoPago,
						numeroAutorizacion,
						comentarios,
						activo,
						idEntidad,
						fechaAlta,
						idUsuarioAlta,
                        idSucursal
					)
				VALUES 
					(
						@folioEntradaSalida,
						@idTipoPago,
						@montoPago,
						@numeroAutorizacion,
						@comentarios,
						@activo,
						@idEntidad,
						dbo.fn_GetDateMX(),
						@idUsuarioModifica,
                        ISNULL(@idSucursal,0)
					);
					SELECT * FROM proc_entradasSalidaPago where folioEntradaSalida = @folioEntradaSalida And idEntidad = @idEntidad and idSucursal = ISNULL(@idSucursal,0)
				
			END
    
	END TRY
    BEGIN CATCH

		SELECT 'Error: ' + ERROR_MESSAGE();
	END CATCH;
END;
Go

ALTER PROCEDURE [dbo].[sp_up_inventarioV2]    
(    
    @folioMovimientoInventario INT,    
    @idProductoServicio INT,    
    @idProveedor INT,    
    @cantidad DECIMAL(16, 4),    
    @idUnidadMedida INT,    
    @idTipoMovimientoInventario INT,    
    @lote VARCHAR(50) = '',    
    @serie VARCHAR(50) = '',    
    @numeracion decimal(16,2) = 0,    
    @fechaVencimiento DATE = '19000101',    
    @costoUnitario DECIMAL(18, 2) = NULL,    
    @precioVenta DECIMAL(18, 2) = NULL,    
    @idEntidad INT,    
    @idUsuarioModifica INT    ,
    @idSucursal        INT = NULL
)    
AS    
BEGIN    
    BEGIN TRY    
        DECLARE @afectacion INT;    
    
        -- 1 Obtener la afectación    
        SELECT @afectacion = afectacion    
        FROM cat_tiposMovmientosInventario    
        WHERE id = @idTipoMovimientoInventario;    

		-- ==================
		-- Servicio sin inventario: omite conversión UM, validación y movimiento de stock
		-- ==================
        DECLARE @esServicio BIT = 0;
        SELECT @esServicio = ISNULL(esServicio, 0)
        FROM cat_productosServicios
        WHERE id = @idProductoServicio
          AND idEntidad = @idEntidad;

        IF @esServicio = 1
        BEGIN
            SELECT TOP 0 * FROM inv_inventarioDet;
            RETURN;
        END
		-- ==================
		-- ==================
		-- ==================

		-- === Conversión a UM base del producto (antes de validar/afectar inventario) ===  
        DECLARE @factor DECIMAL(18,8),  
                @idUnidadMedidaBase INT,  
                @cantidadBase DECIMAL(18,8);  
  
        SELECT  
            @idUnidadMedidaBase = f.idUnidadMedidaBase,  
            @factor             = f.factor  
        FROM dbo.fn_FactorUnidadAUnidadBaseProducto(@idEntidad, @idProductoServicio, @idUnidadMedida) f;  
  
        IF @factor IS NULL  
        BEGIN  
            THROW 52000, 'No se pudo calcular factor de conversión hacia unidad base del producto. Revisa configuración de unidades/magnitud o factor por producto (packaging).', 1;  
        END  
  
        SET @cantidadBase = CAST(@cantidad AS DECIMAL(18,8)) * @factor;  
  
        -- Normalizar para que TODO el SP opere en UM base  
        SET @cantidad = CAST(@cantidadBase AS DECIMAL(16,4));  
        SET @idUnidadMedida = @idUnidadMedidaBase;  
    
    -- Tratar cadena vacía como NULL    
    SET @lote = NULLIF(LTRIM(RTRIM(@lote)), '');    
    SET @serie = NULLIF(LTRIM(RTRIM(@serie)), '');    
    SET @idSucursal = ISNULL(@idSucursal, 0); 
    -- Opcional: si usas '1900-01-01' como marcador, conviértelo a NULL    
    IF @fechaVencimiento = '1900-01-01'    
   SET @fechaVencimiento = NULL;    
    
  -- 2 Valida existencia en negativo    
  IF @afectacion < 0    
  BEGIN    
   DECLARE @existenciaDet DECIMAL(16,4);    
   SELECT @existenciaDet = cantidadExistente    
   FROM inv_inventarioDet    
   WHERE idProductoServicio = @idProductoServicio    
    AND (    
     lote  = @lote     
     OR (lote IS NULL AND @lote IS NULL)    
     )    
    AND (    
     serie = @serie    
     OR (serie IS NULL AND @serie IS NULL)    
     )    
    AND (    
     fechaExpira = @fechaVencimiento    
     OR (fechaExpira IS NULL AND @fechaVencimiento IS NULL)    
     )    
    AND numeracion = @numeracion    
    AND idEntidad  = @idEntidad    
    AND ISNULL(idSucursal, 0) = @idSucursal
    
   IF (@existenciaDet IS NULL OR @existenciaDet + (@cantidad * @afectacion) < 0)    
   BEGIN    
    RAISERROR('Inventario insuficiente para el lote/serie especificado.', 16, 1);    
    RETURN;    
   END    
  END    
    
        -- 3 Actualizar o insertar en inv_inventarioDet    
        IF EXISTS (    
            SELECT 1 FROM inv_inventarioDet     
            WHERE idProductoServicio = @idProductoServicio    
    AND (lote  = @lote  OR (lote  IS NULL AND @lote  IS NULL))    
    AND (serie = @serie OR (serie IS NULL AND @serie IS NULL))    
    AND (    
     (fechaExpira    = @fechaVencimiento) 
     OR (fechaExpira    IS NULL AND @fechaVencimiento IS NULL)    
     )    
    AND (numeracion = @numeracion OR (numeracion IS NULL AND @numeracion IS NULL))    
    AND idEntidad = @idEntidad    
    AND ISNULL(idSucursal, 0) = @idSucursal
        )    
        BEGIN    
            UPDATE inv_inventarioDet    
            SET cantidadExistente = ISNULL(cantidadExistente,0) + (@cantidad * @afectacion),    
                costoUnitario = ISNULL(@costoUnitario, costoUnitario),    
                precioVenta = ISNULL(@precioVenta, precioVenta),    
                fechaExpira = ISNULL(@fechaVencimiento, fechaExpira),    
                fechaUltimoMovimiento = dbo.fn_GetDateMX(),    
                idUsuarioModifica = @idUsuarioModifica,    
                fechaModificacion = dbo.fn_GetDateMX()    
            WHERE idProductoServicio = @idProductoServicio    
    AND (lote  = @lote  OR (lote  IS NULL AND @lote  IS NULL))    
    AND (serie = @serie OR (serie IS NULL AND @serie IS NULL))    
    AND (    
     (fechaExpira    = @fechaVencimiento)    
     OR (fechaExpira    IS NULL AND @fechaVencimiento IS NULL)    
     )    
    AND (numeracion = @numeracion OR (numeracion IS NULL AND @numeracion IS NULL))    
    AND idEntidad = @idEntidad    
    AND ISNULL(idSucursal, 0) = @idSucursal
        END    
        ELSE    
        BEGIN    
            INSERT INTO inv_inventarioDet (    
                idProductoServicio,    
                idPersona,    
                serie,    
                cantidadExistente,    
                idUnidadMedida,    
                fechaExpira,    
                lote,    
    numeracion,    
                costoUnitario,    
                precioVenta,    
                fechaUltimoMovimiento,    
                activo,    
                idEntidad,    
                fechaAlta,    
                idUsuarioAlta    ,
                idSucursal

            )    
            VALUES (    
                @idProductoServicio,    
                @idProveedor,    
                @serie,    
               (@cantidad * @afectacion),    
                @idUnidadMedida,    
                @fechaVencimiento,    
                @lote,    
    @numeracion,    
                @costoUnitario,    
                @precioVenta,    
                dbo.fn_GetDateMX(),    
                1,    
                @idEntidad,    
                dbo.fn_GetDateMX(),    
                @idUsuarioModifica    ,
                 @idSucursal  
            );    
        END    
            
      
    
    
        -- 4 Actualizar o insertar en inv_inventario    
        IF EXISTS (    
            SELECT 1 FROM inv_inventario     
            WHERE idProductoServicio = @idProductoServicio    
              AND idEntidad = @idEntidad    
              AND ISNULL(idSucursal, 0) = @idSucursal
        )    
        BEGIN    
            UPDATE inv_inventario    
            SET cantidadExistente = ISNULL(cantidadExistente,0) + (@cantidad * @afectacion),    
                costoUnitario = ISNULL(@costoUnitario, costoUnitario),    
                precioVenta = ISNULL(@precioVenta, precioVenta),    
                fechaUltimoMovimiento = dbo.fn_GetDateMX(),    
                idUsuarioModifica = @idUsuarioModifica,    
                fechaModificacion = dbo.fn_GetDateMX()    
            WHERE idProductoServicio = @idProductoServicio    
              AND idEntidad = @idEntidad
              AND ISNULL(idSucursal, 0) = @idSucursal
        END    
        ELSE    
        BEGIN    
            INSERT INTO inv_inventario (    
                idProductoServicio,    
                cantidadExistente,    
                idUnidadMedida,    
                costoUnitario,    
                precioVenta,    
                fechaUltimoMovimiento,    
                activo,    
                idEntidad,    
                fechaAlta,    
                idUsuarioAlta,
                idSucursal

            )    
            VALUES (    
                @idProductoServicio,    
                (@cantidad * @afectacion),    
                @idUnidadMedida,    
                @costoUnitario,    
                @precioVenta,    
                dbo.fn_GetDateMX(),    
                1,    
                @idEntidad,    
                dbo.fn_GetDateMX(),    
                @idUsuarioModifica    ,
                @idSucursal
            );    
        END    
    
        -- 5 Opcional: retornar inventario actualizado (detallado y general)    
        SELECT * FROM inv_inventarioDet    
        WHERE idProductoServicio = @idProductoServicio    
  AND (lote  = @lote  OR (lote  IS NULL AND @lote  IS NULL))    
  AND (serie = @serie OR (serie IS NULL AND @serie IS NULL))    
  AND (    
   (fechaExpira    = @fechaVencimiento)    
   OR (fechaExpira    IS NULL AND @fechaVencimiento IS NULL)    
   )    
  AND (numeracion = @numeracion OR (numeracion IS NULL AND @numeracion IS NULL))    
  AND idEntidad = @idEntidad    
  AND ISNULL(idSucursal, 0) = @idSucursal
    
    END TRY    
    BEGIN CATCH    
        DECLARE @ErrorMessage NVARCHAR(4000);    
        DECLARE @ErrorSeverity INT;    
        DECLARE @ErrorState INT;    
    
   SET @ErrorMessage = ERROR_MESSAGE();    
        SET @ErrorSeverity = ERROR_SEVERITY();    
        SET @ErrorState = ERROR_STATE();    
    
        --RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);    
        RAISERROR ('Ocurrió un error en el SP [sp_up_inventarioV2]: %s', 16, 1, @ErrorMessage);    
    END CATCH    
END 







Select * From movimienod