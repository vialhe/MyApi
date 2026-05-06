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

            try
            {
                ds = ExecuteDataSet("sp_se_empleadoHorario", db =>
                {
                    db.AddParameter("folioEmpleado", request.folioEmpleado);
                    db.AddParameter("idSucursal", request.idSucursal);
                    db.AddParameter("idEntidad", request.idEntidad);
                    db.AddParameter("fechaInicio", request.fechaInicio);
                    db.AddParameter("fechaFin", request.fechaFin);
                });

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
        [Route("get-disponibilidad-servicio")]
        public IActionResult GetDisponibilidadServicio([FromBody] DisponibilidadServicioGetRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds;

            try
            {
                ds = ExecuteDataSet("sp_se_horariosDisponiblesServicio", db =>
                {
                    db.AddParameter("idProductoServicio", request.idProductoServicio);
                    db.AddParameter("fecha", request.fecha);
                    db.AddParameter("folioEmpleado", request.folioEmpleado);
                    db.AddParameter("idSucursal", request.idSucursal);
                    db.AddParameter("intervaloMin", request.intervaloMin);
                    db.AddParameter("idEntidad", request.idEntidad);
                });

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

            try
            {
                ds = ExecuteDataSet("sp_se_disponibilidadEmpleado", db =>
                {
                    db.AddParameter("folioEmpleado", request.folioEmpleado);
                    db.AddParameter("idSucursal", request.idSucursal);
                    db.AddParameter("fecha", request.fecha);
                    db.AddParameter("horaInicio", request.horaInicio);
                    db.AddParameter("horaFin", request.horaFin);
                    db.AddParameter("idEntidad", request.idEntidad);
                    db.AddParameter("folioAgendaDetalleServicioExcluir", request.folioAgendaDetalleServicioExcluir);
                });

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

            try
            {
                ds = ExecuteDataSet("sp_se_disponibilidadEmpleadoDetalle", db =>
                {
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
                });

                if (ds.Tables.Count == 4)
                {
                    ds.Tables[0].TableName = "Horario";
                    ds.Tables[1].TableName = "BloqueHorario";
                    ds.Tables[2].TableName = "Agenda";
                    ds.Tables[3].TableName = "Disponibilidad";
                }
                else
                {
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
                dt = ExecuteDataTable("sp_ui_empleadoHorario", db =>
                {
                    db.AddParameter("folioEmpleadoHorario", request.folioEmpleadoHorario);
                    db.AddParameter("folioEmpleado", request.folioEmpleado);
                    db.AddParameter("idSucursal", request.idSucursal);
                    db.AddParameter("diaSemana", request.diaSemana);
                    db.AddParameter("horaEntrada", request.horaEntrada);
                    db.AddParameter("horaSalida", request.horaSalida);
                    db.AddParameter("comentarios", request.comentarios ?? "");
                    db.AddParameter("activo", request.activo);
                    db.AddParameter("idEntidad", request.idEntidad);
                    db.AddParameter("idUsuarioAlta", request.idUsuarioModifica);
                });

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
                dt = ExecuteDataTable("sp_ui_empleadoHorario", db =>
                {
                    db.AddParameter("folioEmpleadoHorario", request.folioEmpleadoHorario);
                    db.AddParameter("folioEmpleado", request.folioEmpleado);
                    db.AddParameter("idSucursal", request.idSucursal);
                    db.AddParameter("diaSemana", request.diaSemana);
                    db.AddParameter("horaEntrada", request.horaEntrada);
                    db.AddParameter("horaSalida", request.horaSalida);
                    db.AddParameter("comentarios", request.comentarios ?? "");
                    db.AddParameter("activo", request.activo);
                    db.AddParameter("idEntidad", request.idEntidad);
                    db.AddParameter("idUsuarioAlta", request.idUsuarioModifica);
                });

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
                ExecuteNonQuery("sp_del_empleadoHorario", db =>
                {
                    db.AddParameter("folioEmpleadoHorario", request.folioEmpleadoHorario);
                    db.AddParameter("idSucursal", request.idSucursal);
                    db.AddParameter("idEntidad", request.idEntidad);
                });

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

            try
            {
                ds = ExecuteDataSet("sp_se_empleadoBloqueoHorario", db =>
                {
                    db.AddParameter("folioEmpleado", request.folioEmpleado);
                    db.AddParameter("idSucursal", request.idSucursal);
                    db.AddParameter("fechaInicio", request.fechaInicio ?? "");
                    db.AddParameter("fechaFin", request.fechaFin ?? "");
                    db.AddParameter("idEntidad", request.idEntidad);
                });

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
                dt = ExecuteDataTable("sp_ui_empleadoBloqueoHorario", db =>
                {
                    db.AddParameter("folioEmpleadoBloqueoHorario", request.folioEmpleadoBloqueoHorario);
                    db.AddParameter("folioEmpleado", request.folioEmpleado);
                    db.AddParameter("idSucursal", request.idSucursal);
                    db.AddParameter("fecha", request.fecha);
                    db.AddParameter("horaInicio", request.horaInicio);
                    db.AddParameter("horaFin", request.horaFin);
                    db.AddParameter("idTipoBloqueoHorario", request.idTipoBloqueoHorario);
                    db.AddParameter("motivo", request.motivo ?? "");
                    db.AddParameter("comentarios", request.comentarios ?? "");
                    db.AddParameter("activo", request.activo);
                    db.AddParameter("idEntidad", request.idEntidad);
                    db.AddParameter("idUsuarioAlta", request.idUsuarioModifica);
                });

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
                dt = ExecuteDataTable("sp_ui_empleadoBloqueoHorario", db =>
                {
                    db.AddParameter("folioEmpleadoBloqueoHorario", request.folioEmpleadoBloqueoHorario);
                    db.AddParameter("folioEmpleado", request.folioEmpleado);
                    db.AddParameter("idSucursal", request.idSucursal);
                    db.AddParameter("fecha", request.fecha);
                    db.AddParameter("horaInicio", request.horaInicio);
                    db.AddParameter("horaFin", request.horaFin);
                    db.AddParameter("idTipoBloqueoHorario", request.idTipoBloqueoHorario);
                    db.AddParameter("motivo", request.motivo ?? "");
                    db.AddParameter("comentarios", request.comentarios ?? "");
                    db.AddParameter("activo", request.activo);
                    db.AddParameter("idEntidad", request.idEntidad);
                    db.AddParameter("idUsuarioAlta", request.idUsuarioModifica);
                });

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
                ExecuteNonQuery("sp_del_empleadoBloqueoHorario", db =>
                {
                    db.AddParameter("folioEmpleadoBloqueoHorario", request.folioEmpleadoBloqueo);
                    db.AddParameter("idSucursal", request.idSucursal);
                    db.AddParameter("idEntidad", request.idEntidad);
                });

                Response = MyToolsController.ToJson(true, "Bloqueo eliminado exitosamente.");
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

        #region Empleado Sucursal

        [HttpPost]
        [Route("get-empleados")]
        public IActionResult GetEmpleados([FromBody] EmpleadosGetRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds;

            if (request == null)
                return BadRequest(MyToolsController.ToJson(false, "La petición no es válida."));

            if (request.idEntidad <= 0)
                return BadRequest(MyToolsController.ToJson(false, "La entidad es obligatoria."));

            try
            {
                ds = ExecuteDataSet("sp_se_empleados", db =>
                {
                    db.AddParameter("idEntidad", request.idEntidad);
                    db.AddParameter("soloActivos", request.soloActivos);
                    db.AddParameter("busqueda", request.busqueda ?? "");
                });

                if (ds.Tables.Count > 0)
                    ds.Tables[0].TableName = "Data";

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable());
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
        [Route("get-empleado-sucursal")]
        public IActionResult GetEmpleadoSucursal([FromBody] EmpleadoSucursalGetRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds;

            if (request == null)
                return BadRequest(MyToolsController.ToJson(false, "La petición no es válida."));

            if (request.folioEmpleado <= 0)
                return BadRequest(MyToolsController.ToJson(false, "El empleado es obligatorio."));

            if (request.idEntidad <= 0)
                return BadRequest(MyToolsController.ToJson(false, "La entidad es obligatoria."));

            try
            {
                ds = ExecuteDataSet("sp_se_empleadoSucursal", db =>
                {
                    db.AddParameter("folioEmpleado", request.folioEmpleado);
                    db.AddParameter("idEntidad", request.idEntidad);
                    db.AddParameter("soloActivos", request.soloActivos);
                });

                if (ds.Tables.Count > 0)
                    ds.Tables[0].TableName = "Data";

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable());
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
        [Route("get-empleados-by-sucursal")]
        public IActionResult GetEmpleadosBySucursal([FromBody] EmpleadosPorSucursalGetRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds;

            if (request == null)
                return BadRequest(MyToolsController.ToJson(false, "La petición no es válida."));

            if (request.idSucursal < 0)
                return BadRequest(MyToolsController.ToJson(false, "La sucursal no puede ser negativa."));

            if (request.idEntidad <= 0)
                return BadRequest(MyToolsController.ToJson(false, "La entidad es obligatoria."));

            try
            {
                ds = ExecuteDataSet("sp_se_empleadosPorSucursal", db =>
                {
                    db.AddParameter("idSucursal", request.idSucursal);
                    db.AddParameter("idEntidad", request.idEntidad);
                    db.AddParameter("soloActivos", request.soloActivos);
                });

                if (ds.Tables.Count > 0)
                    ds.Tables[0].TableName = "Data";

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds.Tables.Count > 0 ? ds.Tables[0] : new DataTable());
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
        [Route("save-empleado-sucursal")]
        public IActionResult SaveEmpleadoSucursal([FromBody] EmpleadoSucursalSaveRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds;

            if (request == null)
                return BadRequest(MyToolsController.ToJson(false, "La petición no es válida."));

            if (request.folioEmpleado <= 0)
                return BadRequest(MyToolsController.ToJson(false, "El empleado es obligatorio."));

            if (request.idEntidad <= 0)
                return BadRequest(MyToolsController.ToJson(false, "La entidad es obligatoria."));

            if (request.idUsuario <= 0)
                return BadRequest(MyToolsController.ToJson(false, "El usuario es obligatorio."));

            if (string.IsNullOrWhiteSpace(request.sucursalesJson))
                return BadRequest(MyToolsController.ToJson(false, "Debe enviar las sucursales del empleado."));

            try
            {
                ds = ExecuteDataSet("sp_ui_empleadoSucursal", db =>
                {
                    db.AddParameter("folioEmpleado", request.folioEmpleado);
                    db.AddParameter("idEntidad", request.idEntidad);
                    db.AddParameter("idUsuario", request.idUsuario);
                    db.AddParameter("sucursalesJson", request.sucursalesJson);
                });

                if (ds.Tables.Count > 0)
                    ds.Tables[0].TableName = "Data";

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
            }
            catch (SqlException sqlEx)
            {
                Code = false;
                Message = "Error en la base de datos: " + sqlEx.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Exception: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }

            return Response;
        }

        #endregion

        #region Helpers

        private DataSet ExecuteDataSet(string storedProcedure, Action<DataBase2> setParameters)
        {
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand(storedProcedure, true);
                setParameters(db);

                return db.ExecuteWithDataSet();
            }
            finally
            {
                db.Close();
            }
        }

        private DataTable ExecuteDataTable(string storedProcedure, Action<DataBase2> setParameters)
        {
            DataSet ds = ExecuteDataSet(storedProcedure, setParameters);

            if (ds == null || ds.Tables.Count == 0)
                return new DataTable();

            return ds.Tables[0];
        }

        private void ExecuteNonQuery(string storedProcedure, Action<DataBase2> setParameters)
        {
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand(storedProcedure, true);
                setParameters(db);
                db.Execute();
            }
            finally
            {
                db.Close();
            }
        }

        #endregion
    }
}