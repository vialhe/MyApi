using Microsoft.AspNetCore.Mvc;
using System.Data;
using MyApi.Models.MyDB;
using MyApi.Class.Tools;
using MyApi.Models.Horario;
using Microsoft.Data.SqlClient;
using MyApi.Controllers.MyTools;

namespace MyApi.Controllers.Agenda
{
    [ApiController]
    [Route("[controller]")]
    public class HorarioController : ControllerBase
    {
        
        public class EmpleadoHorarioGetRequest
        {
            public int folioEmpleado { get; set; }
            public int idEntidad { get; set; }
        }

        public class EmpleadoHorarioRequest
        {
            public int folioEmpleadoHorario { get; set; }
            public int folioEmpleado { get; set; }
            public int diaSemana { get; set; }
            public string horaEntrada { get; set; } = "";
            public string horaSalida { get; set; } = "";
            public string comentarios { get; set; } = "";
            public int activo { get; set; } = 1;
            public int idEntidad { get; set; }
            public int idUsuarioAlta { get; set; }
            public int idUsuarioModifica { get; set; }
        }

        public class EmpleadoHorarioDeleteRequest
        {
            public int id { get; set; }
            public string nombreTabla { get; set; } = "proc_empleadoHorario";
        }

        public class EmpleadoBloqueoGetRequest
        {
            public int folioEmpleado { get; set; }
            public string fechaInicio { get; set; } = "";
            public string fechaFin { get; set; } = "";
            public int idEntidad { get; set; }
        }

        public class EmpleadoBloqueoRequest
        {
            public int folioEmpleadoBloqueoHorario { get; set; }
            public int folioEmpleado { get; set; }
            public string fecha { get; set; } = "";
            public string horaInicio { get; set; } = "";
            public string horaFin { get; set; } = "";
            public int idTipoBloqueoHorario { get; set; }
            public string motivo { get; set; } = "";
            public string comentarios { get; set; } = "";
            public int activo { get; set; } = 1;
            public int idEntidad { get; set; }
            public int idUsuarioAlta { get; set; }
            public int idUsuarioModifica { get; set; }
        }

        public class EmpleadoBloqueoDeleteRequest
        {
            public int id { get; set; }
            public string nombreTabla { get; set; } = "proc_empleadoBloqueoHorario";
        }


        #region Horarios

        [HttpPost]
        [Route("get-empleado-horario")]
        public IActionResult GetEmpleadoHorario([FromBody] EmpleadoHorarioGetRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds;
            DataBase2 db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_se_empleadoHorario", true);
                db.AddParameter("folioEmpleado", request.folioEmpleado);
                db.AddParameter("idEntidad", request.idEntidad);

                ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds.Tables[0]);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Exception: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }

            return Response;
        }

        [HttpPost]
        [Route("insert-empleado-horario")]
        public IActionResult InsertEmpleadoHorario([FromBody] EmpleadoHorarioRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            request.folioEmpleadoHorario = 0;

            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("folioEmpleadoHorario", request.folioEmpleadoHorario.ToString()),
                    new Parametro("folioEmpleado", request.folioEmpleado.ToString()),
                    new Parametro("diaSemana", request.diaSemana.ToString()),
                    new Parametro("horaEntrada", request.horaEntrada),
                    new Parametro("horaSalida", request.horaSalida),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("activo", request.activo.ToString()),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioAlta.ToString())
                };

                dt = DataBase.Listar("sp_ui_empleadoHorario", parametros);

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, dt);
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
        [Route("update-empleado-horario")]
        public IActionResult UpdateEmpleadoHorario([FromBody] EmpleadoHorarioRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("folioEmpleadoHorario", request.folioEmpleadoHorario.ToString()),
                    new Parametro("folioEmpleado", request.folioEmpleado.ToString()),
                    new Parametro("diaSemana", request.diaSemana.ToString()),
                    new Parametro("horaEntrada", request.horaEntrada),
                    new Parametro("horaSalida", request.horaSalida),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("activo", request.activo.ToString()),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", request.idUsuarioModifica.ToString())
                };

                dt = DataBase.Listar("sp_ui_empleadoHorario", parametros);

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, dt);
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
        [Route("delete-empleado-horario")]
        public IActionResult DeleteEmpleadoHorario([FromBody] EmpleadoHorarioDeleteRequest request)
        {
            if (request.id <= 0)
                return BadRequest(MyToolsController.ToJson(false, "El ID proporcionado no es válido."));

            if (string.IsNullOrWhiteSpace(request.nombreTabla))
                request.nombreTabla = "proc_empleadoHorario";

            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("id", request.id.ToString()),
                    new Parametro("nombreTabla", request.nombreTabla)
                };

                DataBase.Ejecutar("sp_del_fromNameTable", parametros);

                return Ok(MyToolsController.ToJson(true, "Horario eliminado exitosamente."));
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

        #endregion

        #region Bloqueos

        [HttpPost]
        [Route("get-empleado-bloqueo")]
        public IActionResult GetEmpleadoBloqueo([FromBody] EmpleadoBloqueoGetRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds;
            DataBase2 db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_se_empleadoBloqueoHorario", true);
                db.AddParameter("folioEmpleado", request.folioEmpleado);
                db.AddParameter("fechaInicio", request.fechaInicio ?? "");
                db.AddParameter("fechaFin", request.fechaFin ?? "");
                db.AddParameter("idEntidad", request.idEntidad);

                ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds.Tables[0]);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Exception: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }

            return Response;
        }

        [HttpPost]
        [Route("insert-empleado-bloqueo")]
        public IActionResult InsertEmpleadoBloqueo([FromBody] EmpleadoBloqueoRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            request.folioEmpleadoBloqueoHorario = 0;

            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("folioEmpleadoBloqueoHorario", request.folioEmpleadoBloqueoHorario.ToString()),
                    new Parametro("folioEmpleado", request.folioEmpleado.ToString()),
                    new Parametro("fecha", request.fecha),
                    new Parametro("horaInicio", request.horaInicio),
                    new Parametro("horaFin", request.horaFin),
                    new Parametro("idTipoBloqueoHorario", request.idTipoBloqueoHorario.ToString()),
                    new Parametro("motivo", request.motivo ?? ""),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("activo", request.activo.ToString()),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioAlta.ToString())
                };

                dt = DataBase.Listar("sp_ui_empleadoBloqueoHorario", parametros);

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, dt);
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
        [Route("update-empleado-bloqueo")]
        public IActionResult UpdateEmpleadoBloqueo([FromBody] EmpleadoBloqueoRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("folioEmpleadoBloqueoHorario", request.folioEmpleadoBloqueoHorario.ToString()),
                    new Parametro("folioEmpleado", request.folioEmpleado.ToString()),
                    new Parametro("fecha", request.fecha),
                    new Parametro("horaInicio", request.horaInicio),
                    new Parametro("horaFin", request.horaFin),
                    new Parametro("idTipoBloqueoHorario", request.idTipoBloqueoHorario.ToString()),
                    new Parametro("motivo", request.motivo ?? ""),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("activo", request.activo.ToString()),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", request.idUsuarioModifica.ToString())
                };

                dt = DataBase.Listar("sp_ui_empleadoBloqueoHorario", parametros);

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, dt);
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
        [Route("delete-empleado-bloqueo")]
        public IActionResult DeleteEmpleadoBloqueo([FromBody] EmpleadoBloqueoDeleteRequest request)
        {
            if (request.id <= 0)
                return BadRequest(MyToolsController.ToJson(false, "El ID proporcionado no es válido."));

            if (string.IsNullOrWhiteSpace(request.nombreTabla))
                request.nombreTabla = "proc_empleadoBloqueoHorario";

            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("id", request.id.ToString()),
                    new Parametro("nombreTabla", request.nombreTabla)
                };

                DataBase.Ejecutar("sp_del_fromNameTable", parametros);

                return Ok(MyToolsController.ToJson(true, "Bloqueo eliminado exitosamente."));
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

        #endregion
    }
}