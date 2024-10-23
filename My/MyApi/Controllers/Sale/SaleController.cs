using Microsoft.AspNetCore.Mvc;
using System.Data;
using MyApi.Models.MyDB;
using MyApi.Models.Sale;
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
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            int idFoliadorEntradaSalida = 5; // FOLIO DE ENTRADA SALIDA
            int idFolioadorMovInv = 4; // FOLIO DE MOVIMIENTO INVETNARIO
            int idTipoMovInv = 3; //VENTA POR PUBLICO GENERAL
            string FolioEntradaSalida = "";
            string FolioMovimiento = "";
            
            //Referencias
            DataBase2 db = new DataBase2();
            MyToolsController tools = new MyToolsController();
            SaleH? cSaleH = data.CSaleH;
            List<SaleD>? cSaleD = data.CSaleD;
            List<SalePay>? cSalePay = data.CSalePay;

            try
            { 
                db.BeginTransaction();

                FolioEntradaSalida = tools.generatFolio(idFoliadorEntradaSalida, cSaleH.idEntidad, cSaleH.idUsuarioModifica, db);
                FolioMovimiento = tools.generatFolio(idFolioadorMovInv, cSaleH.idEntidad, cSaleH.idUsuarioModifica, db);
                cSaleH.folioEntradaSalida = Convert.ToInt32(FolioEntradaSalida);
                cSaleH.folioMovimientoInventario = Convert.ToInt32(FolioMovimiento);

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
                }

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

                db.SetCommand("sp_in_movimentosInventarios", true);
                db.AddParameter("@folioMovimientoInventario", cSaleH.folioMovimientoInventario);
                db.AddParameter("@idTipoMovimientoInventario", idTipoMovInv);
                db.AddParameter("@comentarios", cSaleH.comentarios);
                db.AddParameter("@activo", cSaleH.activo);
                db.AddParameter("@idEntidad", cSaleH.idEntidad);
                db.AddParameter("@idUsuarioModifica", cSaleH.idUsuarioModifica);
                db.Execute();

                foreach (SaleD d in cSaleD)
                {
                    db.SetCommand("sp_in_movimentosInventariosDetalles", true);
                    db.AddParameter("@folioMovimientoInventario", cSaleH.folioMovimientoInventario);
                    db.AddParameter("@idProductoServicio", d.idProductoServicio);
                    db.AddParameter("@idUnidadMedida", d.idUnidadMedida);
                    db.AddParameter("@cantidad", d.cantidad);
                    db.AddParameter("@comentarios", d.comentarios);
                    db.AddParameter("@activo", cSaleH.activo);
                    db.AddParameter("@idEntidad", cSaleH.idEntidad);
                    db.AddParameter("@idUsuarioModifica", cSaleH.idUsuarioModifica);
                    db.Execute();
                }

                db.Commit();

                Code = true;
                Message = "Succes";
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