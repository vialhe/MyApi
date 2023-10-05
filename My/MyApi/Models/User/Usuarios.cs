using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyApi.Models.User
{
    public class Usuarios
    {
        public int id { get; set; }
        public int idPerfil { get; set; }
        public int idPersona { get; set; }
        public string usuario { get; set; } = "";
        public string password { get; set; } = "";
        public string salt { get; set; } = "";
        public string nombre { get; set; } = "";
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public DateTime fechaModificacion { get; set; }
        public int idUsuarioModifica { get; set; }
        public DateTime fechaAlta { get; set; }
        public int idUsuarioAlta { get; set; }
    }
}
