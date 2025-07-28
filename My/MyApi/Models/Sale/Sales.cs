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
        public decimal montoTotalTicket { get; set; }
        public decimal pagoTotal { get; set; }
        public decimal totalDescuento { get; set; }
        public decimal montoSinDescuento { get; set; }
        public decimal suCambio { get; set; }
        public int folioCorteCaja { get; set; }
        public int folioCorteTienda { get; set; }
    }

    public class SaleD
    {
        public int idProductoServicio { get; set; }
        public decimal cantidad { get; set; }
        public decimal precioFinal { get; set; }
        public decimal precio { get; set; }
        public string lote { get; set; } = "";
        public decimal numeracion { get; set; }
        public DateTime? fechaExpira { get; set; }
        public string serie { get; set; } = "";
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

    public class RequestReporteVenta
    {
        public DateTime fechaInicio { get; set; }
        public DateTime fechaFin { get; set; }
        public int idEntidad { get; set; }
    }

    public class RequestGetCashRegister
    {
        public int idUsuarioIniciaCorte { get; set; }
        public int idEntidad { get; set; }
    }

    public class RequestInicioCorteDeCaja
    {
        public int idUsuario { get; set; }
        public int idCaja { get; set; }
        public decimal saldoInicial { get; set; }
        public int idEntidad { get;set; }

    }

    public class RequestCierreCorteDeCaja
    {
        public int idUsuario { get; set; }
        public int idCaja { get; set; }
        public decimal saldoFinal { get; set; }
        public int idEntidad { get; set; }
        public int folioCorteCaja { get; set; }
        public int folioCorteTienda { get; set; }
        public string? comentarios { get; set; } 

    }

    public class RequestCierreCorteDeTienda
    {
        public int idUsuario { get; set; }
        public int idEntidad { get; set; }
        public decimal saldoFinal { get; set; }
        public int folioCorteTienda { get; set; }

    }
}
