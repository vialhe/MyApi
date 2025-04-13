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
            if (data == null || data.CSaleH == null || data.CSaleD == null || data.CSalePay == null)
            {
                return BadRequest("Los datos de venta no pueden ser nulos.");
            }
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            int idFoliadorEntradaSalida = 5; // FOLIO DE ENTRADA SALIDA
            int idFoliadorMovInv = 4; // FOLIO DE MOVIMIENTO INVETNARIO
            int idTipoMovInv = 2; //VENTA POR PUBLICO GENERAL
            int idTipoEntradaSalida = 3; //VENTA POR PUBLICO GENERAL
            string FolioEntradaSalida = "";
            string Message;
            string FolioMovimiento = "";
            

            //Referencias
            var db = new DataBase2();
            var tools = new MyToolsController();
            var invmov = new InventoryController();
            var inventoryData = new InventoryData();
            var cSaleH = data.CSaleH;
            var cSaleD = data.CSaleD;
            var cSalePay = data.CSalePay;
            var cMovInvH = new InventoryH();
            var cMovInvD = new List<InventoryD>();
            inventoryData.cDB = db;
            cSaleH.idTipoEntradaSalida = idTipoEntradaSalida;

            try
            { 
                db.BeginTransaction();

                FolioEntradaSalida = tools.generatFolio(idFoliadorEntradaSalida, cSaleH.idEntidad, cSaleH.idUsuarioModifica, db);
                FolioMovimiento = tools.generatFolio(idFoliadorMovInv, cSaleH.idEntidad, cSaleH.idUsuarioModifica, db);
                cSaleH.folioEntradaSalida = Convert.ToInt32(FolioEntradaSalida);
                cSaleH.folioMovimientoInventario = Convert.ToInt32(FolioMovimiento);

                inventoryData.CInventoryH = CreateInventoryHeader(cSaleH,idTipoMovInv);
                DataSet ds = ExecuteSaleHeader(db, cSaleH);

                foreach (SaleD d in cSaleD) 
                {
                    ExecuteSaleDetail(db,cSaleH,d);
                    cMovInvD.Add(CreateInventoryDetail(cSaleH, d));
                }
                inventoryData.CInventoryD = cMovInvD;

                foreach (SalePay p in cSalePay)
                {
                    ExecuteSalePayment(db,cSaleH,p);
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

        [HttpPost]
        [Route("open-cashregister")]
        public IActionResult OpenCashRegister(SaleData data)
        {
            if (data == null || data.CSaleH == null || data.CSaleD == null || data.CSalePay == null)
            {
                return BadRequest("Los datos de venta no pueden ser nulos.");
            }
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            int idFoliadorTienda = 6; // FOLIO DE ENTRADA SALIDA
            int idFoliadorCaja = 7; // FOLIO DE MOVIMIENTO INVETNARIO
            string Message;


            //Referencias
            var db = new DataBase2();
            var tools = new MyToolsController();
            var invmov = new InventoryController();
            var inventoryData = new InventoryData();
            var cSaleH = data.CSaleH;
            var cSaleD = data.CSaleD;
            var cSalePay = data.CSalePay;
            var cMovInvH = new InventoryH();
            var cMovInvD = new List<InventoryD>();
            inventoryData.cDB = db;

            try
            {
                db.BeginTransaction();

                //FolioEntradaSalida = tools.generatFolio(idFoliadorEntradaSalida, cSaleH.idEntidad, cSaleH.idUsuarioModifica, db);
                //FolioMovimiento = tools.generatFolio(idFoliadorMovInv, cSaleH.idEntidad, cSaleH.idUsuarioModifica, db);
                //cSaleH.folioEntradaSalida = Convert.ToInt32(FolioEntradaSalida);
                //cSaleH.folioMovimientoInventario = Convert.ToInt32(FolioMovimiento);

                //inventoryData.CInventoryH = CreateInventoryHeader(cSaleH, idTipoMovInv);
                DataSet ds = ExecuteSaleHeader(db, cSaleH);

                foreach (SaleD d in cSaleD)
                {
                    ExecuteSaleDetail(db, cSaleH, d);
                    cMovInvD.Add(CreateInventoryDetail(cSaleH, d));
                }
                inventoryData.CInventoryD = cMovInvD;

                foreach (SalePay p in cSalePay)
                {
                    ExecuteSalePayment(db, cSaleH, p);
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

        [HttpPost]
        [Route("get-cashregister")]
        public IActionResult GetCashRegister()
        {
            return Ok();
        }

        [HttpPost]
        [Route("get-storecash")]
        public IActionResult GetStoreCash()
        {
            return Ok();
        }

        [HttpPost]
        [Route("get-report-sale")]
        public IActionResult SaleReport(RequestReporteVenta data)
        {
            if (data == null )
            {
                return BadRequest("Las fechas no pueden nulas.");
            }
            /*Declara variables*/
            JsonResult Response;
            bool Code;            
            string Message;

            //Referencias
            var db = new DataBase2();
            var tools = new MyToolsController();
            try
            {
                db.Open();
                db.SetCommand("sp_se_reporteDeVentas", true);
                db.AddParameter("@fechaInicio", data.fechaInicio);
                db.AddParameter("@fechaFin", data.fechaFin);
                DataSet ds = db.ExecuteWithDataSet();
                ds.Tables[0].TableName = "Data";
                db.Close();
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
        private InventoryH CreateInventoryHeader(SaleH saleHeader, int idTipoMovInv)
        {
            return new InventoryH
            {
                idTipoMovimientoInventario = idTipoMovInv,
                folioMovimientoInventario = saleHeader.folioMovimientoInventario,
                idDocumentoReferencia = saleHeader.folioEntradaSalida,
                idAlmacen = saleHeader.idEntidad,
                idMotivoMovimiento = 2,
                idEstadoMovimiento = 1,
                idPersona = 999,
                idEntidad = saleHeader.idEntidad,
                idUsuarioModifica = saleHeader.idUsuarioModifica
            };
        }
        private DataSet ExecuteSaleHeader(DataBase2 db, SaleH saleHeader)
        {
            db.SetCommand("sp_in_entradasSalidas", true);
            db.AddParameter("@folioEntradaSalida", saleHeader.folioEntradaSalida);
            db.AddParameter("@folioMovimientoInventario", saleHeader.folioMovimientoInventario);
            db.AddParameter("@idTipoEntradaSalida", saleHeader.idTipoEntradaSalida);
            db.AddParameter("@comentarios", saleHeader.comentarios);
            db.AddParameter("@activo", saleHeader.activo);
            db.AddParameter("@idEntidad", saleHeader.idEntidad);
            db.AddParameter("@idUsuarioModifica", saleHeader.idUsuarioModifica);
            db.AddParameter("@montoTotalTicket", saleHeader.montoTotalTicket);
            db.AddParameter("@pagoTotal", saleHeader.pagoTotal  );
            db.AddParameter("@suCambio", saleHeader.suCambio);
            DataSet ds = db.ExecuteWithDataSet();
            return ds;
        }
        private void ExecuteSaleDetail(DataBase2 db, SaleH cSaleH , SaleD d)
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
        }
        private InventoryD CreateInventoryDetail(SaleH saleHeader, SaleD saleDetail)
        {
            return new InventoryD
            {
                idProductoServicio = saleDetail.idProductoServicio,
                cantidad = saleDetail.cantidad,
                idUnidadMedida = saleDetail.idUnidadMedida,
                precioVentaUnitario = saleDetail.precioFinal,
                comentarios = saleDetail.comentarios,
                idEntidad = saleHeader.idEntidad,
                idUsuarioModifica = saleHeader.idUsuarioModifica
            };
        }
        private void ExecuteSalePayment(DataBase2 db, SaleH saleHeader, SalePay salePay)
        {
            db.SetCommand("sp_in_entradasSalidasPago", true);
            db.AddParameter("@folioEntradaSalida", saleHeader.folioEntradaSalida);
            db.AddParameter("@idTipoPago", salePay.idTipoPago);
            db.AddParameter("@montoPago", salePay.montoPago);
            db.AddParameter("@numeroAutorizacion", salePay.numeroAutorizacion);
            db.AddParameter("@comentarios", salePay.comentarios);
            db.AddParameter("@activo", saleHeader.activo);
            db.AddParameter("@idEntidad", saleHeader.idEntidad);
            db.AddParameter("@idUsuarioModifica", saleHeader.idUsuarioModifica);
            db.Execute();
        }
    }
}