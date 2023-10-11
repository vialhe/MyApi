using Microsoft.AspNetCore.Mvc;
using System.Data;
using Newtonsoft.Json;
using MyApi.Models.MyDB;
using MyApi.Class.Tools;
using MyApi.Models.User;
using Microsoft.AspNetCore.ResponseCompression;

namespace MyApi.Controllers.MyScale
{
    [ApiController]
    [Route("[controller]")]
    public class MenuController : ControllerBase
    {

        [HttpGet]
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
                Response = ToJson(Code, Message, dt);
            }
            catch (Exception ex)
            {
                /* Retorna error */
                Code = false;
                Message = "Ex:" + ex.Message;
                Response= ToJson(Code,Message);
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
                Response = ToJson(Code,Message,dt);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex;
                Response = ToJson(Code, Message);
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


            return ToJson(dt);
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
        public IActionResult ToJson(DataTable dt)
        {
            DataTable dataTable = dt; // Obtén tu DataTable aquí

            var jsonData = dataTable.AsEnumerable()
                .Select(row => row.Table.Columns.Cast<DataColumn>()
                    .ToDictionary(column => column.ColumnName, column => row[column]))
                .ToList();

            return new JsonResult(jsonData);
        }
    }
}