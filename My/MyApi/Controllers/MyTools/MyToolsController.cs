using Microsoft.AspNetCore.Mvc;
using MyApi.Models.MyDB;
using MyApi.Models.ProductoServicio;
using MyApi.Models.User;
using System.Data;

namespace MyApi.Controllers.MyTools
{
    public class MyToolsController : Controller
    {
        #region Cátalogos
        [HttpPost]
        [Route("get-empresa")]
        public IActionResult GetEmpresa(GenericReques rEmpresa)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            DataBase2 db = new DataBase2();


            try
            {
                db.SetCommand("sp_se_empresas", true);
                db.AddParameter("id", rEmpresa.id.ToString());
                db.AddParameter("idEntidad", rEmpresa.idEntidad.ToString());
                db.AddParameter("isAdmin", rEmpresa.isAdmin.ToString());

                /*Inicia proceso*/
                //List<Parametro> parametros = new List<Parametro>{
                //    new Parametro("id", rEntidad.id.ToString()),
                //    new Parametro("idEntidad", rEntidad.idEntidad.ToString()),
                //    new Parametro("isAdmin", rEntidad.isAdmin.ToString())
                //};
                //dt = DataBase.Listar("sp_se_entidad", parametros);

                /*Define return success*/

                dt = db.ExecuteWithDataSet().Tables[0];
                Code = true;
                Message = "Succes";
                Response = MyToolsController.ToJson(Code, Message, dt);

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
                        //return row.Table.Columns.Cast<DataColumn>()
                        //    .ToDictionary(column => column.ColumnName, column => row[column]);

                        // Crear un diccionario para cada fila de la tabla
                        var rowData = row.Table.Columns.Cast<DataColumn>()
                            .ToDictionary(column => column.ColumnName, column => row[column]);

                        // Filtrar los valores nulos en el diccionario de la fila
                        var filteredRowData = rowData.Where(kv => kv.Value != DBNull.Value)
                                                     .ToDictionary(kv => kv.Key, kv => kv.Value);

                        return filteredRowData;

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

                resultDictionary.Add("Data", data);

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

        public class GenericReques
        {
            public int id { get; set; }
            public int idEntidad { get; set; }
            public bool isAdmin { get; set; }
        }
        class Foliador 
        {
            private int idFolio { get; set; }
            private int idEntidad { get; set; }
            private int idUsuarioModifica { get; set; }

        }
        #endregion
    }
}
