using MyApi.Models.Horario;

namespace MyApi.Models.Horario
{
    #region Request Models

    public class DisponibilidadHorarioGetRequest
    {
        public int folioEmpleado { get; set; }
        public int idEntidad { get; set; }
        public int idSucursal { get; set; }
        public DateTime fecha { get; set; }
        public DateTime horaInicio { get; set; } 
        public DateTime horaFin { get; set; }
        public int? folioAgendaDetalleServicioExcluir { get; set; } = null;
    }

    public class DisponibilidadHorarioDetallesGetRequest
    {
        public int folioEmpleado { get; set; }
        public int idSucursal { get; set; }
        public int idEntidad { get; set; }
        public DateTime fecha { get; set; }
        public int intervaloMin { get; set; } = 30;
        public int? folioAgendaDetalleServicioExcluir { get; set; } = null;
        public bool incluirSlotsDisponibles { get; set; } = true;
        public bool soloDisponibles { get; set; } = false;
        public DateTime? horaInicio { get; set; } = null;
        public DateTime? horaFin { get; set; } = null;
    }

    public class EmpleadoHorarioGetRequest
    {
        public int folioEmpleado { get; set; }
        public int idEntidad { get; set; }
        public int idSucursal { get; set; }
    }

    public class DisponibilidadServicioGetRequest
    {
        public int idProductoServicio { get; set; } = 0;
        public DateTime fecha { get; set; } 
        public int intervaloMin { get; set; } 
        public int folioEmpleado { get; set; }
        public int idEntidad { get; set; }
        public int idSucursal { get; set; }
    }

    public class EmpleadoHorarioRequest
    {
        public int folioEmpleadoHorario { get; set; }
        public int folioEmpleado { get; set; }
        public int idSucursal { get; set; }
        public int diaSemana { get; set; }
        public string horaEntrada { get; set; } = "";
        public string horaSalida { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int activo { get; set; } = 1;
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }

    public class EmpleadoHorarioDeleteRequest
    {
        public int folioEmpleadoHorario { get; set; }
        public int idSucursal { get; set; }
        public int idEntidad { get; set; }
    }

    public class EmpleadoBloqueoGetRequest
    {
        public int folioEmpleado { get; set; }
        public int idSucursal { get; set; }
        public string fechaInicio { get; set; } = "";
        public string fechaFin { get; set; } = "";
        public int idEntidad { get; set; }
    }

    public class EmpleadoBloqueoRequest
    {
        public int folioEmpleadoBloqueoHorario { get; set; }
        public int folioEmpleado { get; set; }
        public int idSucursal { get; set; }
        public string fecha { get; set; } = "";
        public string horaInicio { get; set; } = "";
        public string horaFin { get; set; } = "";
        public int idTipoBloqueoHorario { get; set; }
        public string motivo { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int activo { get; set; } = 1;
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }

    public class EmpleadoBloqueoDeleteRequest
    {
        public int folioEmpleadoBloqueo { get; set; }
        public int idSucursal { get; set; }
        public int idEntidad { get; set; }
    }



    #endregion

}
