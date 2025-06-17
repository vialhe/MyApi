/*
	 I M P O R T A N T E   :   L I M P I A R   R E G I S T R O S   D E   B D 
/*

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

*/
SELECT * From cat_unidadesMedida WHERE idEntidad = 9999
SELECT * From sys_folios
SELECT * From sys_foliosContador
GO
SELECT * From sys_foliosContador

go
--exec sp_ui_catalogos
--@id						= 0,
--@descripcion			='Caja',
--@comentarios			= '',
--@idEntidad				= 9999,
--@activo					= 1,
--@idUsuarioModifica		= 1,
--@catalogo				= 'cat_unidadesMedida'