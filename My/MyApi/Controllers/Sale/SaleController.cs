using Microsoft.AspNetCore.Mvc;
using System.Data;
using MyApi.Models.MyDB;
using MyApi.Models.Sale;
using MyApi.Models.Inventory;
using MyApi.Controllers.Inventory;
using MyApi.Controllers.MyTools;
using static MyApi.Controllers.MyTools.MyToolsController;

namespace MyApi.Controllers.Sale
{
    [ApiController]
    [Route("[controller]")]
    public class SaleController : ControllerBase
    {


        [HttpPost]
        [Route("insert-sale")]
        public IActionResult SalePut(SaleData data)
        {
            if (data == null)
            {
                return BadRequest("Los datos de venta o inventario son nulos.");
            }
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            int idFoliadorEntradaSalida = 5; // FOLIO DE ENTRADA SALIDA
            int idFolioadorMovInv = 4; // FOLIO DE MOVIMIENTO INVETNARIO
            int idTipoMovInv = 1; //VENTA POR PUBLICO GENERAL
            string FolioEntradaSalida = "";
            string FolioMovimiento = "";
            SaleData saleData = data;
            

            //Referencias
            DataBase2 db = new DataBase2();
            MyToolsController tools = new MyToolsController();
            InventoryController invmov = new InventoryController();
            InventoryData inventoryData = new InventoryData();
            InventoryH inventoryH = new InventoryH();

            
            SaleH? cSaleH = saleData.CSaleH;
            List<SaleD>? cSaleD = saleData.CSaleD;
            List<SalePay>? cSalePay = saleData.CSalePay;

            InventoryH cMovInvH = new InventoryH();
            List<InventoryD>? cMovInvD = new List<InventoryD>();
            inventoryData.cDB = db;

            try
            { 
                db.BeginTransaction();

                FolioEntradaSalida = tools.generatFolio(idFoliadorEntradaSalida, cSaleH.idEntidad, cSaleH.idUsuarioModifica, db);
                FolioMovimiento = tools.generatFolio(idFolioadorMovInv, cSaleH.idEntidad, cSaleH.idUsuarioModifica, db);
                cSaleH.folioEntradaSalida = Convert.ToInt32(FolioEntradaSalida);
                cSaleH.folioMovimientoInventario = Convert.ToInt32(FolioMovimiento);

                cMovInvH.idTipoMovimientoInventario = idTipoMovInv;
                cMovInvH.folioMovimientoInventario = cSaleH.folioMovimientoInventario;
                cMovInvH.idDocumentoReferencia = cSaleH.folioEntradaSalida;
                cMovInvH.idAlmacen = cSaleH.idEntidad;
                cMovInvH.idMotivoMovimiento = 2; //Baja por venta
                cMovInvH.idEstadoMovimiento = 1; //Concluida
                cMovInvH.idEstadoMovimiento = 1; //Concluida
                cMovInvH.idPersona = 999; //Cliente genérico
                cMovInvH.idEntidad = cSaleH.idEntidad;
                cMovInvH.idUsuarioModifica = cSaleH.idUsuarioModifica;

                inventoryData.CInventoryH = cMovInvH;

                db.SetCommand("sp_in_entradasSalidas", true);
                db.AddParameter("@folioEntradaSalida", cSaleH.folioEntradaSalida);
                db.AddParameter("@folioMovimientoInventario", cSaleH.folioMovimientoInventario);
                db.AddParameter("@idTipoEntradaSalida", cSaleH.idTipoEntradaSalida);
                db.AddParameter("@comentarios", cSaleH.comentarios);
                db.AddParameter("@activo", cSaleH.activo);
                db.AddParameter("@idEntidad", cSaleH.idEntidad);
                db.AddParameter("@idUsuarioModifica", cSaleH.idUsuarioModifica);
                DataSet ds = db.ExecuteWithDataSet();
                ds.Tables[0].TableName = "Data";

                foreach (SaleD d in cSaleD) 
                {

                    db.SetCommand("sp_in_entradasSalidasDetalles", true);
                    db.AddParameter("@folioEntradaSalida", cSaleH.folioEntradaSalida);
                    db.AddParameter("@idProductoServicio", d.idProductoServicio);
                    db.AddParameter("@cantidad", d.cantidad);
                    db.AddParameter("@precioFinal", d.precioFinal);
                    db.AddParameter("@idUnidadMedida", d.idUnidadMedida);
                    db.AddParameter("@comentarios", d.comentarios);
                    db.AddParameter("@activo", cSaleH.activo);
                    db.AddParameter("@idEntidad", cSaleH.idEntidad);
                    db.AddParameter("@idUsuarioModifica", cSaleH.idUsuarioModifica);
                    db.Execute();

                    InventoryD invD = new InventoryD();

                    invD.idProductoServicio = d.idProductoServicio;
                    invD.cantidad = d.cantidad;
                    invD.idUnidadMedida = d.idUnidadMedida;
                    invD.precioVentaUnitario = d.precioFinal;
                    invD.comentarios = d.comentarios;
                    invD.idEntidad = cSaleH.idEntidad;
                    invD.idUsuarioModifica = cSaleH.idUsuarioModifica;
                    cMovInvD.Add(invD);
                }

                inventoryData.CInventoryD = cMovInvD;

                foreach (SalePay p in cSalePay)
                {
                    db.SetCommand("sp_in_entradasSalidasPago", true);
                    db.AddParameter("@folioEntradaSalida", cSaleH.folioEntradaSalida);
                    db.AddParameter("@idTipoPago", p.idTipoPago);
                    db.AddParameter("@montoPago", p.@montoPago);                    
                    db.AddParameter("@numeroAutorizacion", p.numeroAutorizacion);
                    db.AddParameter("@comentarios", p.comentarios);
                    db.AddParameter("@activo", cSaleH.activo);
                    db.AddParameter("@idEntidad", cSaleH.idEntidad);
                    db.AddParameter("@idUsuarioModifica", cSaleH.idUsuarioModifica);
                    db.Execute();
                }


                invmov.InventoryMovementPutSale(inventoryData);
                db.Commit();

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);

            }
            catch (Exception ex)
            {
                db.Rollback();
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }
            return Response;
        }
    }
}