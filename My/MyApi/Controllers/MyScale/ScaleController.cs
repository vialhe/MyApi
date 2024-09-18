using Microsoft.AspNetCore.Mvc;
using System.Data;
using Newtonsoft.Json;
using MyApi.Models.MyDB;
using MyApi.Class.Tools;
using MyApi.Models.User;
using Microsoft.AspNetCore.ResponseCompression;
using MyApi.Controllers.MyTools;
using static MyApi.Controllers.MyTools.MyToolsController;

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

        [HttpPost]
        [Route("get-tiposPagos")]
        public IActionResult GetTiposPagos(GenericReques rTipoPago)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            string NombreTablaEnBD = "cat_tiposPago";
            DataSet ds;
            DataBase2 db = new DataBase2();


            try
            {
                db.SetCommand("sp_se_catalogos", true);
                db.AddParameter("id", rTipoPago.id.ToString());
                db.AddParameter("idEntidad", rTipoPago.idEntidad.ToString());
                db.AddParameter("isAdmin", rTipoPago.isAdmin.ToString());
                db.AddParameter("catalogo", NombreTablaEnBD);

                /*Define return success*/
                ds = db.ExecuteWithDataSet();
                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Succes";

                Response = MyToolsController.ToJson(Code, Message, ds.Tables[0]);
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

    }
}