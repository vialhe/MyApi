using Microsoft.AspNetCore.Mvc;
using MyApi.Models.MyDB;
using MyApi.Models.ProductoServicio;
using MyApi.Models.User;
using System.Data;

namespace MyApi.Controllers.MyTools
{
    public class ToolsController : Controller
    {
        #region JSON 
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

        public static JsonResult ToJson(bool Code, string Message, DataTable dt, string Token , bool forLogin)
        {
            DataTable dataTable = dt;
            var resultDictionary = new Dictionary<string, object>();

            try
            {
                resultDictionary.Add("Code", Code);
                resultDictionary.Add("Mensaje", Message);
                resultDictionary.Add("Token", Token);

                var data = dataTable.AsEnumerable()
                    .Select(row =>
                    {
                        return row.Table.Columns.Cast<DataColumn>()
                            .ToDictionary(column => column.ColumnName, column => row[column]);
                    })
                    .ToList();

                resultDictionary.Add("table", data);

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

        public static IActionResult ToJson(DataTable dt)
        {
            DataTable dataTable = dt;

            var jsonData = dataTable.AsEnumerable()
                .Select(row => row.Table.Columns.Cast<DataColumn>()
                    .ToDictionary(column => column.ColumnName, column => row[column]))
                .ToList();

            return new JsonResult(jsonData);
        }


        #endregion

        #region Config 
        public DataTable generatFolio(int idFolio, int idEntidad, int idUsuarioModifica)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds = new DataSet();

            //Referencias
            DataBase2 db = new DataBase2();
            try
            {
                db.Open();

                db.SetCommand("sp_proc_generaFolio", true);
                db.AddParameter("idFolio", idFolio);
                db.AddParameter("idEntidad", idEntidad);
                db.AddParameter("idUsuarioModifica", idUsuarioModifica);

                ds = db.ExecuteWithDataSet();

                db.Close();
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
            }
            return ds.Tables[0];


        }

        public String generatFolio(int idFolio, int idEntidad, int idUsuarioModifica, DataBase2 db)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds = new DataSet();
            string? folioTraslado = "";
            //Referencias
            try
            {
                db.SetCommand("sp_proc_generaFolio", true);
                db.AddParameter("idFolio", idFolio);
                db.AddParameter("idEntidad", idEntidad);
                db.AddParameter("idUsuarioModifica", idUsuarioModifica);

                ds = db.ExecuteWithDataSet();
                folioTraslado = ds.Tables.Count > 0 ? ds.Tables[0].Rows[0]["nuevoFolio"].ToString() : "";
                db.ClearParameters();
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
            }
            return folioTraslado;
        }
        #endregion

        #region Class
        class Foliador 
        {
            private int idFolio { get; set; }
            private int idEntidad { get; set; }
            private int idUsuarioModifica { get; set; }

        }
        #endregion
    }
}
