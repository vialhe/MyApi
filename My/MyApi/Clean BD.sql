/*
	 I M P O R T A N T E   :   L I M P I A R   R E G I S T R O S   D E   B D 

Delete from proc_movimientosInventarios
Delete from proc_movimientosInventariosDetalles
Delete From inv_inventario
Delete From inv_inventarioDet


Delete From proc_entradasSalidas
Delete From proc_entradasSalidasDetalles
Delete From proc_entradasSalidaPago

Delete From proc_corteCaja
Delete From proc_corteTienda

*/

/*
	 I M P O R T A N T E   :   A G R E G A R   C A T A L O G O S   A   C A D A   E N T I D A D 

*//*
SELECT * From cat_unidadesMedida WHERE idEntidad = 9999
SELECT * From sys_folios
SELECT * From sys_foliosContador
Select * From cat_estadosEntradaSalida
GO
*/
--exec sp_ui_catalogos
--@id						= 0,
--@descripcion			='Caja',
--@comentarios			= '',
--@idEntidad				= 9999,
--@activo					= 1,
--@idUsuarioModifica		= 1,
--@catalogo				= 'cat_unidadesMedida'

/*

	--------------------------------------------------------------------------------- 	 
	--------------------------------------------------------------------------------- 	 

*/


Select * From inv_inventario
Select * From inv_inventarioDet
Select * From cat_productosServicios where id IN( 1159)--,1153,1161,1166)

Select * From proc_movimientosInventarios where folioMovimientoInventario = 329
Select * From proc_movimientosInventariosDetalles where folioMovimientoInventario = 329
Select * From cat_tiposMovmientosInventario

Select * From proc_entradasSalidas where folioEntradaSalida = 192
Select * From proc_entradasSalidasDetalles where folioEntradaSalida = 192
Select * From proc_entradasSalidaPago where folioEntradaSalida = 192
Select * From cat_estadosEntradaSalida

exec sp_se_corteTienda 9999

exec sp_se_catalogos 0,9999,1,'cat_tiposMovmientosInventario'
exec sp_se_catalogos 0,1,1,'cat_tiposMovmientosInventario'
exec sp_se_catalogos 0,9999,1,'cat_unidadesMedida'
sys_entidades
exec sp_se_catalogos 0,1,1,'cat_unidadesMedida'




 --BEGIN CATCH
 --       DECLARE @ErrorMessage NVARCHAR(4000);
 --       DECLARE @ErrorSeverity INT;
 --       DECLARE @ErrorState INT;

 --       SET @ErrorMessage = ERROR_MESSAGE();
 --       SET @ErrorSeverity = ERROR_SEVERITY();
 --       SET @ErrorState = ERROR_STATE();

 --       RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
 --       RAISERROR ('Ocurrió un error en el SP. Detalles: %s', 16, 1, @ErrorMessage);
 --   END CATCH
 go

 Declare @idEntidad int = 9998
 ;WITH EntidadesHijas AS (
    SELECT id
    FROM sys_entidades
    WHERE id = @idEntidad
    UNION ALL
    SELECT e.id
    FROM sys_entidades e
    INNER JOIN EntidadesHijas eh ON e.idPadre = eh.id
)
SELECT * 
FROM Cat_UnidadesMedida
WHERE activo = 1
AND (
    idEntidad = 1
    OR idEntidad IN (SELECT id FROM EntidadesHijas)
)
