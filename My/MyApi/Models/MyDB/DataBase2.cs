using System;
using System.Data;
using Microsoft.Data.SqlClient;

namespace MyApi.Models.MyDB
{
    public class DataBase2 : IDisposable
    {
        private SqlConnection connection;
        private SqlCommand command;
        private SqlTransaction transaction;
        public static string cadenaConexion = "server=SQL5112.site4now.net;database=db_aa6711_bdmyst;User Id=db_aa6711_bdmyst_admin; Password=l12345678;";
        //private static string cadenaConexion = "server=PONCHO;database=db_a9b21d_prueba;User Id=dev; Password=admin; Integrated Security=True; TrustServerCertificate=True";

        public DataBase2(string connectionString ="")
        {
            connection = new SqlConnection(cadenaConexion);
            command = new SqlCommand();
            command.Connection = connection;
        }

        public void Open()
        {
            if (connection.State != ConnectionState.Open)
            {
                connection.Open();
            }
        }

        public void Close()
        {
            if (connection.State != ConnectionState.Closed)
            {
                connection.Close();
            }
        }

        public void BeginTransaction()
        {
            Open();
            transaction = connection.BeginTransaction();
            command.Transaction = transaction;
        }

        public void SetCommand(string storedProcedure, bool isStoredProcedure = true)
        {
            command.CommandType = isStoredProcedure ? CommandType.StoredProcedure : CommandType.Text;
            command.CommandText = storedProcedure;
        }

        public void AddParameter(string parameterName, object value)
        {
            command.Parameters.AddWithValue(parameterName, value);
        }

        public void Execute()
        {
            try
            {
                command.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                // Manejar la excepción según tus necesidades
                Console.WriteLine($"Error: {ex.Message}");
                //Rollback();
                throw;
            }
            finally
            {
                ClearParameters();
            }
        }

        public DataSet ExecuteWithDataSet()
        {
            try
            {
                using (SqlDataAdapter adapter = new SqlDataAdapter(command))
                {
                    DataSet dataSet = new DataSet();
                    adapter.Fill(dataSet);
                    return dataSet;
                }
            }
            catch (Exception ex)
            {
                // Manejar la excepción según tus necesidades
                Console.WriteLine($"Error: {ex.Message}");
                //Rollback();
                throw;
            }
            finally 
            {
                ClearParameters();
            }
        }

        public void Commit()
        {
            transaction.Commit();
            Close();
        }

        public void Rollback()
        {
            transaction.Rollback();
            Close();
        }

        public void Dispose()
        {
            if (transaction != null)
            {
                transaction.Dispose();
            }
            Close();
            connection.Dispose();
            command.Dispose();
        }

        public void ClearParameters()
        {
            command.Parameters.Clear(); 
            command.CommandText = ""; 
        }
    }

}