using MyApi.Models.Catalogos;

namespace MyApi.Models.Catalogos
{
    #region Request Models

    public class CatalogoRequest
    {
        public int id { get; set; }
        public int idEntidad { get; set; }
        public int isAdmin { get; set; }
    }

    public class EmpleadoAgendaRequest
    {
        public int folioEmpleado { get; set; }
        public int idSucursal { get; set; }
        public int idEntidad { get; set; }
        public int activo { get; set; } = 1;
    }

    public class ServicioAgendaRequest
    {
        public int idProductoServicio { get; set; }
        public int idSucursal { get; set; }
        public int idEntidad { get; set; }
        public int activo { get; set; } = 1;
    }

    #endregion

}
