using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyApi.Class.Auth
{

    public class ValidaUsuario
    {
        public int id { get; set; }
        public string username { get; set; } = "";
        public string password { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int idUsuarioModifica { get; set; }

    }

}
