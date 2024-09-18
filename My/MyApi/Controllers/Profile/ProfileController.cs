using Microsoft.AspNetCore.Mvc;
using MyApi.Controllers.MyTools;
using MyApi.Models.MyDB;
using MyApi.Models.ProductoServicio;
using MyApi.Models.Profile;
using System.Data;
using static MyApi.Controllers.MyTools.MyToolsController;

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

        #region Persona
        [HttpPost]
        [Route("insert-persona")]
        public IActionResult insertPersona(Persona cPersona)
        {
            /*Se declaran Variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            DataBase2 db = new DataBase2();
            cPersona.id = 0;

            try
            {
                db.SetCommand("sp_ui_persona", true);
                db.AddParameter("@id", cPersona.id);
                db.AddParameter("@idTipoPersona", cPersona.idTipoPersona);
                db.AddParameter("@nombre", cPersona.nombre);
                db.AddParameter("@apellidoPaterno", cPersona.apellidoPaterno);
                db.AddParameter("@apellidoMaterno", cPersona.apellidoMaterno);
                db.AddParameter("@genero", cPersona.genero);
                db.AddParameter("@fechaNacimiento", cPersona.fechaNacimiento);
                db.AddParameter("@calle", cPersona.calle);
                db.AddParameter("@numExterior", cPersona.numExterior);
                db.AddParameter("@numInterior", cPersona.numInterior);
                db.AddParameter("@colonia", cPersona.colonia);
                db.AddParameter("@municipio", cPersona.municipio);
                db.AddParameter("@estado", cPersona.estado);
                db.AddParameter("@cp", cPersona.cp);
                db.AddParameter("@referenciasDomicilio", cPersona.referenciasDomicilio);
                db.AddParameter("@nss", cPersona.nss); // Número de Seguro Social
                db.AddParameter("@correo", cPersona.correo);
                db.AddParameter("@comentarios", cPersona.comentarios);
                db.AddParameter("@activo", cPersona.activo);
                db.AddParameter("@idEntidad", cPersona.idEntidad);
                db.AddParameter("@idUsuarioModifica", cPersona.idUsuarioModifica);

                dt = db.ExecuteWithDataSet().Tables[0];
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
        [Route("update-persona")]
        public IActionResult updatePersona(Persona cPersona)
        {
            /*Se declaran Variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            DataBase2 db = new DataBase2();

            try
            {
                db.SetCommand("sp_ui_persona", true);
                db.AddParameter("@id", cPersona.id);
                db.AddParameter("@idTipoPersona", cPersona.idTipoPersona);
                db.AddParameter("@nombre", cPersona.nombre);
                db.AddParameter("@apellidoPaterno", cPersona.apellidoPaterno);
                db.AddParameter("@apellidoMaterno", cPersona.apellidoMaterno);
                db.AddParameter("@genero", cPersona.genero);
                db.AddParameter("@fechaNacimiento", cPersona.fechaNacimiento);
                db.AddParameter("@calle", cPersona.calle);
                db.AddParameter("@numExterior", cPersona.numExterior);
                db.AddParameter("@numInterior", cPersona.numInterior);
                db.AddParameter("@colonia", cPersona.colonia);
                db.AddParameter("@municipio", cPersona.municipio);
                db.AddParameter("@estado", cPersona.estado);
                db.AddParameter("@cp", cPersona.cp);
                db.AddParameter("@referenciasDomicilio", cPersona.referenciasDomicilio);
                db.AddParameter("@nss", cPersona.nss); // Número de Seguro Social
                db.AddParameter("@correo", cPersona.correo);
                db.AddParameter("@comentarios", cPersona.comentarios);
                db.AddParameter("@activo", cPersona.activo);
                db.AddParameter("@idEntidad", cPersona.idEntidad);
                db.AddParameter("@idUsuarioModifica", cPersona.idUsuarioModifica);

                dt = db.ExecuteWithDataSet().Tables[0];
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
        [Route("get-personas")]
        public IActionResult GetPersonas(GenericReques rPersona)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            string NombreTablaEnBD = "cat_personas";
            DataSet ds;
            DataBase2 db = new DataBase2();


            try
            {
                db.SetCommand("sp_se_catalogos", true);
                db.AddParameter("id", rPersona.id.ToString());
                db.AddParameter("idEntidad", rPersona.idEntidad.ToString());
                db.AddParameter("isAdmin", rPersona.isAdmin.ToString());
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

        [HttpPost]
        [Route("get-tiposPersona")]
        public IActionResult GetTiposPersona(GenericReques rPersona)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            string NombreTablaEnBD = "cat_tiposPersonas";
            DataSet ds;
            DataBase2 db = new DataBase2();


            try
            {
                db.SetCommand("sp_se_catalogos", true);
                db.AddParameter("id", rPersona.id.ToString());
                db.AddParameter("idEntidad", rPersona.idEntidad.ToString());
                db.AddParameter("isAdmin", rPersona.isAdmin.ToString());
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
        #endregion
    }
}
