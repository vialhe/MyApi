using Microsoft.AspNetCore.Mvc;
using MyApi.Controllers.MyTools;
using MyApi.Models.MyDB;
using System.Data;

namespace MyApi.Controllers.TipoProductoServicio
{
    [ApiController]
    [Route("[controller]")]
    public class TipoProductoServicioController : ControllerBase
    {
        public static string NombreTabla = "cat_tipoProductoServicio";

        [HttpPost]
        [Route("get-tipoProductoServicio")]
        public IActionResult TipoProductoServicioGet(int id = 0, int idEntidad = 0, int isAdmin = 0)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            //Referencias

            try
            {
                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", id.ToString()),
                    new Parametro("idEntidad", idEntidad.ToString()),
                    new Parametro("isAdmin", isAdmin.ToString())
                };

                dt = Models.MyDB.DataBase.Listar("sp_se_perfil", parametros);
                Code = true;
                Message = "Succes";
                Response = ToolsController.ToJson(Code, Message, dt);

            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = ToolsController.ToJson(Code, Message);
            }
            return Response;
        }

        [HttpPost]
        [Route("insert-tipoProductoServicio")]
        public IActionResult TipoProductoServicioPut(Models.TipoProductoServicio.TipoProductoServicio cTipoProductoServicio)
        {
            /*Se declaran Variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            cTipoProductoServicio.id = 0;

            try
            {
                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", cTipoProductoServicio.id.ToString()),
                    new Parametro("descripcion", cTipoProductoServicio.descripcion.ToString()),
                    new Parametro("comentarios", cTipoProductoServicio.comentarios.ToString()),
                    new Parametro("activo", cTipoProductoServicio.activo.ToString()),
                    new Parametro("idEntidad", cTipoProductoServicio.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", cTipoProductoServicio.idUsuarioModifica.ToString()),
                    new Parametro("catalogo", NombreTabla.ToString())

                };

                dt = DataBase.Listar("sp_ui_catalogos", parametros);

                Code = true;
                Message = "Succes";
                Response = ToolsController.ToJson(Code, Message, dt);

            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = ToolsController.ToJson(Code, Message);
            }
            return Response;


        }

        [HttpPost]
        [Route("update-tipoProductoServicio")]
        public IActionResult TipóProductoServicioUpdate(Models.TipoProductoServicio.TipoProductoServicio cTipoProductoServicio)
        {
            /*Se declaran variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", cTipoProductoServicio.id.ToString()),
                    new Parametro("descripcion", cTipoProductoServicio.descripcion.ToString()),
                    new Parametro("comentarios", cTipoProductoServicio.comentarios.ToString()),
                    new Parametro("activo", cTipoProductoServicio.activo.ToString()),
                    new Parametro("idEntidad", cTipoProductoServicio.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", cTipoProductoServicio.idUsuarioModifica.ToString()),
                    new Parametro("catalogo", NombreTabla.ToString())

                };

                dt = DataBase.Listar("sp_ui_catalogos", parametros);
                Code = true;
                Message = "Succes";
                Response = ToolsController.ToJson(Code, Message, dt);

            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = ToolsController.ToJson(Code, Message);
            }
            return Response;


        }



        [HttpPost]
        [Route("delete-TipoProductoServicio")]
        public IActionResult TipoProductoServicioDelete(int id, string nombreTabla = "")
        {
            /*Define variables*/
            JsonResult Response;
            bool Code;
            string Message;

            try
            {
                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", id.ToString()),
                    new Parametro("nombreTabla", NombreTabla.ToString())
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
