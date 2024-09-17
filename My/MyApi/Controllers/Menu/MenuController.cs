using Microsoft.AspNetCore.Mvc;
using System.Data;
using Newtonsoft.Json;
using MyApi.Models.MyDB;
using MyApi.Class.Tools;
using MyApi.Models.User;
using MyApi.Models.ProductoServicio;
using System.Net.Http.Headers;
using MyApi.Controllers.MyTools;
using Microsoft.Extensions.ObjectPool;
using Microsoft.Data.SqlClient;

namespace MyApi.Controllers.Menu
{
    [ApiController]
    [Route("[controller]")]
    public class MenuController : ControllerBase
    {

        public class ProductoServicioRequest
        {
            public int Id { get; set; }
            public int IdEntidad { get; set; }
            public int IsAdmin { get; set; }
            public int idTipoProductoServicio { get; set; }
        }

        [HttpPost]
        [Route("get-productoservicio")]
        public IActionResult ProductoServicioGet([FromBody] ProductoServicioRequest request)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            // Referencias
            DataBase2 db = new DataBase2();
            try
            {
                db.Open();

                db.SetCommand("sp_se_productosServicio", true);
                db.AddParameter("id", request.Id);
                db.AddParameter("idEntidad", request.IdEntidad);
                db.AddParameter("isAdmin", request.IsAdmin);
                db.AddParameter("idTipoProductoServicio", request.idTipoProductoServicio);


                DataSet ds = db.ExecuteWithDataSet();

                db.Close();

                ds.Tables[0].TableName = "Data";
                ds.Tables[1].TableName = "Pager";

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);

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
        [Route("insert-productoservicio")]
        public IActionResult ProductoServicioPut(ProductoServicio cProductoServicio)
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
                    new Parametro("idUsuarioModifica", cProductoServicio.idUsuarioModifica.ToString()),
                    new Parametro("calificacion", cProductoServicio.calificacion.ToString()),
                    new Parametro("popular", cProductoServicio.popular.ToString())

                };
                
                dt = DataBase.Listar("sp_ui_productosServicios", parametros);

                Code = true;
                Message = "Succes";
                Response = MyToolsController.ToJson(Code,Message,dt);

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
        [Route("update-productoservicio")]
        public IActionResult ProductoServicioUpdate(ProductoServicio cProductoServicio)
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
                    new Parametro("calificacion", cProductoServicio.calificacion.ToString()),
                    new Parametro("popular", cProductoServicio.popular.ToString())
                };

                dt = DataBase.Listar("sp_ui_productosServicios", parametros);
                Code = true;
                Message = "Succes";
                Response = MyToolsController.ToJson(Code, Message,dt);

            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }
            return Response;


        }



        public class DeleteProductRequest
        {
            public int Id { get; set; }
            public string NombreTabla { get; set; }
        }

        [HttpPost]
        [Route("delete-productoservicio")]
        public IActionResult ProductoServicioDelete([FromBody] DeleteProductRequest request)
        {
            // Validar la entrada
            if (request.Id <= 0)
            {
                return BadRequest(MyToolsController.ToJson(false, "El ID proporcionado no es válido."));
            }

            if (string.IsNullOrWhiteSpace(request.NombreTabla))
            {
                request.NombreTabla = "cat_productosServicios";
            }

            try
            {
                // Iniciar proceso
                List<Parametro> parametros = new List<Parametro>
        {
            new Parametro("id", request.Id.ToString()),
            new Parametro("nombreTabla", request.NombreTabla)
        };

                DataBase.Ejecutar("sp_del_fromNameTable", parametros);

                // Retornar respuesta exitosa
                return Ok(MyToolsController.ToJson(true, "Producto eliminado exitosamente."));
            }
            catch (SqlException sqlEx)
            {
                return StatusCode(500, MyToolsController.ToJson(false, "Error en la base de datos: " + sqlEx.Message));
            }
            catch (Exception ex)
            {
                return StatusCode(500, MyToolsController.ToJson(false, "Ocurrió un error: " + ex.Message));
            }
        }




    }
}