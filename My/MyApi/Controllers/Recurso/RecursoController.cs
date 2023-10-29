using Microsoft.AspNetCore.Mvc;
using System.Data;
using Newtonsoft.Json;
using MyApi.Models.MyDB;
using MyApi.Models.ProductoServicio;
using MyApi.Controllers.MyTools;
using MyApi.Models.Recurso;
using Microsoft.Data.SqlClient;
using System.Text;

namespace MyApi.Controllers.Recurso
{
    [ApiController]
    [Route("[controller]")]
    public class RecursoController : ControllerBase
    {

        [HttpPost]
        [Route("get-recurso")]
        public IActionResult RecursoGet(int id = 0, int idEntidad = 0, int isAdmin = 0)
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

                dt = Models.MyDB.DataBase.Listar("sp_se_recursos", parametros);
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
        [Route("insert-recurso")]
        public IActionResult RecursoPut(Models.Recurso.Recurso cRecurso)
        {
            /*Se declaran Variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            cRecurso.id = 0;

            DataBase db = new DataBase();
            try
            {
                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("idTabla", cRecurso.idTabla.ToString()),
                    new Parametro("idRegistro", cRecurso.idRegistro.ToString()),
                    new Parametro("descripcion", cRecurso.descripcion.ToString()),
                    new Parametro("recurso", Encoding.UTF8.GetString(cRecurso.recurso)),
                    new Parametro("comentarios", cRecurso.comentarios.ToString()),
                    new Parametro("activo", cRecurso.activo.ToString()),
                    new Parametro("idEntidad", cRecurso.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", cRecurso.idUsuarioModifica.ToString())
                };


               dt = DataBase.Listar("sp_ui_recurso", parametros);

                Code = true;
                Message = "Succes";
                Response = ToolsController.ToJson(Code,Message,dt);

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
        [Route("update-recurso")]
        public IActionResult RecursoUpdate(Models.Recurso.Recurso cRecurso)
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
                    new Parametro("id", cRecurso.id.ToString()),
                    new Parametro("idTabla", cRecurso.idTabla.ToString()),
                    new Parametro("idRegistro", cRecurso.idRegistro.ToString()),
                    new Parametro("descripcion", cRecurso.descripcion.ToString()),
                    new Parametro("recurso", Encoding.UTF8.GetString(cRecurso.recurso)),
                    new Parametro("comentarios", cRecurso.comentarios.ToString()),
                    new Parametro("activo", cRecurso.activo.ToString()),
                    new Parametro("idEntidad", cRecurso.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", cRecurso.idUsuarioModifica.ToString())
                };

                dt = DataBase.Listar("sp_ui_recurso", parametros);
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
        [Route("delete-recurso")]
        public IActionResult RecursoDelete(int id, string nombreTabla = "")
        {
            /*Define variables*/
            JsonResult Response;
            bool Code;
            string Message;
            nombreTabla = "cat_recursos";

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