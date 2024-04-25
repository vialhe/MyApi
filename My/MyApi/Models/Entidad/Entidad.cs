using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyApi.Models.User
{
    public class Entidad
    {
        public int id { get; set; }
        public string descripcion { get; set; } = "";
        public int idPadre { get; set; }
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public DateTime fechaModificacion { get; set; }
        public int idUsuarioModifica { get; set; }
        public DateTime fechaAlta { get; set; }
        public int idUsuarioAlta { get; set; }
    }
    public class EntidadRequest
    {
        public int id { get; set; }
        public int idEntidad { get; set; }
        public bool isAdmin { get; set; }
    }
}
