using MyApi.Models.Inventory;

namespace MyApi.Models.Sale
{
    public class SaleH
    {
        public int folioEntradaSalida { get; set; }
        public int folioMovimientoInventario { get; set; }
        public int idTipoEntradaSalida { get; set; } 
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }

    public class SaleD
    {
        public int idProductoServicio { get; set; }
        public decimal cantidad { get; set; }
        public decimal precioFinal { get; set; }
        public int idUnidadMedida { get; set; }
        public string comentarios { get; set; } = "";
    }

    public class SalePay
    {
        public int idTipoPago { get; set; }
        public decimal montoPago { get; set; }
        public string numeroAutorizacion { get; set; }
        public string comentarios { get; set; } = "";
    }
    public class SaleData
    {
        public SaleH? CSaleH { get; set; }
        public List<SaleD>? CSaleD { get; set; }
        public List<SalePay>? CSalePay { get; set; }
    }

    public class SaleAndInventoryData
    {
        public SaleData SaleData { get; set; }
        public InventoryData InventoryData { get; set; }
    }
}
