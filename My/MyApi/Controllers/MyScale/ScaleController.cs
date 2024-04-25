using Microsoft.AspNetCore.Mvc;
using System.Data;
using Newtonsoft.Json;
using MyApi.Models.MyDB;
using MyApi.Class.Tools;
using MyApi.Models.User;
using Microsoft.AspNetCore.ResponseCompression;
using MyApi.Controllers.MyTools;

namespace MyApi.Controllers.MyScale
{
    [ApiController]
    [Route("[controller]")] 
    public class MenuController : ControllerBase
    {

        [HttpPost]
        [Route("insert-scale")]
        public IActionResult UsuariosGet(int id = 0)

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
                    new Parametro("id", id.ToString())
                };
                dt = Models.MyDB.DataBase.Listar("sp_se_usuarios", parametros);

                /*Define return*/
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, dt);
            }
            catch (Exception ex)
            {
                /* Retorna error */
                Code = false;
                Message = "Ex:" + ex.Message;
                Response= MyToolsController.ToJson(Code,Message);
            }
            /* Retorna Datos */
            return Response;
        }

        [HttpPut]
        [Route("insert-scale")]
        public IActionResult UsuariosPut(Usuarios usuario)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            usuario.id = 0;

            try
            {
                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", usuario.id.ToString()),
                    new Parametro("idPerfil", usuario.idPerfil.ToString()),
                    new Parametro("usuario", usuario.usuario.ToString()),
                    new Parametro("password", usuario.password.ToString()),
                    new Parametro("idPersona", usuario.idPersona.ToString()),
                    new Parametro("nombre", usuario.nombre.ToString()),
                    new Parametro("comentarios", usuario.comentarios.ToString()),
                    new Parametro("activo", usuario.activo.ToString()),
                    new Parametro("idEntidad", usuario.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", usuario.idUsuarioModifica.ToString()),
                };

                dt = DataBase.Listar("sp_ui_usuarios", parametros);

                Code= true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code,Message,dt);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex;
                Response = MyToolsController.ToJson(Code, Message);
            }


            return Response;
        }

        [HttpPut]
        [Route("update-scale")]
        public IActionResult UsuariosUpdate(Usuarios usuario)
        {
            /*Declara variables*/
            DataTable dt;

            try
            {

                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", usuario.id.ToString()),
                    new Parametro("idPerfil", usuario.idPerfil.ToString()),
                    new Parametro("usuario", usuario.usuario.ToString()),
                    new Parametro("password", usuario.password.ToString()),
                    new Parametro("idPersona", usuario.idPersona.ToString()),
                    new Parametro("nombre", usuario.nombre.ToString()),
                    new Parametro("comentarios", usuario.comentarios.ToString()),
                    new Parametro("activo", usuario.activo.ToString()),
                    new Parametro("idEntidad", usuario.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", usuario.idUsuarioModifica.ToString()),

                };
                dt = DataBase.Listar("sp_ui_usuarios", parametros);
            }
            catch (Exception)
            {

                throw;
            }


            return MyToolsController.ToJson(dt);
        }

    }
}