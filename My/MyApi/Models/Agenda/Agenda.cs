using MyApi.Models.Agenda;

namespace MyApi.Models.Agenda
{
    #region Request Models

    public class AgendaByFolioRequest
    {
        public int folioAgenda { get; set; }
        public int idEntidad { get; set; }
    }

    public class AgendaDisponibilidadRequest
    {
        public int idProductoServicio { get; set; }
        public string fecha { get; set; } = "";
        public int folioEmpleado { get; set; }
        public int intervaloMin { get; set; } = 60;
        public int idEntidad { get; set; }
    }

    public class AgendaDisponibilidadEmpleadoRequest
    {
        public int folioEmpleado { get; set; }
        public string fecha { get; set; } = "";
        public string horaInicio { get; set; } = "";
        public string horaFin { get; set; } = "";
        public int? folioAgendaDetalleServicioExcluir { get; set; }
        public int idEntidad { get; set; }
    }

    public class AgendaDetailEmployeeRequest
    {
        public int folioEmpleado { get; set; }
        public int idRolParticipacionServicio { get; set; }
        public decimal porcentajeParticipacion { get; set; }
        public decimal comisionCalculada { get; set; }
        public string? horaInicioReal { get; set; }
        public string? horaFinReal { get; set; }
        public string comentarios { get; set; } = "";
        public int activo { get; set; } = 1;
    }

    public class AgendaDetailCreateRequest
    {
        public int idProductoServicio { get; set; }
        public decimal precioFinal { get; set; }
        public decimal descuento { get; set; }
        public decimal cantidad { get; set; }
        public int ordenServicio { get; set; }
        public string horaInicioProgramada { get; set; } = "";
        public string horaFinProgramada { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int activo { get; set; } = 1;
        public List<AgendaDetailEmployeeRequest> empleados { get; set; } = new List<AgendaDetailEmployeeRequest>();
    }

    public class AgendaCreateRequest
    {
        public int folioCliente { get; set; }
        public int idSucursal { get; set; }
        public string fechaCita { get; set; } = "";
        public string horaInicioProgramada { get; set; } = "";
        public string horaFinProgramada { get; set; } = "";
        public int idOrigenAgenda { get; set; }
        public int requiereConfirmacion { get; set; } = 1;
        public string observacionesInternas { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int activo { get; set; } = 1;
        public int idEntidad { get; set; }
        public int idUsuarioAlta { get; set; }
        public List<AgendaDetailCreateRequest> detalles { get; set; } = new List<AgendaDetailCreateRequest>();
    }

    public class AgendaConfirmRequest
    {
        public int folioAgenda { get; set; }
        public string comentarios { get; set; } = "";
        public int idEntidad { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class AgendaPaymentRequest
    {
        public int folioAgenda { get; set; }
        public int idTipoMovimientoPagoAgenda { get; set; }
        public int idTipoPago { get; set; }
        public decimal montoPago { get; set; }
        public string? numeroAutorizacion { get; set; }
        public string? referenciaOperacion { get; set; }
        public string referenciaExterna { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int idEntidad { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class AgendaDetailStatusRequest
    {
        public int folioAgendaDetalleServicio { get; set; }
        public int idEstatusAgendaDetalleServicioNuevo { get; set; }
        public string descripcionMovimiento { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int idEntidad { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class AgendaStatusRequest
    {
        public int folioAgenda { get; set; }
        public int idEstatusAgendaNuevo { get; set; }
        public string descripcionMovimiento { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int idEntidad { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class AgendaReprogramRequest
    {
        public int folioAgenda { get; set; }
        public string fechaHoraNuevaInicio { get; set; } = "";
        public string fechaHoraNuevaFin { get; set; } = "";
        public string motivo { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int idEntidad { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class DetalleAgendaReprogramRequest
    {
        public int folioAgendaDetalleServicio { get; set; }
        public string fechaHoraNuevaInicio { get; set; } = "";
        public string fechaHoraNuevaFin { get; set; } = "";
        public int? folioEmpleadoNuevo { get; set; } = null; 
        public string motivo { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int idEntidad { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class AgendaCancelRequest
    {
        public int folioAgenda { get; set; }
        public string motivoCancelacion { get; set; } = "";
        public int cancelarDetalles { get; set; } = 1;
        public int idEntidad { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class AgendaCancelDetailRequest
    {
        public int folioAgendaDetalleServicio { get; set; }
        public string motivoCancelacion { get; set; } = "";
        public int idEntidad { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    #endregion
}
