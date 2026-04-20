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
            JsonResult Response;
            bool Code;
            string Message;

            DataTable dtAgenda;
            DataTable dtDetalle;
            int folioAgendaGenerado = 0;

            try
            {
                if (request.detalles == null || request.detalles.Count == 0)
                    return MyToolsController.ToJson(false, "La agenda debe contener al menos un detalle.");

                List<Parametro> parametrosAgenda = new List<Parametro>
                {
                    new Parametro("folioAgenda", "0"),
                    new Parametro("folioCliente", request.folioCliente.ToString()),
                    new Parametro("idSucursal", request.idSucursal.ToString()),
                    new Parametro("fechaCita", request.fechaCita),
                    new Parametro("horaInicioProgramada", request.horaInicioProgramada),
                    new Parametro("horaFinProgramada", request.horaFinProgramada),
                    new Parametro("idOrigenAgenda", request.idOrigenAgenda.ToString()),
                    new Parametro("requiereConfirmacion", request.requiereConfirmacion.ToString()),
                    new Parametro("observacionesInternas", request.observacionesInternas ?? ""),
                    new Parametro("comentarios", request.comentarios ?? ""),
                    new Parametro("activo", request.activo.ToString()),
                    new Parametro("idEntidad", request.idEntidad.ToString()),
                    new Parametro("idUsuarioAlta", request.idUsuarioAlta.ToString())
                };

                dtAgenda = DataBase.Listar("sp_ui_agenda", parametrosAgenda);

                if (dtAgenda.Rows.Count <= 0)
                    return MyToolsController.ToJson(false, "No fue posible generar la agenda.");

                folioAgendaGenerado = Convert.ToInt32(dtAgenda.Rows[0]["folioAgenda"]);

                foreach (var detalle in request.detalles)
                {
                    List<Parametro> parametrosDetalle = new List<Parametro>
                    {
                        new Parametro("folioAgendaDetalleServicio", "0"),
                        new Parametro("folioAgenda", folioAgendaGenerado.ToString()),
                        new Parametro("idProductoServicio", detalle.idProductoServicio.ToString()),
                        new Parametro("precioFinal", detalle.precioFinal.ToString()),
                        new Parametro("descuento", detalle.descuento.ToString()),
                        new Parametro("cantidad", detalle.cantidad.ToString()),
                        new Parametro("ordenServicio", detalle.ordenServicio.ToString()),
                        new Parametro("horaInicioProgramada", detalle.horaInicioProgramada),
                        new Parametro("horaFinProgramada", detalle.horaFinProgramada),
                        new Parametro("comentarios", detalle.comentarios ?? ""),
                        new Parametro("activo", detalle.activo.ToString()),
                        new Parametro("idEntidad", request.idEntidad.ToString()),
                        new Parametro("idUsuarioAlta", request.idUsuarioAlta.ToString())
                    };

                    dtDetalle = DataBase.Listar("sp_ui_agendaDetalleServicio", parametrosDetalle);

                    if (dtDetalle.Rows.Count <= 0)
                        return MyToolsController.ToJson(false, "No fue posible generar un detalle de la agenda.");

                    int folioAgendaDetalleServicio = Convert.ToInt32(dtDetalle.Rows[0]["folioAgendaDetalleServicio"]);

                    if (detalle.empleados != null && detalle.empleados.Count > 0)
                    {
                        foreach (var empleado in detalle.empleados)
                        {
                            List<Parametro> parametrosEmpleado = new List<Parametro>
                            {
                                new Parametro("folioAgendaDetalleServicioEmpleado", "0"),
                                new Parametro("folioAgendaDetalleServicio", folioAgendaDetalleServicio.ToString()),
                                new Parametro("folioEmpleado", empleado.folioEmpleado.ToString()),
                                new Parametro("idRolParticipacionServicio", empleado.idRolParticipacionServicio.ToString()),
                                new Parametro("porcentajeParticipacion", empleado.porcentajeParticipacion.ToString()),
                                new Parametro("comisionCalculada", empleado.comisionCalculada.ToString()),
                                new Parametro("horaInicioReal", empleado.horaInicioReal ?? ""),
                                new Parametro("horaFinReal", empleado.horaFinReal ?? ""),
                                new Parametro("comentarios", empleado.comentarios ?? ""),
                                new Parametro("activo", empleado.activo.ToString()),
                                new Parametro("idEntidad", request.idEntidad.ToString()),
                                new Parametro("idUsuarioAlta", request.idUsuarioAlta.ToString())
                            };

                            DataBase.Listar("sp_ui_agendaDetalleServicioEmpleado", parametrosEmpleado);
                        }
                    }
                }

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, dtAgenda);
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