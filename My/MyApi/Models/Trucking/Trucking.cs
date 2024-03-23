namespace MyApi.Models.Trucking
{
    public class TruckingH
    {
        public int folioTraslado { get; set; }
        public int folioMovimientoInventario { get; set; }
        public int idUbicacionOrigen { get; set; }
        public int idUbicacionDestino { get; set; }
        public int idVehiculo { get; set; } 
        public int idEstadoTraslado { get; set; }
        public int idTipoRegistro { get; set; }
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }

    public class TruckingD
    {
        public int idProductoServicio { get; set; }
        public int idUnidadMedida{ get; set; }
        public decimal cantidad { get; set; }
        public string comentarios { get; set; } = "";
    }
    public class TruckingData
    {
        public TruckingH? CTrasladoH { get; set; }
        public List<TruckingD>? CTrasladoD { get; set; }
    }
}
