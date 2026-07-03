Select * From proc_movimientosInventarios where idEntidad IN (10007) and idSucursal <> 13
--Begin Tran
--	Update proc_movimientosInventarios set idSucursal = 13 where idEntidad IN (10007) and idSucursal <> 13
--Rollback

Select * From proc_movimientosInventariosDetalles where idEntidad IN (10007) and idSucursal <> 13
--Begin Tran
--	Update proc_movimientosInventariosDetalles set idSucursal = 13 where idEntidad IN (10007) and idSucursal <> 13 and idUsuarioAlta = 80
--Commit

Select * From inv_inventario where idEntidad IN (10007) and idSucursal = 13
Select * From inv_inventarioDet where idEntidad IN (10007) and idSucursal = 13

Select * From proc_entradasSalidas where idEntidad IN (10007) and idSucursal <> 13
Select * From proc_entradasSalidasDetalles where idEntidad IN (10007) and idSucursal <> 13
Select * From proc_entradasSalidaPago where idEntidad IN (10007) and idSucursal <> 13
Select * From proc_corteCaja   Where idSucursal <> 13
Select * From proc_corteTienda Where idSucursal <> 13

Select * From sys_foliosContador where idEntidad IN (10007) and idSucursal <> 13

Select * From cat_sucursales where idEntidad IN (10007) and idSucursal <> 13
Select * From sys_entidades where id IN (10007) 
Select * From cat_tiposMovmientosInventario