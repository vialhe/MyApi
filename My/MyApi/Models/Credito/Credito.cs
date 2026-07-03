namespace MyApi.Models.Credito
{
    // ------------------------------------------------------------------
    // A) Configuracion
    // ------------------------------------------------------------------
    public class ConfiguracionCreditoRequest
    {
        public int idEntidad { get; set; }
    }

    public class ConfiguracionCreditoGuardarRequest
    {
        public int idEntidad { get; set; }
        public string tipoValorRecargo { get; set; } = "";
        public string nivelAplicacion { get; set; } = "";
        public decimal valorRecargo { get; set; }
        public int diasVencimientoCargo { get; set; }
        public decimal limiteCreditoDefaultExpress { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    // ------------------------------------------------------------------
    // B) Cliente / limite
    // ------------------------------------------------------------------
    public class ClienteHabilitarRequest
    {
        public int idPersona { get; set; }
        public bool creditoHabilitado { get; set; }
        public decimal? limiteCredito { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class LimiteActualizarRequest
    {
        public int idPersona { get; set; }
        public decimal limiteNuevo { get; set; }
        public string motivo { get; set; } = "";
        public int idEntidad { get; set; }
        public int idSucursal { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    // ------------------------------------------------------------------
    // C) Nucleo transaccional
    // ------------------------------------------------------------------
    public class CarritoCreditoItem
    {
        public int idProductoServicio { get; set; }
        public decimal cantidad { get; set; }
        public decimal precio { get; set; }
    }

    public class CalcularRecargoRequest
    {
        public int idEntidad { get; set; }
        public List<CarritoCreditoItem> carrito { get; set; } = new List<CarritoCreditoItem>();
    }

    public class InsertCargoRequest
    {
        public int folioEntradaSalida { get; set; }
        public int idPersona { get; set; }
        public decimal montoConRecargo { get; set; }
        public int idEntidad { get; set; }
        public int idSucursal { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class PagoCredito
    {
        public int idTipoPago { get; set; }
        public decimal montoPago { get; set; }
        public string numeroAutorizacion { get; set; } = "";
    }

    public class InsertAbonoRequest
    {
        public int idPersona { get; set; }
        public List<PagoCredito> pagos { get; set; } = new List<PagoCredito>();
        public bool esLiquidacion { get; set; }
        public int idEntidad { get; set; }
        public int idSucursal { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class InsertAjusteRequest
    {
        public int idPersona { get; set; }
        public decimal monto { get; set; }
        public string motivo { get; set; } = "";
        public int idEntidad { get; set; }
        public int idSucursal { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class ReversaCargoRequest
    {
        public int folioEntradaSalida { get; set; }
        public int idEntidad { get; set; }
        public int idSucursal { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    // ------------------------------------------------------------------
    // D) Consulta / lectura
    // ------------------------------------------------------------------
    public class GetSaldoClienteRequest
    {
        public int idPersona { get; set; }
        public int idEntidad { get; set; }
    }

    public class GetHistorialClienteRequest
    {
        public int idPersona { get; set; }
        public int idEntidad { get; set; }
        public DateTime? fechaInicio { get; set; }
        public DateTime? fechaFin { get; set; }
        public string? clave { get; set; }
        public int pagina { get; set; } = 1;
        public int tamanoPagina { get; set; } = 50;
    }

    public class GetHistorialGlobalRequest
    {
        public int idEntidad { get; set; }
        public int? idSucursal { get; set; }
        public int? idUsuarioAlta { get; set; }
        public string? clave { get; set; }
        public DateTime? fechaInicio { get; set; }
        public DateTime? fechaFin { get; set; }
        public int pagina { get; set; } = 1;
        public int tamanoPagina { get; set; } = 50;
    }

    public class GetListadoClientesRequest
    {
        public int idEntidad { get; set; }
    }

    public class GetDashboardCreditoRequest
    {
        public int idEntidad { get; set; }
        public DateTime fechaInicio { get; set; }
        public DateTime fechaFin { get; set; }
    }
}
