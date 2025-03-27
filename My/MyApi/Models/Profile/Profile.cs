﻿namespace MyApi.Models.Profile
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
}
