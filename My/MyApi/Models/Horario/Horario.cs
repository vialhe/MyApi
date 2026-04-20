using MyApi.Models.Horario;

namespace MyApi.Models.Horario
{
    #region Request Models

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

    #endregion

}
