using Microsoft.AspNetCore.Mvc;
using System.Data;
using Newtonsoft.Json;
using MyApi.Models.MyDB;
using MyApi.Class.Tools;
using MyApi.Models.User;
using MyApi.Models.ProductoServicio;

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

            /*Inicia proceso*/
            List<Parametro> parametros = new List<Parametro>{
                new Parametro("id", id.ToString())
            };
            DataTable dt = Models.MyDB.DataBase.Listar("sp_se_productoservicio", parametros);

            return ToJson(dt);
        }

        [HttpPost]
        [Route("insert-productoservicio")]
        public IActionResult ProductoServicioPut(ProductoServcio cProductoServicio)
        {
            /*Se declaran Variables*/
            cProductoServicio.id = 0;

            /*Inicia proceso*/
            List<Parametro> parametros = new List<Parametro>{
                new Parametro("id", cProductoServicio.id.ToString()),
                new Parametro("idTipoProductoServicio", cProductoServicio.idTipoProductoServicio.ToString()),
                new Parametro("folioProductoServicio", cProductoServicio.folioProductoServicio.ToString()),
                new Parametro("descripcion", cProductoServicio.descripcion.ToString()),
                new Parametro("recurrente", cProductoServicio.recurrente.ToString()),
                new Parametro("comentarios", cProductoServicio.comentarios.ToString()),
                new Parametro("activo", cProductoServicio.activo.ToString()),
                new Parametro("idEntidad", cProductoServicio.idEntidad.ToString()),
                new Parametro("idUsuarioModifica", cProductoServicio.idUsuarioModifica.ToString()),

            };
            DataTable dt = DataBase.Listar("sp_ui_productosServicios", parametros);

            return ToJson(dt);
        }

        [HttpPost]
        [Route("update-productoservicio")]
        public IActionResult ProductoServicioUpdate(ProductoServcio cProductoServicio)
        {
            /*Se declaran variables*/

            /*Inicia proceso*/
            List<Parametro> parametros = new List<Parametro>{
                new Parametro("id", cProductoServicio.id.ToString()),
                new Parametro("idTipoProductoServicio", cProductoServicio.idTipoProductoServicio.ToString()),
                new Parametro("folioProductoServicio", cProductoServicio.folioProductoServicio.ToString()),
                new Parametro("descripcion", cProductoServicio.descripcion.ToString()),
                new Parametro("recurrente", cProductoServicio.recurrente.ToString()),
                new Parametro("comentarios", cProductoServicio.comentarios.ToString()),
                new Parametro("activo", cProductoServicio.activo.ToString()),
                new Parametro("idEntidad", cProductoServicio.idEntidad.ToString()),
                new Parametro("idUsuarioModifica", cProductoServicio.idUsuarioModifica.ToString()),

            };
            DataTable dt = DataBase.Listar("sp_ui_productosServicios", parametros);

            return ToJson(dt);
        }

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