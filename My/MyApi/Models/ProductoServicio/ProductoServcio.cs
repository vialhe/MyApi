﻿namespace MyApi.Models.ProductoServicio
{
    public class ProductoServicio
    {
        public int id { get; set; }
        public int idTipoProductoServicio { get; set; }
        public string folioProductoServicio { get; set; } = "";
        public decimal precio { get; set; }
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

    }
}
