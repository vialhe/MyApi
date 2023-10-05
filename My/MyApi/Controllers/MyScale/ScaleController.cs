using Microsoft.AspNetCore.Mvc;
using System.Data;
using Newtonsoft.Json;
using MyApi.Models.MyDB;
using MyApi.Class.Tools;
using MyApi.Models.User;

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

            /*Inicia proceso*/
            List<Parametro> parametros = new List<Parametro>{
                new Parametro("id", id.ToString())
            };
            DataTable dt = Models.MyDB.DataBase.Listar("sp_se_usuarios", parametros);

            return ToJson(dt);
        }

        [HttpPut]
        [Route("insert-scale")]
        public IActionResult UsuariosPut(Usuarios usuario)
        {
            /*Se declaran Variables*/
            usuario.id = 0;

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
            DataTable dt = DataBase.Listar("sp_ui_usuarios", parametros);

            return ToJson(dt);
        }

        [HttpPut]
        [Route("update-scale")]
        public IActionResult UsuariosUpdate(Usuarios usuario)
        {
            /*Se declaran variables*/

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
            DataTable dt = DataBase.Listar("sp_ui_usuarios", parametros);

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