  
CREATE PROCEDURE [dbo].[sp_up_inventarioV2]  
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
    @idUsuarioModifica INT  
)  
AS  
BEGIN  
    BEGIN TRY  
        DECLARE @afectacion INT;  
  
        -- 1 Obtener la afectación  
        SELECT @afectacion = afectacion  
        FROM cat_tiposMovmientosInventario  
        WHERE id = @idTipoMovimientoInventario;  
  
    -- Tratar cadena vacía como NULL  
    SET @lote = NULLIF(LTRIM(RTRIM(@lote)), '');  
    SET @serie = NULLIF(LTRIM(RTRIM(@serie)), '');  
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
    AND idEntidad  = @idEntidad;  
  
  
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
  
        )  
        BEGIN  
            UPDATE inv_inventarioDet  
            SET cantidadExistente = ISNULL(cantidadExistente,0) + (@cantidad * @afectacion),  
                costoUnitario = ISNULL(@costoUnitario, costoUnitario),  
                precioVenta = ISNULL(@precioVenta, precioVenta),  
                fechaExpira = ISNULL(@fechaVencimiento, fechaExpira),  
                fechaUltimoMovimiento = GETDATE(),  
                idUsuarioModifica = @idUsuarioModifica,  
                fechaModificacion = GETDATE()  
            WHERE idProductoServicio = @idProductoServicio  
    AND (lote  = @lote  OR (lote  IS NULL AND @lote  IS NULL))  
    AND (serie = @serie OR (serie IS NULL AND @serie IS NULL))  
    AND (  
     (fechaExpira    = @fechaVencimiento)  
     OR (fechaExpira    IS NULL AND @fechaVencimiento IS NULL)  
     )  
    AND (numeracion = @numeracion OR (numeracion IS NULL AND @numeracion IS NULL))  
    AND idEntidad = @idEntidad  
  
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
                idUsuarioAlta  
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
                GETDATE(),  
                1,  
                @idEntidad,  
                GETDATE(),  
                @idUsuarioModifica  
            );  
        END  
          
    
  
  
        -- 4 Actualizar o insertar en inv_inventario  
        IF EXISTS (  
            SELECT 1 FROM inv_inventario   
            WHERE idProductoServicio = @idProductoServicio  
              AND idEntidad = @idEntidad  
        )  
        BEGIN  
            UPDATE inv_inventario  
            SET cantidadExistente = ISNULL(cantidadExistente,0) + (@cantidad * @afectacion),  
                costoUnitario = ISNULL(@costoUnitario, costoUnitario),  
                precioVenta = ISNULL(@precioVenta, precioVenta),  
                fechaUltimoMovimiento = GETDATE(),  
                idUsuarioModifica = @idUsuarioModifica,  
                fechaModificacion = GETDATE()  
            WHERE idProductoServicio = @idProductoServicio  
              AND idEntidad = @idEntidad;  
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
                idUsuarioAlta  
            )  
            VALUES (  
                @idProductoServicio,  
                (@cantidad * @afectacion),  
                @idUnidadMedida,  
                @costoUnitario,  
                @precioVenta,  
                GETDATE(),  
                1,  
                @idEntidad,  
                GETDATE(),  
                @idUsuarioModifica  
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