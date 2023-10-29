namespace MyApi.Models.Recurso
{
    public class Recurso
    {
        public int id { get; set; }
        public int idTabla { get; set; }
        public int idRegistro { get; set; } 
        public string descripcion { get; set; } = "";
        public byte[] recurso { get; set; } = { };
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public DateTime fechaModificacion { get; set; }
        public int idUsuarioModifica { get; set; }
        public DateTime fechaAlta { get; set; }
        public int idUsuarioAlta { get; set; }
    }
}
