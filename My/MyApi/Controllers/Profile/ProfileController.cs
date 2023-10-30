using Microsoft.AspNetCore.Mvc;
using MyApi.Controllers.MyTools;
using MyApi.Models.MyDB;
using System.Data;

namespace MyApi.Controllers.Profile
{
    [ApiController]
    [Route("[controller]")]
    public class ProfileController : ControllerBase
    {
        public static string NombreTabla = "sys_perfiles";

        [HttpPost]
        [Route("get-profile")]
        public IActionResult ProfileGet(int id = 0, int idEntidad = 0, int isAdmin = 0)
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
        [Route("insert-profile")]
        public IActionResult ProfilePut(Models.Profile.Profile cProfile)
        {
            /*Se declaran Variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            cProfile.id = 0;

            try
            {
                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", cProfile.id.ToString()),
                    new Parametro("descripcion", cProfile.descripcion.ToString()),
                    new Parametro("comentarios", cProfile.comentarios.ToString()),
                    new Parametro("activo", cProfile.activo.ToString()),
                    new Parametro("idEntidad", cProfile.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", cProfile.idUsuarioModifica.ToString()),
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
        [Route("update-profile")]
        public IActionResult ProfileUpdate(Models.Profile.Profile cProfile)
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
                    new Parametro("id", cProfile.id.ToString()),
                    new Parametro("descripcion", cProfile.descripcion.ToString()),
                    new Parametro("comentarios", cProfile.comentarios.ToString()),
                    new Parametro("activo", cProfile.activo.ToString()),
                    new Parametro("idEntidad", cProfile.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", cProfile.idUsuarioModifica.ToString()),
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
        [Route("delete-profile")]
        public IActionResult ProfileDelete(int id, string nombreTabla = "")
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
