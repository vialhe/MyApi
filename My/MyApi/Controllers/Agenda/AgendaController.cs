using Microsoft.AspNetCore.Mvc;
using System.Data;
using MyApi.Models.MyDB;
using MyApi.Class.Tools;
using MyApi.Models.Agenda;
using Microsoft.Data.SqlClient;
using MyApi.Controllers.MyTools;

namespace MyApi.Controllers.Agenda
{
    [ApiController]
    [Route("[controller]")]
    public class AgendaController : ControllerBase
    {

        #region Operaciones

        [HttpPost]
        [Route("insert-agenda")]
        public IActionResult InsertAgenda([FromBody] AgendaCreateRequest request)
        {
            JsonResult response;
            DataTable dtAgenda = new DataTable();
            DataTable dtDetalle = new DataTable();
            int folioAgendaGenerado = 0;

            var db = new DataBase2();

            try
            {
                if (request == null || request.detalles == null || request.detalles.Count == 0)
                    return MyToolsController.ToJson(false, "La agenda debe contener al menos un detalle.");

                db.BeginTransaction();

                // =========================
                // 1) INSERTA AGENDA
                // =========================
                db.SetCommand("sp_ui_agenda", true);
                db.AddParameter("@folioAgenda", 0);
                db.AddParameter("@folioCliente", request.folioCliente);
                db.AddParameter("@idSucursal", request.idSucursal);
                db.AddParameter("@fechaCita", request.fechaCita);
                db.AddParameter("@horaInicioProgramada", request.horaInicioProgramada);
                db.AddParameter("@horaFinProgramada", request.horaFinProgramada);
                db.AddParameter("@idOrigenAgenda", request.idOrigenAgenda);
                db.AddParameter("@requiereConfirmacion", request.requiereConfirmacion);
                db.AddParameter("@observacionesInternas", request.observacionesInternas ?? "");
                db.AddParameter("@comentarios", request.comentarios ?? "");
                db.AddParameter("@activo", request.activo);
                db.AddParameter("@idEntidad", request.idEntidad);
                db.AddParameter("@idUsuarioAlta", request.idUsuarioAlta);

                // Usa aquí el método de DataBase2 que te retorna DataTable
                dtAgenda = db.ExecuteWithDataSet().Tables[0];

                if (dtAgenda == null || dtAgenda.Rows.Count <= 0)
                    throw new Exception("No fue posible generar la agenda.");

                folioAgendaGenerado = Convert.ToInt32(dtAgenda.Rows[0]["folioAgenda"]);

                // =========================
                // 2) INSERTA DETALLES
                // =========================
                foreach (var detalle in request.detalles)
                {
                    db.SetCommand("sp_ui_agendaDetalleServicio", true);
                    db.AddParameter("@folioAgendaDetalleServicio", 0);
                    db.AddParameter("@folioAgenda", folioAgendaGenerado);
                    db.AddParameter("@idProductoServicio", detalle.idProductoServicio);
                    db.AddParameter("@precioFinal", detalle.precioFinal);
                    db.AddParameter("@descuento", detalle.descuento);
                    db.AddParameter("@cantidad", detalle.cantidad);
                    db.AddParameter("@ordenServicio", detalle.ordenServicio);
                    db.AddParameter("@horaInicioProgramada", detalle.horaInicioProgramada);
                    db.AddParameter("@horaFinProgramada", detalle.horaFinProgramada);
                    db.AddParameter("@comentarios", detalle.comentarios ?? "");
                    db.AddParameter("@activo", detalle.activo);
                    db.AddParameter("@idEntidad", request.idEntidad);
                    db.AddParameter("@idUsuarioAlta", request.idUsuarioAlta);

                    dtDetalle = db.ExecuteWithDataSet().Tables[0];

                    if (dtDetalle == null || dtDetalle.Rows.Count <= 0)
                        throw new Exception("No fue posible generar un detalle de la agenda.");

                    int folioAgendaDetalleServicio = Convert.ToInt32(dtDetalle.Rows[0]["folioAgendaDetalleServicio"]);

                    // =========================
                    // 3) INSERTA EMPLEADOS
                    // =========================
                    if (detalle.empleados != null && detalle.empleados.Count > 0)
                    {
                        foreach (var empleado in detalle.empleados)
                        {
                            db.SetCommand("sp_ui_agendaDetalleServicioEmpleado", true);
                            db.AddParameter("@folioAgendaDetalleServicioEmpleado", 0);
                            db.AddParameter("@folioAgendaDetalleServicio", folioAgendaDetalleServicio);
                            db.AddParameter("@folioEmpleado", empleado.folioEmpleado);
                            db.AddParameter("@idRolParticipacionServicio", empleado.idRolParticipacionServicio);
                            db.AddParameter("@porcentajeParticipacion", empleado.porcentajeParticipacion);
                            db.AddParameter("@comisionCalculada", empleado.comisionCalculada);
                            db.AddParameter("@horaInicioReal", empleado.horaInicioReal ?? "");
                            db.AddParameter("@horaFinReal", empleado.horaFinReal ?? (object)DBNull.Value);
                            db.AddParameter("@comentarios", string.IsNullOrWhiteSpace(empleado.comentarios) ? (object)DBNull.Value : empleado.comentarios);
                            db.AddParameter("@activo", empleado.activo);
                            db.AddParameter("@idEntidad", request.idEntidad);
                            db.AddParameter("@idUsuarioAlta", request.idUsuarioAlta);

                            db.Execute();
                        }
                    }
                }

                db.Commit();
                response = MyToolsController.ToJson(true, "Success", dtAgenda);
            }
            catch (Exception ex)
            {
                try
                {
                    db.Rollback();
                }
                catch
                {
                }

                response = MyToolsController.ToJson(false, "Ex: " + ex.Message);
            }

            return response;
        }

        [HttpPost]
        [Route("confirm-agenda")]
        public IActionResult ConfirmAgenda([FromBody] AgendaConfirmRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("folioAgenda", request.folioAgenda.ToString()),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioAlta.ToString())
                };

                dt = DataBase.Listar("sp_ui_confirmarAgenda", parametros);

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
        [Route("register-agenda-payment")]
        public IActionResult RegisterAgendaPayment([FromBody] AgendaPaymentRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("folioAgenda", request.folioAgenda.ToString()),
                    new Parametro("idTipoMovimientoPagoAgenda", request.idTipoMovimientoPagoAgenda.ToString()),
                    new Parametro("idTipoPago", request.idTipoPago.ToString()),
                    new Parametro("montoPago", request.montoPago.ToString()),
                    new Parametro("numeroAutorizacion", request.numeroAutorizacion ?? ""),
                    new Parametro("referenciaOperacion", request.referenciaOperacion ?? ""),
                    new Parametro("referenciaExterna", request.referenciaExterna ?? ""),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioAlta.ToString())
                };

                dt = DataBase.Listar("sp_ui_agendaPago", parametros);

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
        [Route("start-agenda-detail")]
        public IActionResult StartAgendaDetail([FromBody] AgendaDetailStatusRequest request)
        {
            return ChangeAgendaDetailStatus(request);
        }

        [HttpPost]
        [Route("finish-agenda-detail")]
        public IActionResult FinishAgendaDetail([FromBody] AgendaDetailStatusRequest request)
        {
            return ChangeAgendaDetailStatus(request);
        }

        private IActionResult ChangeAgendaDetailStatus(AgendaDetailStatusRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("folioAgendaDetalleServicio", request.folioAgendaDetalleServicio.ToString()),
                    new Parametro("idEstatusAgendaDetalleServicioNuevo", request.idEstatusAgendaDetalleServicioNuevo.ToString()),
                    new Parametro("descripcionMovimiento", request.descripcionMovimiento ?? ""),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioAlta.ToString())
                };

                dt = DataBase.Listar("sp_ui_agendaCambioEstatusDetalleServicio", parametros);

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
        [Route("finish-agenda")]
        public IActionResult FinishAgenda([FromBody] AgendaStatusRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("folioAgenda", request.folioAgenda.ToString()),
                    new Parametro("idEstatusAgendaNuevo", request.idEstatusAgendaNuevo.ToString()),
                    new Parametro("descripcionMovimiento", request.descripcionMovimiento ?? ""),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioAlta.ToString())
                };

                dt = DataBase.Listar("sp_ui_agendaCambioEstatus", parametros);

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
        [Route("reprogram-agenda")]
        public IActionResult ReprogramAgenda([FromBody] AgendaReprogramRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("folioAgenda", request.folioAgenda.ToString()),
                    new Parametro("fechaHoraNuevaInicio", request.fechaHoraNuevaInicio),
                    new Parametro("fechaHoraNuevaFin", request.fechaHoraNuevaFin),
                    new Parametro("motivo", request.motivo ?? ""),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioAlta.ToString())
                };

                dt = DataBase.Listar("sp_ui_agendaReprogramacion", parametros);

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
        [Route("cancel-agenda")]
        public IActionResult CancelAgenda([FromBody] AgendaCancelRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("folioAgenda", request.folioAgenda.ToString()),
                    new Parametro("motivoCancelacion", request.motivoCancelacion ?? ""),
                    new Parametro("cancelarDetalles", request.cancelarDetalles.ToString()),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioAlta.ToString())
                };

                dt = DataBase.Listar("sp_ui_cancelarAgenda", parametros);

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
        [Route("cancel-agenda-detail")]
        public IActionResult CancelAgendaDetail([FromBody] AgendaCancelDetailRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                List<Parametro> parametros = new List<Parametro>
                {
                    new Parametro("folioAgendaDetalleServicio", request.folioAgendaDetalleServicio.ToString()),
                    new Parametro("motivoCancelacion", request.motivoCancelacion ?? ""),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioAlta.ToString())
                };

                dt = DataBase.Listar("sp_ui_cancelarDetalleServicio", parametros);

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

        #endregion
    }
}