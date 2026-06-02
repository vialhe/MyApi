namespace MyApi.Models.Profile
{
    public class Profile
    {
        public int id { get; set; }
        public string descripcion { get; set; } = "";
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public DateTime fechaModificacion { get; set; }
        public int idUsuarioModifica { get; set; }
        public DateTime fechaAlta { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class Persona
    {
        public int? id { get; set; }
        public int idTipoPersona { get; set; }
        public string nombre { get; set; } = "";
        public string apellidoPaterno { get; set; } = "";
        public string apellidoMaterno { get; set; } = "";
        public int idGenero { get; set; } 
        public DateTime fechaNacimiento { get; set; }
        public string correo { get; set; } = "";
        public string numeroTelefono { get; set; } = "";
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }

    public class Proveedor
    {
        public int? id { get; set; }
        public int idTipoPersona { get; set; }
        public string nombre { get; set; } = "";
        public string correo { get; set; } = "";
        public string numeroTelefono { get; set; } = "";
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }

    public class Cliente
    {
        public int? id { get; set; }
        public int idTipoPersona { get; set; }
        public string nombre { get; set; } = "";
        public string apellidoP { get; set; } = "";
        public string apellidoM { get; set; } = "";
        public string correo { get; set; } = "";
        public string numeroTelefono { get; set; } = "";
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }

    public class Empleado
    {
        public int? id { get; set; }
        public string nombre { get; set; } = "";
        public string usuario { get; set; } = "";
        public string apellidoP { get; set; } = "";
        public string apellidoM { get; set; } = "";
        public string correo { get; set; } = "";
        public string numeroTelefono { get; set; } = "";
        public DateTime fechaNacimiento { get; set; }
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
        public string fotoPreview { get; set; } = "";
        public string URLfotoPreview { get; set; } = "";
        public string habilidades { get; set; } = "";
        public string experiencia { get; set; } = "";
    }

    public class DelCliente
    {
        public int id { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioModificacion { get; set; }
    }


    public class Domicilio
    {
        public int id { get; set; }
        public int idPersona { get; set; }
        public int cp { get; set; }
        public int idEstado { get; set; } 
        public int idColonia { get; set; } 
        public int idMunicipio { get; set; } 
        public string calle { get; set; } 
        public int numExterior { get; set; }
        public int numInterior { get; set; }
        public string latitud { get; set; } = "";
        public string longitud { get; set; } = "";
        public string referencias { get; set; } 
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }

    public class catalogo
    {
        public int id { get; set; }
        public string descripcion { get; set; } = "";
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }

    #region sucurales
    public class Sucursal
    {
        public int idSucursal { get; set; }
        public string nombre { get; set; } = "";
        public string direccion { get; set; } = "";
        public string cp { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
        public int idTipoNegocioSucursal { get; set; }
        public bool activo { get; set; } = true;
        public string clave { get; set; } = "";
        public string logo { get; set; } = "";
        public string latitud { get; set; } = "";
        public string longitud { get; set; } = "";
    }

    public class GetSucursalRequest
    {
        public int idSucursal { get; set; } = 0;
        public int idEntidad { get; set; }
    }

    public class GetTipoSucursalRequest
    {
        public int id { get; set; } = 0;
        public int idEntidad { get; set; }
    }

    public class DelSucursalRequest
    {
        public int idSucursal { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }
    #endregion
}
