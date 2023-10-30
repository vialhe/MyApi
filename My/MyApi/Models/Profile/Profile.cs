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
}
