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
                db.AddParameter("idSucursal", request.idSucursal);
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
        [Route("get-empleado-disponibilidad")]
        public IActionResult GetEmpleadoDisponibilidad([FromBody] DisponibilidadHorarioGetRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds;
            DataBase2 db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_se_disponibilidadEmpleado", true);
                db.AddParameter("folioEmpleado", request.folioEmpleado);
                db.AddParameter("idSucursal", request.idSucursal);
                db.AddParameter("fecha", request.fecha);
                db.AddParameter("horaInicio", request.horaInicio);
                db.AddParameter("horaFin", request.horaFin);
                db.AddParameter("idEntidad", request.idEntidad);
                db.AddParameter("folioAgendaDetalleServicioExcluir", request.folioAgendaDetalleServicioExcluir);

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
        [Route("get-empleado-disponibilidad-detalle")]
        public IActionResult GetEmpleadoDisponibilidadDetalle([FromBody] DisponibilidadHorarioDetallesGetRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds;
            DataBase2 db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_se_disponibilidadEmpleadoDetalle", true);
                db.AddParameter("folioEmpleado", request.folioEmpleado);
                db.AddParameter("idSucursal", request.idSucursal);
                db.AddParameter("fecha", request.fecha);
                db.AddParameter("horaInicio", request.horaInicio);
                db.AddParameter("horaFin", request.horaFin);
                db.AddParameter("idEntidad", request.idEntidad);
                db.AddParameter("folioAgendaDetalleServicioExcluir", request.folioAgendaDetalleServicioExcluir);
                db.AddParameter("intervaloMin", request.intervaloMin);
                db.AddParameter("incluirSlotsDisponibles", request.incluirSlotsDisponibles);
                db.AddParameter("soloDisponibles", request.soloDisponibles);

                ds = db.ExecuteWithDataSet();
                db.Close();

                if (ds.Tables.Count == 4)
                {
                    ds.Tables[0].TableName = "Horario";
                    ds.Tables[1].TableName = "BloqueHorario";
                    ds.Tables[2].TableName = "Agenda";
                    ds.Tables[3].TableName = "Disponibilidad";
                }
                else {
                    ds.Tables[0].TableName = "Data";
                }
                
    
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
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
                    new Parametro("idSucursal", request.idSucursal.ToString()),
                    new Parametro("diaSemana", request.diaSemana.ToString()),
                    new Parametro("horaEntrada", request.horaEntrada),
                    new Parametro("horaSalida", request.horaSalida),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("activo", request.activo.ToString()),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioModifica.ToString())
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
                    new Parametro("idSucursal", request.idSucursal.ToString()),
                    new Parametro("diaSemana", request.diaSemana.ToString()),
                    new Parametro("horaEntrada", request.horaEntrada),
                    new Parametro("horaSalida", request.horaSalida),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("activo", request.activo.ToString()),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioModifica.ToString())
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
            JsonResult Response;

            if (request.folioEmpleadoHorario <= 0)
                return BadRequest(MyToolsController.ToJson(false, "El Folio Horario proporcionado no es válido."));
            if (request.idSucursal <= 0)
                return BadRequest(MyToolsController.ToJson(false, "El ID Sucursal proporcionado no es válido."));
            if (request.idEntidad <= 0)
                return BadRequest(MyToolsController.ToJson(false, "El ID Entidad proporcionado no es válido."));


            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("folioEmpleadoHorario", request.folioEmpleadoHorario.ToString()),
                    new Parametro("idSucursal", request.idSucursal.ToString()),
                    new Parametro("idEntidad", request.idEntidad.ToString())
                };

                DataBase.Ejecutar("sp_del_empleadoHorario", parametros);

                Response = MyToolsController.ToJson(true, "Horario eliminado exitosamente.");
                return Response;
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
                db.AddParameter("idSucursal", request.idSucursal);
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
                    new Parametro("idSucursal", request.idSucursal.ToString()),
                    new Parametro("fecha", request.fecha),
                    new Parametro("horaInicio", request.horaInicio),
                    new Parametro("horaFin", request.horaFin),
                    new Parametro("idTipoBloqueoHorario", request.idTipoBloqueoHorario.ToString()),
                    new Parametro("motivo", request.motivo ?? ""),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("activo", request.activo.ToString()),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioModifica.ToString())
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
                    new Parametro("idSucursal", request.idSucursal.ToString()),
                    new Parametro("fecha", request.fecha),
                    new Parametro("horaInicio", request.horaInicio),
                    new Parametro("horaFin", request.horaFin),
                    new Parametro("idTipoBloqueoHorario", request.idTipoBloqueoHorario.ToString()),
                    new Parametro("motivo", request.motivo ?? ""),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("activo", request.activo.ToString()),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioModifica.ToString())
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
            JsonResult Response;

            if (request.folioEmpleadoBloqueo <= 0)
                return BadRequest(MyToolsController.ToJson(false, "El Folio Horario proporcionado no es válido."));
            if (request.idSucursal <= 0)
                return BadRequest(MyToolsController.ToJson(false, "El ID Sucursal proporcionado no es válido."));
            if (request.idEntidad <= 0)
                return BadRequest(MyToolsController.ToJson(false, "El ID Entidad proporcionado no es válido."));


            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("folioEmpleadoBloqueoHorario", request.folioEmpleadoBloqueo.ToString()),
                    new Parametro("idSucursal", request.idSucursal.ToString()),
                    new Parametro("idEntidad", request.idEntidad.ToString())
                };

                DataBase.Ejecutar("sp_del_empleadoBloqueoHorario", parametros);

                Response =  MyToolsController.ToJson(true, "Bloqueo eliminado exitosamente.");
                return Response;
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