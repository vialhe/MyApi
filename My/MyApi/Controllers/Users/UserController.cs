using Microsoft.AspNetCore.Mvc;
using System.Data;
using Newtonsoft.Json;
using MyApi.Models.MyDB;
using MyApi.Class.Tools;
using MyApi.Models.User;
using MyApi.Controllers.MyTools;

namespace MyApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : ControllerBase
    {

        [HttpPost]
        [Route("get-user")]
        public IActionResult UsuariosGet(int id = 0, int idEntidad = 0, int isAdmin = 0)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {

                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", id.ToString()),
                    new Parametro("idEntidad", idEntidad.ToString()),
                    new Parametro("isAdmin", isAdmin.ToString())
                };
                dt = DataBase.Listar("sp_se_usuarios", parametros);

                /*Define return success*/
                Code = true;
                Message = "Succes";
                Response = MyToolsController.ToJson(Code,Message, dt);

            }
            catch (Exception ex)
            {
                /*Define return ex*/
                Code = false;
                Message = "Exception: " + ex;
                Response = MyToolsController.ToJson(Code, Message);

            }
             return Response;

        }

        [HttpPost]
        [Route("insert-user")]
        public IActionResult UsuariosPut(Usuarios usuario)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            string salt;

            try
            {
                /*Se declaran Variables*/
                usuario.id = 0;

                /*Inicia proceso*/
                salt = BCrypt.Net.BCrypt.GenerateSalt();
                usuario.password = BCrypt.Net.BCrypt.HashPassword(usuario.password,salt);

                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", usuario.id.ToString()),
                    new Parametro("idPerfil", usuario.idPerfil.ToString()),
                    new Parametro("usuario", usuario.usuario.ToString()),
                    new Parametro("password", usuario.password.ToString()),
                    new Parametro("salt", salt),
                    new Parametro("idPersona", usuario.idPersona.ToString()),
                    new Parametro("nombre", usuario.nombre.ToString()),
                    new Parametro("comentarios", usuario.comentarios.ToString()),
                    new Parametro("activo", usuario.activo.ToString()),
                    new Parametro("idEntidad", usuario.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", usuario.idUsuarioModifica.ToString())
                };

                dt = DataBase.Listar("sp_ui_usuarios", parametros);

                /*Define return success*/
                Code = true;
                Message = "Succes";
                Response = MyToolsController.ToJson(Code, Message, dt);

            }
            catch (Exception ex)
            {
                /*Define return ex*/
                Code = false;
                Message = "Exception: " + ex;
                Response = MyToolsController.ToJson(Code, Message);

            }
            return Response;

        }

        [HttpPost]
        [Route("update-user")]
        public IActionResult UsuariosUpdate(Usuarios usuario)
        {

            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            string salt;

            try
            {

                /*Inicia proceso*/
                salt = BCrypt.Net.BCrypt.GenerateSalt();
                usuario.password = BCrypt.Net.BCrypt.HashPassword(usuario.password,salt);

                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", usuario.id.ToString()),
                    new Parametro("idPerfil", usuario.idPerfil.ToString()),
                    new Parametro("usuario", usuario.usuario.ToString()),
                    new Parametro("password", usuario.password.ToString()),
                    new Parametro("salt", salt),
                    new Parametro("idPersona", usuario.idPersona.ToString()),
                    new Parametro("nombre", usuario.nombre.ToString()),
                    new Parametro("comentarios", usuario.comentarios.ToString()),
                    new Parametro("activo", usuario.activo.ToString()),
                    new Parametro("idEntidad", usuario.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", usuario.idUsuarioModifica.ToString())
                };

                dt = DataBase.Listar("sp_ui_usuarios", parametros);

                /*Define return success*/
                Code = true;
                Message = "Succes";
                Response = MyToolsController.ToJson(Code, Message, dt);

                return Response;
            }
            catch (Exception ex)
            {
                /*Define return ex*/
                Code = false;
                Message = "Exception: " + ex;
                Response = MyToolsController.ToJson(Code, Message);

                return Response;
            }
        }

        [HttpPost]
        [Route("delete-user")]
        public IActionResult UsuariosDelete(int id, string nombreTabla = "")
        {
            /*Define variables*/
            JsonResult Response;
            bool Code;
            string Message;
            nombreTabla = "sys_usuarios";

            try
            {
                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", id.ToString()),
                    new Parametro("nombreTabla", nombreTabla.ToString())
                };

                DataBase.Ejecutar("sp_del_fromNameTable", parametros);
                Code = true;
                Message = "Succes";

                Response = MyToolsController.ToJson(Code, Message);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;

                Response = MyToolsController.ToJson(Code, Message);
            }
            return Response;
        }

    }
}