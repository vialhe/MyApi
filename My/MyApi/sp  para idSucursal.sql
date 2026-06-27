Select top 10 * From proc_entradasSalidas where idEntidad = 10007 order by fechaAlta desc
Select top 10 * From proc_entradasSalidasDetalles where idEntidad = 10007 order by fechaAlta desc
Select top 10 * From proc_entradasSalidaPago where idEntidad = 10007 order by fechaAlta desc
Select top 10 * From proc_movimientosInventarios where idEntidad = 10007 order by fechaAlta desc
Select top 10 * From proc_movimientosInventariosDetalles where idEntidad = 10007 order by fechaAlta desc 
Select top 10 * From inv_inventario where idEntidad = 10007 order by fechaAlta desc
Select top 10 * From inv_inventarioDet where idEntidad = 10007 order by fechaAlta desc
Select * From sys_foliosContador Where idEntidad = 10007
Select * From sys_folios		 


Alter table proc_entradasSalidasDetalles add idSucursal int null
Alter table proc_entradasSalidaPago add idSucursal int null
Alter table proc_movimientosInventarios add idSucursal int null
Alter table proc_movimientosInventariosDetalles add idSucursal int null
Alter table inv_inventario add idSucursal int null
Alter table inv_inventarioDet add idSucursal int null
Alter table proc_agendaDetalleServicio add idSucursal int null
Alter table proc_agendaPago add idSucursal int null
Alter table proc_corteTienda add idSucursal int null
Alter table proc_corteCaja add idSucursal int null
Alter table sys_foliosContador add idSucursal int null


--Update  proc_entradasSalidaPago set idSucursal = 0 where idEntidad = 10007

--Select * From sys_folios
--Select * From sys_foliosContador

--Select * From sys_usuarios where usuario = 'victorhg'
--Select * From proc_empleadoSucursal where folioEmpleado = 1153 and esPrincipal = 1

--Select * From inv_inventario   	Where idEntidad = 10007
--Select * From inv_inventarioDet Where idEntidad = 10007

--Update inv_inventario    set idSucursal = 9	Where idEntidad = 10007
--Update inv_inventarioDet set idSucursal = 9 Where idEntidad = 10007

Select * From corteDeCa
