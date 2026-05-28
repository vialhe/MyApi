using MyApi.Models.Menu;

namespace MyApi.Models.Menu

{
    #region Tipos productos servicios Request Models

    public class TipoProductoServicioInsertRequest
    {
        public string descripcion { get; set; }
        public string comentarios { get; set; }
        public bool? activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuario { get; set; }
    }

    public class TipoProductoServicioUpdateRequest
    {
        public int id { get; set; }
        public string descripcion { get; set; }
        public string comentarios { get; set; }
        public bool? activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuario { get; set; }
    }

    public class TipoProductoServicioGetRequest
    {
        public int id { get; set; }
        public int idEntidad { get; set; }
        public bool soloActivos { get; set; } = true;
        public string busqueda { get; set; }
    }

    public class TipoProductoServicioDeleteRequest
    {
        public int id { get; set; }
        public int idEntidad { get; set; }
        public int idUsuario { get; set; }
    }

    #endregion

    #region Tipos negocio sucursal Request Models
    public class TipoNegocioSucursalInsertRequest
    {
        public string descripcion { get; set; }
        public string comentarios { get; set; }
        public bool? activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuario { get; set; }
    }

    public class TipoNegocioSucursalUpdateRequest
    {
        public int id { get; set; }
        public string descripcion { get; set; }
        public string comentarios { get; set; }
        public bool? activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuario { get; set; }
    }

    public class TipoNegocioSucursalGetRequest
    {
        public int id { get; set; }
        public int idEntidad { get; set; }
        public bool soloActivos { get; set; } = true;
        public string busqueda { get; set; }
    }

    public class TipoNegocioSucursalDeleteRequest
    {
        public int id { get; set; }
        public int idEntidad { get; set; }
        public int idUsuario { get; set; }
    }
    #endregion region
}
