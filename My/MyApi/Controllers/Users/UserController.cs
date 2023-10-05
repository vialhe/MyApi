using Microsoft.AspNetCore.Mvc;
using System.Data;
using Newtonsoft.Json;
using MyApi.Models.MyDB;
using MyApi.Class.Tools;
using MyApi.Models.User;

namespace MyApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : ControllerBase
    {

        [HttpGet]
        [Route("get-user")]
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
                dt = DataBase.Listar("sp_se_usuarios", parametros);

                /*Define return success*/
                Code = true;
                Message = "Succes";
                Response = ToJson(Code,Message, dt);

                return Response;
            }
            catch (Exception ex)
            {
                /*Define return ex*/
                Code = false;
                Message = "Exception: " + ex;
                Response = ToJson(Code, Message);

                return Response;
            }
            
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
                Response = ToJson(Code, Message, dt);

                return Response;
            }
            catch (Exception ex)
            {
                /*Define return ex*/
                Code = false;
                Message = "Exception: " + ex;
                Response = ToJson(Code, Message);

                return Response;
            }
            
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
                Response = ToJson(Code, Message, dt);

                return Response;
            }
            catch (Exception ex)
            {
                /*Define return ex*/
                Code = false;
                Message = "Exception: " + ex;
                Response = ToJson(Code, Message);

                return Response;
            }
        }


        
        // ===================================================================================================
        // Class Convert To JSON
        // ===================================================================================================
        #region
        /**/
        public JsonResult ToJson(bool Code, string Message, DataTable dt, string NameObj = "Data")
        {
            DataTable dataTable = dt;
            var resultDictionary = new Dictionary<string, object>();

            try
            {

                // Agregar el campo "Code" al diccionario con el valor booleano
                resultDictionary.Add("Code", Code);

                // Agregar el campo "Mensaje" al diccionario con el valor del mensaje
                resultDictionary.Add("Mensaje", Message);

                // Obtener el resto de los datos del DataTable y agregarlos al diccionario
                var data = dataTable.AsEnumerable()
                    .Select(row =>
                    {
                        return row.Table.Columns.Cast<DataColumn>()
                            .ToDictionary(column => column.ColumnName, column => row[column]);
                    })
                    .ToList();

                // Agregar el arreglo de datos al diccionario con la clave "Data"
                resultDictionary.Add(NameObj, data);

                return new JsonResult(resultDictionary);

            }
            catch (Exception)
            {
                throw;
            }
        }

        public JsonResult ToJson(bool Code, string Message)
        {
            var resultDictionary = new Dictionary<string, object>();

            try
            {

                // Agregar el campo "Code" al diccionario con el valor booleano
                resultDictionary.Add("Code", Code);

                // Agregar el campo "Mensaje" al diccionario con el valor del mensaje
                resultDictionary.Add("Mensaje", Message);

                return new JsonResult(resultDictionary);

            }
            catch (Exception)
            {
                throw;
            }
        }

        #endregion

    }
}