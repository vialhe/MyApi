namespace MyApi.Models.ProductoServicio
{
    public class ProductoServicio
    {
        public int id { get; set; }
        public int idTipoProductoServicio { get; set; }
        public string folioProductoServicio { get; set; } = "";
        public decimal precio { get; set; }
        public bool requiereSerie { get; set; }
        public bool requiereFechaCaducidad { get; set; }
        public bool requiereLote { get; set; }
        public int idUnidadMedidaCompra {get; set; }
        public int idUnidadMedidaVenta { get; set; }    
        public decimal stockMin { get; set; }
        public decimal stockMax { get; set; }
        public int idUnidadMedidaBase { get; set; }
        public bool requiereNumeracion { get; set; }
        public string descripcion { get; set; } = "";
        public bool recurrente { get; set; }
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public DateTime fechaModificacion { get; set; }
        public int idUsuarioModifica { get; set; }
        public DateTime fechaAlta { get; set; }
        public int idUsuarioAlta { get; set; }
        public decimal calificacion { get; set; } 
        public bool popular { get; set; }
        public int idTipoPrecio { get; set; }
        public decimal costo { get; set; }

    }
}
