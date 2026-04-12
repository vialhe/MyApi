-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREAMOS LA ENTIDAD
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select * From sys_entidades where id = 9999 /*esta entidad ya la conservamos, que es la de pruebas*/
/*
exec sp_ui_entidad 
	@id = 0, -- 0 = nuevo, x = editar esa entidad
	@descripcion = 'Local 21', --nombre de la entidad
	@idPadre = 9998, --aqui el 9998 es entidad de "tienditas" este será siempre para tienditas, lo puse asi para en un futuro tener como un esquema de arboles y tener padres e hijos.
	@comentarios = '', --campo de comentarios
	@activo = 1, --1 = activo, 0 = inactivo
	@idUsuarioModifica = 1  --usuario alta, 1 = superadmin
*/
go


-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREAMOS TIPO PERSONA ( siempre van "administrador" y "proveedor" ) 
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select * From cat_tiposPersonas where idEntidad = 10007
/*
	exec sp_ui_catalogos 
	@id = 0, -- 0 = nuevo, x = editar esa entidad
	@descripcion = 'Administrador', --descripcion
	@comentarios = '', --comentarios
	@idEntidad = 10007, 
	@activo = 1,
	@idUsuarioModifica = 1,
	@catalogo = 'cat_tiposPersonas' --este define a que tabla afectamos, el sp es unico para tablas con misma estrucutra como lo son catalogos
*/

/*Siempre creamos la persona provedores*/

--exec sp_ui_catalogos 0,'Proveedor','',10007,1,1,'cat_tiposPersonas'
go


-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREAMOS PERSONA
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select * From cat_personas where idEntidad = 10007
/*
	Exec sp_ui_persona 
	@id=0,
	@idTipoPersona = 25, --aqui va el id que se obtiene al isertar en "cat_tiposPersonas" el "Administrador" ( para los "Proveedores" ya tengo desarrollado el CRUD desde el POS)
	@nombre ='Administrador',
	@apellidoPaterno = '',
	@apellidoMaterno = '',
	@idGenero = 1,
	@fechaNacimiento ='19981221',
	@numeroTelefono = '4811076708',
	@correo = 'admin@takio.com',
	@comentarios='',
	@activo = 1,
	@idEntidad = 10007,
	@idUsuarioModifica =1
*/
go


-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREAMOS PERFIL
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Select * From sys_perfiles where idEntidad = 10007
--exec sp_ui_catalogos 0,'Administrador','',10007,1,1,'sys_perfiles' /*los perfiles tienen la misma estructura de catalogo, por eso se ocupa el mismo SP*/
GO


-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREAMOS USUARIO
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select * From sys_usuarios where idEntidad = 10007
/*
	exec sp_ui_usuarios 
	@id = 0,
	@idPerfil = 17, --aqui va el IdPerfil que se obtuvo dlel SP anterior (sys_perfiles)
	@usuario= 'Administrador', --usuario con el que se va a logear
	@password = '', --se deja vacio porque elpassword se genera desde un EP que encripta la contraseña
	@salt = '', ----se deja vacio porque salt se genera desde un EP que encripta la contraseña
	@idPersona = 1116, -- aqui va el id que se generó a la tabla cat_personas en el sp de arriba
	@nombre = '' ,-- realmente este campo no es tan util porque tengo la persona relacionada xd
	@comentarios = '',
	@activo = 1,
	@idEntidad = 10007,
	@idUsuarioModifica = 1
*/
GO


-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- AQUI FALTA CREAR LO QUE CORRESPONDE A UNIDADES DE MEDIDA QUE HEMOS ESTADO MEJORANDO
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUERY
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- AQUI FALTA CREAR LO QUE CORRESPONDE A UNIDADES DE MEDIDA QUE HEMOS ESTADO MEJORANDO
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GO

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREAMOS LOS TIPOS DE PRODUCTOS Genericos(pueden variar segun negocio), se planea en un fuutro crear un CRUD para que esto se haga desde el POS pero no he tenido tiempo*/
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select * From cat_tiposProductosServicios where idEntidad = 10007
BEGIN TRAN
	EXEC sp_ui_catalogos 0,'Botanas y Frituras','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Frutas y Verduras','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Lácteos y Derivados','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Embutidos y Carnes Frías','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Congelados','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Bebidas','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Galletas y Snacks','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Bebidas Alcohólicas','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Dulcería y Chocolatería','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Panadería y Tortillería','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Granos y Harinas','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Pastas y Sopas','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Aceites y Condimentos','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Enlatados y Conservas','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Productos para Bebés','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Higiene Personal','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Limpieza del Hogar','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Papelería','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Mascotas','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Calzado y Ropa','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Ferretería y Pilas','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Productos de Temporada','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Novedades','',9999,1,1,'cat_tiposProductosServicios'
	EXEC sp_ui_catalogos 0,'Regalos San Valentin','',9999,1,1,'cat_tiposProductosServicios'
Rollback
GO


-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SETEAR CONTRASEÑA: Este el EP que genera la constraseña para poder logearse al POS, el "id" es el id que genero a la tabla sys_usuarios del sp de arriba*/
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
POST: https://mystores-001-site1.jtempurl.com/auth/ChangePassword
BODY:
{
    "id": 51,
    "username": "Administrador",
    "password": "lacruz" ,
    "comentarios": "",
    "idUsuarioModifica" : 1
}
*/

Select top 1 * From cat_unidadesMedida
Select top 1 * From cat_magnitudMedida
Select top 1 * From proc_unidadMedidaConversion
Select top 1 * From proc_productoUnidadMedida
Select top 1 * From proc_ProductoPrecioUnidad

