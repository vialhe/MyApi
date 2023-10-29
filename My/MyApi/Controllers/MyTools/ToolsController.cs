using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace MyApi.Controllers.MyTools
{
    public class ToolsController : Controller
    {

        public DataTable RecursoPut() 
        {
            
            DataTable dt = new DataTable();
            return dt;
        }

        // ===================================================================================================
        // Class Convert To JSON
        // ===================================================================================================
        #region
        /**/
        public static JsonResult ToJson(bool Code, string Message, DataTable dt, string NameObj = "Data")
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

        public static JsonResult ToJson(bool Code, string Message)
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

        public static IActionResult ToJson(DataTable dt)
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
