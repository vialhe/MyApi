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
        public static JsonResult ToJson(bool Code, string Message, DataTable dt, string NameObj = "Data")
        {
            DataTable dataTable = dt;
            var resultDictionary = new Dictionary<string, object>();

            try
            {
                resultDictionary.Add("Code", Code);
                resultDictionary.Add("Mensaje", Message);

                var data = dataTable.AsEnumerable()
                    .Select(row =>
                    {
                        return row.Table.Columns.Cast<DataColumn>()
                            .ToDictionary(column => column.ColumnName, column => row[column]);
                    })
                    .ToList();

                resultDictionary.Add(NameObj, data);

                return new JsonResult(resultDictionary);
            }
            catch (Exception)
            {
                throw;
            }
        }

        public static JsonResult ToJson(bool Code, string Message, DataSet dataSet)
        {
            var resultDictionary = new Dictionary<string, object>();

            try
            {
                resultDictionary.Add("Code", Code);
                resultDictionary.Add("Mensaje", Message);

                var data = new Dictionary<string, List<Dictionary<string, object>>>();

                foreach (DataTable table in dataSet.Tables)
                {
                    var tableData = table.AsEnumerable()
                        .Select(row =>
                        {
                            return row.Table.Columns.Cast<DataColumn>()
                                .ToDictionary(column => column.ColumnName, column => row[column]);
                        })
                        .ToList();

                    resultDictionary.Add(table.TableName, tableData);
                }

                //resultDictionary.Add("Data", data);

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
                resultDictionary.Add("Code", Code);
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
            DataTable dataTable = dt; 

            var jsonData = dataTable.AsEnumerable()
                .Select(row => row.Table.Columns.Cast<DataColumn>()
                    .ToDictionary(column => column.ColumnName, column => row[column]))
                .ToList();

            return new JsonResult(jsonData);
        }
    }
}
