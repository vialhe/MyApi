using Microsoft.AspNetCore.Mvc;
using MyApi.Controllers.MyTools;
using MyApi.Models.MyDB;
using System.Data;
using System.Reflection.Metadata;
using static MyApi.Controllers.Menu.MenuController;

namespace MyApi.Controllers.TipoProductoServicio
{
    [ApiController]
    [Route("[controller]")]
    public class TipoProductoServicioController : ControllerBase
    {
        public static string NombreTabla = "cat_tiposProductosServicios";

        public class TipoProductoServicioRequest
        {
            public int Id { get; set; }
            public int IdEntidad { get; set; }
            public int IsAdmin { get; set; }
        }

        [HttpPost]
        [Route("get-tipoProductoServicio")]
        public IActionResult TipoProductoServicioGet([FromBody] TipoProductoServicioRequest request)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            //Referencias
            DataBase2 db = new DataBase2();
            try
            {
                db.Open();

                db.SetCommand("sp_se_tipoProductosServicio", true);
                db.AddParameter("id", request.Id);
                db.AddParameter("idEntidad", request.IdEntidad);
                db.AddParameter("isAdmin", request.IsAdmin);

                DataSet ds = db.ExecuteWithDataSet();
                if (ds.Tables.Count > 0)
                    ds.Tables[0].TableName = "Data";

                Code = true;
                Message = "Succes";
                Response = MyToolsController.ToJson(Code, Message, ds);

            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
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
                Response = MyToolsController.ToJson(Code, Message, dt);

            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
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
                Response = MyToolsController.ToJson(Code, Message, dt);

            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
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
