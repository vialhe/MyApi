using MyApi.Models.MyDB;
using System.Text.Json.Serialization;

namespace MyApi.Models.Inventory
{
    public class InventoryH
    {
        public int folioMovimientoInventario { get; set; }
        public int idTipoMovimientoInventario { get; set; }
        public int? idDocumentoReferencia { get; set; }
        public int? idAlmacen { get; set; }
        public int? idMotivoMovimiento { get; set; }
        public int? idEstadoMovimiento { get; set; }
        public int? idPersona { get; set; } // Puede ser cliente o proveedor
        //public decimal? stockAntesMovimiento { get; set; }
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }

    public class InventoryD
    {
        public int folioMovimientoInventario { get; set; }
        public int idProductoServicio { get; set; }
        public decimal cantidad { get; set; }
        public int idUnidadMedida { get; set; }
        public decimal? costoUnitario { get; set; }
        public decimal? precioVentaUnitario { get; set; }
        public string? lote { get; set; }
        public string? serie { get; set; }
        public decimal? numeracion { get; set; }  
        public DateTime? fechaExpira { get; set; }
        public string comentarios { get; set; } = "";
        public bool activo { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }

    public class InventoryMovementData
    {
        public InventoryH? CInventoryH { get; set; }
        public List<InventoryD>? CInventoryD { get; set; }
    }
    public class InventoryUpdate
    {
        public int folioMovimientoInventario { get; set; }
        public int idProductoServicio { get; set; }
        public int idProveedor { get; set; }
        public decimal cantidad { get; set; }
        public int idUnidadMedida { get; set; }
        public int idTipoMovimientoInventario { get; set; } // 1: entrada, -1: salida
        public string? lote { get; set; }
        public string? serie { get; set; }
        public DateTime? fechaVencimiento { get; set; }
        public decimal? costoUnitario { get; set; }
        public decimal? precioVenta { get; set; }
        public decimal? numeracion { get; set; }
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }

    public class InventoryData
    {
        public InventoryH? CInventoryH { get; set; }
        public List<InventoryD>? CInventoryD { get; set; }
        public DataBase2? cDB { get; set; }
    }
    public class tipMovInvRequest
    {
        public int id { get; set; }
        public int idEntidad { get; set; }
        public int isAdmin { get; set; }
    }

public class KardexRequest
    {
        // Esto le dice a C#: "Busca en el JSON la clave 'idEntidad' exacta"
        [JsonPropertyName("idEntidad")]
        public int idEntidad { get; set; }

        [JsonPropertyName("fechaInicio")]
        public DateTime fechaInicio { get; set; }

        [JsonPropertyName("fechaFin")]
        public DateTime fechaFin { get; set; }
    }

}
