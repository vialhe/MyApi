using Microsoft.AspNetCore.Mvc;
using System.Data;
using Newtonsoft.Json;
using MyApi.Models.MyDB;
using MyApi.Class.Tools;
using MyApi.Models.User;
using MyApi.Models.ProductoServicio;
using System.Net.Http.Headers;

namespace MyApi.Controllers.Menu
{
    [ApiController]
    [Route("[controller]")]
    public class MenuController : ControllerBase
    {

        [HttpPost]
        [Route("get-productoservicio")]
        public IActionResult ProductoServicioGet(int id = 0)
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

                dt = Models.MyDB.DataBase.Listar("sp_se_productosServicio", parametros);
                Code = true;
                Message = "Succes";
                Response = ToJson(Code, Message, dt);

            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = ToJson(Code, Message);
            }
            return Response;
        }

        [HttpPost]
        [Route("insert-productoservicio")]
        public IActionResult ProductoServicioPut(ProductoServcio cProductoServicio)
        {
            /*Se declaran Variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            cProductoServicio.id = 0;

            try
            {
                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", cProductoServicio.id.ToString()),
                    new Parametro("idTipoProductoServicio", cProductoServicio.idTipoProductoServicio.ToString()),
                    new Parametro("folioProductoServicio", cProductoServicio.folioProductoServicio.ToString()),
                    new Parametro("precio", cProductoServicio.precio.ToString()),
                    new Parametro("descripcion", cProductoServicio.descripcion.ToString()),
                    new Parametro("recurrente", cProductoServicio.recurrente.ToString()),
                    new Parametro("comentarios", cProductoServicio.comentarios.ToString()),
                    new Parametro("activo", cProductoServicio.activo.ToString()),
                    new Parametro("idEntidad", cProductoServicio.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", cProductoServicio.idUsuarioModifica.ToString())
                };
                
                dt = DataBase.Listar("sp_ui_productosServicios", parametros);

                Code = true;
                Message = "Succes";
                Response = ToJson(Code,Message,dt);

            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = ToJson(Code, Message);
            }
            return Response;

            
        }

        [HttpPost]
        [Route("update-productoservicio")]
        public IActionResult ProductoServicioUpdate(ProductoServcio cProductoServicio)
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
                    new Parametro("id", cProductoServicio.id.ToString()),
                    new Parametro("idTipoProductoServicio", cProductoServicio.idTipoProductoServicio.ToString()),
                    new Parametro("folioProductoServicio", cProductoServicio.folioProductoServicio.ToString()),
                    new Parametro("precio", cProductoServicio.precio.ToString()),
                    new Parametro("descripcion", cProductoServicio.descripcion.ToString()),
                    new Parametro("recurrente", cProductoServicio.recurrente.ToString()),
                    new Parametro("comentarios", cProductoServicio.comentarios.ToString()),
                    new Parametro("activo", cProductoServicio.activo.ToString()),
                    new Parametro("idEntidad", cProductoServicio.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", cProductoServicio.idUsuarioModifica.ToString()),
                };

                dt = DataBase.Listar("sp_ui_productosServicios", parametros);
                Code = true;
                Message = "Succes";
                Response = ToJson(Code, Message, dt);

            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = ToJson(Code, Message);
            }
            return Response;


        }

        

        [HttpPost]
        [Route("delete-productoservicio")]
        public IActionResult ProductoServicioDelete(int id = 0)
        {
            /*Declara variables*/

            /*Inicia proceso*/
            List<Parametro> parametros = new List<Parametro>{
                new Parametro("id", id.ToString())
            };
            DataTable dt = Models.MyDB.DataBase.Listar("sp_delete_productoservicio", parametros);

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