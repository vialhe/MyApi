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


Select 
	ps.id,
	ps.descripcion,
	inv.cantidadExistente,
	invd.lote,
	invd.serie,
	invd.fechaExpira
From
	cat_productosServicios ps
	left join inv_inventario inv
		On ps.id = inv.idProductoServicio
		And ps.idEntidad = inv.idEntidad
	join inv_inventarioDet invd
		On invd.idProductoServicio = inv.idProductoServicio
		And invd.idEntidad = inv.idEntidad

 --Select * From cat_personas

Select 
	h.folioMovimientoInventario,
	cat.descripcion,
	h.fechaAlta,
	ps.descripcion,
	d.cantidad,
	inv.cantidadExistente
From	
	proc_movimientosInventarios h
	join proc_movimientosInventariosDetalles d
		On h.folioMovimientoInventario = d.folioMovimientoInventario
		and h.identidad = d.identidad
	join inv_inventario inv
		On inv.idProductoServicio = d.idProductoServicio
		and inv.idEntidad = d.idEntidad
	join inv_inventarioDet invd
		On invd.idProductoServicio = inv.idProductoServicio
		and invd.idEntidad =  inv.idEntidad
	join cat_tiposMovmientosInventario cat
		On cat.id = h.idTipoMovimientoInventario
	join cat_productosServicios ps
		On ps.id = d.idProductoServicio
Order by
	h.fechaAlta


--Select * From proc_entradasSalidas where folioEntradaSalida = 192
--Select * From proc_entradasSalidasDetalles where folioEntradaSalida = 192
--Select * From proc_entradasSalidaPago where folioEntradaSalida = 192
--Select * From cat_estadosEntradaSalida

--exec sp_se_corteTienda 9999

--exec sp_se_catalogos 0,9999,1,'cat_tiposMovmientosInventario'
--exec sp_se_catalogos 0,1,1,'cat_tiposMovmientosInventario'
--exec sp_se_catalogos 0,9999,1,'cat_unidadesMedida'
--exec sp_se_catalogos 0,2,1,'cat_unidadesMedida'

--sys_entidades
--exec sp_se_catalogos 0,9999,1,'cat_tiposMovmientosInventario'

--Update cat_unidadesMedida set idEntidad = 1 where idEntidad = 9999


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

 
--Select
-- * 
--From
--	sys_entidades

--Select * From cat_tiposPago

--Update cat_tiposPago set activo = 0 where idEntidad = 9999

--Select * From proc_movimientosInventariosDetalles where foliomovimientoinventario IN (388,387) 

--
--	AQUI VAMOS A RETORNAR DATOS PARA EL DASHBOARD
--
Select
	esh.folioEntradaSalida,
	esh.idTipoEntradaSalida,
	esd.idProductoServicio,
	esd.cantidad
From 
	proc_entradasSalidas esh
	join proc_entradasSalidasDetalles esd
		On esh.folioEntradaSalida = esd.folioEntradaSalida
		and esh.idEntidad = esd.idEntidad
	join proc_entradasSalidaPago esp
		On esh.folioEntradaSalida = esp.folioEntradaSalida
		and esh.idEntidad = esp.idEntidad

Where
	idEstadoTicket = 3


	--
	-- 
	--

	Select * From cat_unidadesMedida
	Select * From cat_productosServicios
	Select * From proc_unidadMedidaConversion
	Select * From proc_entradasSalidas
	Select * From proc_entradasSalidasDetalles
	Select * From proc_movimientosInventariosDetalles

	--alter table  cat_productosServicios add numeracion decimal(18,2)

CREATE TABLE proc_unidadMedidaConversion (
  id INT IDENTITY PRIMARY KEY,
  idUMOrigen INT NOT NULL,
  idUMDestino INT NOT NULL,
  factor DECIMAL(18,6) NOT NULL
)