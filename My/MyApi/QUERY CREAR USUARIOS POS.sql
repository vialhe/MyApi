/*CREAMOS LA ENTIDAD*/
Select * From sys_entidades where id = 10003
--exec sp_ui_entidad 0,'Abarrotes La Cruz',9998,'',1,1
go

/*CREAMOS TIPO PERSONA*/
Select * From cat_tiposPersonas where idEntidad = 10003
--exec sp_ui_catalogos 0,'Administrador','',10003,1,1,'cat_tiposPersonas'

/*Siempre creamos la persona provedores*/
--exec sp_ui_catalogos 0,'Proveedor','',10003,1,1,'cat_tiposPersonas'

go

/*CREAMOS PERSONA*/
Select * From cat_personas where idEntidad = 10003
Exec sp_ui_persona 1067,15,'Nahum Gonzalez','','',1,'19940313','4810000000','invitado@gmail.com','',1,10003,1
go

/*CREAMOS PERFIL*/
Select * From sys_perfiles where idEntidad = 10003
--exec sp_ui_catalogos 0,'Administrador','',10003,1,1,'sys_perfiles'

/*CREAMOS USUARIO*/
Select * From sys_usuarios where idEntidad = 10003
exec sp_ui_usuarios 0,12,'nahum','','',1067,'g','',1,10003,1

/*CREAMOS LOS TIPOS DE PRODUCTOS*/
Select * From cat_tiposProductosServicios where idEntidad = 10000
BEGIN TRAN
	EXEC sp_ui_catalogos 0,'Frutas y Verduras','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Lácteos y Derivados','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Embutidos y Carnes Frías','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Congelados','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Botanas y Frituras','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Bebidas No Alcohólicas','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Bebidas Alcohólicas','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Dulcería y Chocolatería','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Panadería y Tortillería','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Granos y Harinas','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Pastas y Sopas','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Pastas y Sopas','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Aceites y Condimentos','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Enlatados y Conservas','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Productos para Bebés','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Higiene Personal','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Limpieza del Hogar','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Papelería','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Mascotas','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Novedades','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Calzado y Ropa','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Ferretería y Pilas','',10003,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Productos de Temporada','',10003,1,1,'cat_tiposProductosServicios'
Rollback
/*SETEAR CONTRASEÑA
POST: https://mystores-001-site1.jtempurl.com/auth/ChangePassword
BODY:
{
    "id": 42,
    "username": "nahum",
    "password": "lacruz" ,
    "comentarios": "",
    "idUsuarioModifica" : 1
}
*/


--Select * From cat_productosServicios where idEntidad = 10003

--Select * From cat_tiposPersonas where idEntidad = 10003
--Select * From cat_personas where idEntidad = 10003

--Update cat_personas set idTipoPersona = 16 where id = 1068