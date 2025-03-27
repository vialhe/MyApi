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

        public class PostalCodeRequest
        {
            public string CodigoPostal { get; set; }
        }


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

        [HttpPost]
        [Route("insert-domicilio")]
        public IActionResult insertDomicilio(Domicilio  cDomicilio)
        {
            /*Se declaran Variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            DataBase2 db = new DataBase2();
            cDomicilio.id = 0;

            try
            {
                db.SetCommand("sp_ui_direccion", true);
                db.AddParameter("@id", cDomicilio.id);
                db.AddParameter("@idPersona", cDomicilio.idPersona);
                db.AddParameter("@cp", cDomicilio.cp);
                db.AddParameter("@idEstado", cDomicilio.idEstado);
                db.AddParameter("@idMunicipio", cDomicilio.idMunicipio);
                db.AddParameter("@idColonia", cDomicilio.idColonia);
                db.AddParameter("@calle", cDomicilio.calle);
                db.AddParameter("@numeroExt", cDomicilio.numExterior);
                db.AddParameter("@numeroInt", cDomicilio.numInterior);
                db.AddParameter("@latitud", cDomicilio.latitud);
                db.AddParameter("@longitud", cDomicilio.longitud);
                db.AddParameter("@referencias", cDomicilio.referencias);
                db.AddParameter("@comentarios", cDomicilio.comentarios);
                db.AddParameter("@activo", cDomicilio.activo);
                db.AddParameter("@idEntidad", cDomicilio.idEntidad);
                db.AddParameter("@idUsuarioModifica", cDomicilio.idUsuarioModifica);

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
        [Route("update-domicilio")]
        public IActionResult updatePersona(Domicilio cDomicilio)
        {
            /*Se declaran Variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            DataBase2 db = new DataBase2();

            try
            {
                db.SetCommand("sp_ui_direccion", true);
                db.AddParameter("@id", cDomicilio.id);
                db.AddParameter("@idPersona", cDomicilio.idPersona);
                db.AddParameter("@cp", cDomicilio.cp);
                db.AddParameter("@idEstado", cDomicilio.idEstado);
                db.AddParameter("@idMunicipio", cDomicilio.idMunicipio);
                db.AddParameter("@idColonia", cDomicilio.idColonia);
                db.AddParameter("@calle", cDomicilio.calle);
                db.AddParameter("@numeroExt", cDomicilio.numExterior);
                db.AddParameter("@numeroInt", cDomicilio.numInterior);
                db.AddParameter("@latitud", cDomicilio.latitud);
                db.AddParameter("@longitud", cDomicilio.longitud);
                db.AddParameter("@referencias", cDomicilio.referencias);
                db.AddParameter("@comentarios", cDomicilio.comentarios);
                db.AddParameter("@activo", cDomicilio.activo);
                db.AddParameter("@idEntidad", cDomicilio.idEntidad);
                db.AddParameter("@idUsuarioModifica", cDomicilio.idUsuarioModifica);

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

        #region Persona
        [HttpPost]
        [Route("insert-persona")]
        public IActionResult insertPersona([FromBody]Persona cPersona)
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
                db.AddParameter("@idGenero", cPersona.idGenero);
                db.AddParameter("@fechaNacimiento", cPersona.fechaNacimiento);
                db.AddParameter("@correo", cPersona.correo);
                db.AddParameter("@comentarios", cPersona.comentarios);
                db.AddParameter("@numeroTelefono", cPersona.numeroTelefono);
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
                db.AddParameter("@idGenero", cPersona.idGenero);
                db.AddParameter("@fechaNacimiento", cPersona.fechaNacimiento);
                db.AddParameter("@correo", cPersona.correo);
                db.AddParameter("@numeroTelefono", cPersona.numeroTelefono);
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



        [HttpPost]
        [Route("insert-genero")]
        public IActionResult SalePut(catalogo data)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            DataBase2 db = new DataBase2();
            string catalogo = "cat_generos";

            try
            {
                db.BeginTransaction();

                db.SetCommand("sp_ui_catalogos", true);
                db.AddParameter("@id", data.id);
                db.AddParameter("@descripcion", data.descripcion);
                db.AddParameter("@comentarios", data.comentarios);
                db.AddParameter("@activo", data.activo);
                db.AddParameter("@idEntidad", data.idEntidad);
                db.AddParameter("@idUsuarioModifica", data.idUsuarioModifica);
                db.AddParameter("@catalogo", catalogo);
                DataSet ds = db.ExecuteWithDataSet();
                ds.Tables[0].TableName = "Data";

                db.Commit();

                Code = true;
                Message = "Succes";
                Response = MyToolsController.ToJson(Code, Message, ds);

            }
            catch (Exception ex)
            {
                db.Rollback();
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }
            return Response;
        }
        #endregion



        #region CP
        [HttpPost]
        [Route("get-location")]
        public IActionResult GetLocationByPostalCode([FromBody] PostalCodeRequest request)
        {
            /* Declara variables */
            JsonResult response;
            bool code;
            string message;
            DataTable dt;

            try
            {
                /* Inicia proceso */
                // Crear la lista de parámetros para el procedimiento almacenado
                List<Parametro> parametros = new List<Parametro> {
            new Parametro("@CodigoPostal", request.CodigoPostal)  // Usar el valor recibido en el JSON
        };

                // Llamar al procedimiento almacenado 'sp_GetLocationByPostalCode' con los parámetros
                dt = Models.MyDB.DataBase.Listar("sp_se_obtieneDireccionPorCP", parametros);

                // Definir respuesta exitosa
                code = true;
                message = "Success";
                response = MyToolsController.ToJson(code, message, dt);
            }
            catch (Exception ex)
            {
                // Definir respuesta en caso de error
                code = false;
                message = "Exception: " + ex.Message;
                response = MyToolsController.ToJson(code, message);
            }

            // Devolver la respuesta en formato JSON
            return response;
        }


        #endregion
    }
}
