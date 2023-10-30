using Microsoft.AspNetCore.Mvc;
using System.Data;
using MyApi.Models.MyDB;
using MyApi.Controllers.MyTools;
using MyApi.Models.User;

namespace MyApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class EntidadController : ControllerBase
    {

        [HttpPost]
        [Route("get-entidad")]
        public IActionResult EntidadGet(int id = 0, int idEntidad = 0, int isAdmin = 0)
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
                dt = DataBase.Listar("sp_se_entidad", parametros);

                /*Define return success*/
                Code = true;
                Message = "Succes";
                Response = ToolsController.ToJson(Code, Message, dt);

            }
            catch (Exception ex)
            {
                /*Define return ex*/
                Code = false;
                Message = "Exception: " + ex;
                Response = ToolsController.ToJson(Code, Message);

            }
            return Response;

        }

        [HttpPost]
        [Route("insert-entidad")]
        public IActionResult EntidadPut(Entidad entidad)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                /*Se declaran Variables*/
                entidad.id = 0;

                /*Inicia proceso*/

                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", entidad.id.ToString()),
                    new Parametro("idPadre", entidad.idPadre.ToString()),
                    new Parametro("descripcion", entidad.descripcion.ToString()),
                    new Parametro("comentarios", entidad.comentarios.ToString()),
                    new Parametro("activo", entidad.activo.ToString()),
                    new Parametro("idUsuarioModifica", entidad.idUsuarioModifica.ToString())
                };

                dt = DataBase.Listar("sp_ui_entidad", parametros);

                /*Define return success*/
                Code = true;
                Message = "Succes";
                Response = ToolsController.ToJson(Code, Message, dt);

            }
            catch (Exception ex)
            {
                /*Define return ex*/
                Code = false;
                Message = "Exception: " + ex;
                Response = ToolsController.ToJson(Code, Message);

            }
            return Response;

        }

        [HttpPost]
        [Route("update-entidad")]
        public IActionResult EntidadUpdate(Entidad entidad)
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
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", entidad.id.ToString()),
                    new Parametro("idPadre", entidad.idPadre.ToString()),
                    new Parametro("descripcion", entidad.descripcion.ToString()),
                    new Parametro("comentarios", entidad.comentarios.ToString()),
                    new Parametro("activo", entidad.activo.ToString()),
                    new Parametro("idUsuarioModifica", entidad.idUsuarioModifica.ToString())
                };

                dt = DataBase.Listar("sp_ui_entidad", parametros);

                /*Define return success*/
                Code = true;
                Message = "Succes";
                Response = ToolsController.ToJson(Code, Message, dt);

                return Response;
            }
            catch (Exception ex)
            {
                /*Define return ex*/
                Code = false;
                Message = "Exception: " + ex;
                Response = ToolsController.ToJson(Code, Message);

                return Response;
            }
        }

        [HttpPost]
        [Route("delete-entidad")]
        public IActionResult EntidadDelete(int id, string nombreTabla = "")
        {
            /*Define variables*/
            JsonResult Response;
            bool Code;
            string Message;
            nombreTabla = "sys_entidades";

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

                Response = ToolsController.ToJson(Code, Message);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;

                Response = ToolsController.ToJson(Code, Message);
            }
            return Response;
        }

    }
}