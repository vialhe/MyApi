using Microsoft.AspNetCore.Mvc;
using MyApi.Models.MyDB;
using System.Data;
using MyApi.Class.Auth;
using MyApi.Models.User;

namespace MyApi.Controllers.Auth
{
    [ApiController]
    [Route("[controller]")]
    public class AuthController : Controller
    {
       
        public DataTable GetVerifyUser(ValidaUsuario oUsuario)
        {
            /*Declara variables*/
            DataTable dt = new DataTable();

            /*Definiciones*/

            try
            {
                /*Definiciones de las variables*/

                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("user", oUsuario.usuario)

                };
                dt = DataBase.Listar("sp_proc_ValidaLogin", parametros);

                return dt;

            }
            catch (Exception)
            {
                /*Define return ex*/
                throw;
            }

        }

        
        [HttpPost]
        [Route("VerifySession")]
        public IActionResult VerifySession(ValidaUsuario user)
        {

            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dtUsuario = new DataTable();
            bool Verify = false;
            string Hash;

            /*Definicion de Variables*/
            try
            {
                /*Inicia proceso*/
                dtUsuario = GetVerifyUser(user);

                if (dtUsuario.Rows.Count > 0)
                {
                    Hash = BCrypt.Net.BCrypt.HashPassword(user.password, dtUsuario.Rows[0]["salt"].ToString());
                    Verify = dtUsuario.Rows[0]["hashpassword"].ToString() == Hash;
                }

                /*Define return */
                Code = Verify;
                Message = Verify ? "Succes" : "Acceso denegado";
                Response = ToJson(Code, Message);

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
        [Route("ChangePassword")]
        public IActionResult ChangePassword(ValidaUsuario Usuarios)
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

                Usuarios.password = BCrypt.Net.BCrypt.HashPassword(Usuarios.password,salt);

                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", Usuarios.id.ToString()),
                    new Parametro("usuario", Usuarios.usuario.ToString()),
                    new Parametro("password", Usuarios.password.ToString()),
                    new Parametro("salt", salt),
                    new Parametro("comentarios", Usuarios.comentarios.ToString()),
                    new Parametro("idUsuarioModifica", Usuarios.idUsuarioModifica.ToString())
                };

                dt = DataBase.Listar("sp_proc_UpdatePassword", parametros);

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
