using MyApi.Models.MyDB;
using MyApi.Controllers.MyTools;
using System.Data;
using MyApi.Models.Inventory;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using MyApi.Models.Sale;
using static MyApi.Controllers.Menu.MenuController;

namespace MyApi.Controllers.Inventory
{
    [ApiController]
    [Route("[controller]")]
    public class InventoryController : ControllerBase
    {

        [HttpPost]
        [Route("insert-movinv")]
        public IActionResult InventoryMovementPut(InventoryMovementData data)
        {
            if (data == null || data.CInventoryH == null || data.CInventoryD == null)
            {
                return BadRequest("Los movimientos no pueden ser nulos.");
            }

            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            int idFoliadorMovInv = 4; // FOLIO DE MOVIMIENTO INVENTARIO
            string FolioMovimiento = "";

            //Referencias
            var db = new DataBase2();
            MyToolsController tools = new MyToolsController();
            InventoryH? cInventoryH = data.CInventoryH;
            List<InventoryD>? cInventoryD = data.CInventoryD;

            try
            {
                db.BeginTransaction();
                // Generar folio para el movimiento de inventario
                FolioMovimiento = tools.generatFolio(idFoliadorMovInv, cInventoryH.idEntidad, cInventoryH.idUsuarioModifica, db);
                cInventoryH.folioMovimientoInventario = Convert.ToInt32(FolioMovimiento);

                // Ejecutar SP para insertar el encabezado del movimiento de inventario
                db.SetCommand("sp_in_movimentosInventarios", true);
                db.AddParameter("@folioMovimientoInventario", cInventoryH.folioMovimientoInventario);
                db.AddParameter("@idTipoMovimientoInventario", cInventoryH.idTipoMovimientoInventario);
                db.AddParameter("@idDocumentoReferencia", cInventoryH.idDocumentoReferencia);
                db.AddParameter("@idAlmacen", cInventoryH.idAlmacen);
                db.AddParameter("@idMotivoMovimiento", cInventoryH.idMotivoMovimiento);
                db.AddParameter("@idEstadoMovimiento", cInventoryH.idEstadoMovimiento);
                db.AddParameter("@idPersona", cInventoryH.idPersona);
                //db.AddParameter("@stockAntesMovimiento", cInventoryH.stockAntesMovimiento);
                db.AddParameter("@comentarios", cInventoryH.comentarios);
                db.AddParameter("@activo", cInventoryH.activo);
                db.AddParameter("@idEntidad", cInventoryH.idEntidad);
                db.AddParameter("@idUsuarioModifica", cInventoryH.idUsuarioModifica);
                db.Execute();

                // Ejecutar SP para insertar los detalles del movimiento de inventario
                foreach (InventoryD d in cInventoryD)
                {
                    db.SetCommand("sp_in_movimentosInventariosDetalles", true);
                    db.AddParameter("@folioMovimientoInventario", cInventoryH.folioMovimientoInventario);
                    db.AddParameter("@idProductoServicio", d.idProductoServicio);
                    db.AddParameter("@cantidad", d.cantidad);
                    db.AddParameter("@idUnidadMedida", d.idUnidadMedida);
                    db.AddParameter("@costoUnitario", d.costoUnitario);
                    db.AddParameter("@precioVentaUnitario", d.precioVentaUnitario);
                    db.AddParameter("@lote", d.lote);
                    db.AddParameter("@serie", d.serie);
                    db.AddParameter("@fechaVencimiento", d.fechaExpira);
                    db.AddParameter("@comentarios", d.comentarios);
                    db.AddParameter("@activo", d.activo);
                    db.AddParameter("@idEntidad", d.idEntidad);
                    db.AddParameter("@idUsuarioModifica", d.idUsuarioModifica);
                    db.Execute();
                }

                // Ejecutar SP para actualizar el inventario
                foreach (InventoryD d in cInventoryD)
                {
                    db.SetCommand("sp_up_inventarioV2", true);
                    db.AddParameter("@folioMovimientoInventario", cInventoryH.folioMovimientoInventario);
                    db.AddParameter("@idProductoServicio", d.idProductoServicio);
                    db.AddParameter("@idProveedor", cInventoryH.idPersona); 
                    db.AddParameter("@cantidad", d.cantidad);
                    db.AddParameter("@idUnidadMedida", d.idUnidadMedida);
                    db.AddParameter("@idTipoMovimientoInventario", cInventoryH.idTipoMovimientoInventario);
                    db.AddParameter("@lote", d.lote);
                    db.AddParameter("@serie", d.serie);
                    db.AddParameter("@numeracion", d.numeracion);
                    db.AddParameter("@fechaVencimiento", d.fechaExpira);
                    db.AddParameter("@costoUnitario", d.costoUnitario);
                    db.AddParameter("@precioVenta", d.precioVentaUnitario);
                    db.AddParameter("@idEntidad", d.idEntidad);
                    db.AddParameter("@idUsuarioModifica", d.idUsuarioModifica);
                    db.Execute();
                }
                db.Commit();

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message);

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
        public IActionResult InventoryMovementPut(InventoryData data)
        {
            // Declarar variables
            JsonResult Response;
            bool Code;
            string Message;
            //DataTable dt;
            DataSet ds;
            int idFoliadorMovInv = 4; // FOLIO DE MOVIMIENTO INVENTARIO
            string FolioMovimiento = "";

            // Referencias
            DataBase2 db = new DataBase2();
            MyToolsController tools = new MyToolsController();
            InventoryH? cInventoryH = data.CInventoryH;
            List<InventoryD>? cInventoryD = data.CInventoryD;

            try
            {
                db.BeginTransaction();

                // Generar folio para el movimiento de inventario
                FolioMovimiento = tools.generatFolio(idFoliadorMovInv, cInventoryH.idEntidad, cInventoryH.idUsuarioModifica, db);
                cInventoryH.folioMovimientoInventario = Convert.ToInt32(FolioMovimiento);

                // Ejecutar SP para insertar el encabezado del movimiento de inventario
                db.SetCommand("sp_in_movimentosInventarios", true);
                db.AddParameter("@folioMovimientoInventario", cInventoryH.folioMovimientoInventario);
                db.AddParameter("@idTipoMovimientoInventario", cInventoryH.idTipoMovimientoInventario);
                db.AddParameter("@idDocumentoReferencia", cInventoryH.idDocumentoReferencia);
                db.AddParameter("@idAlmacen", cInventoryH.idAlmacen);
                db.AddParameter("@idMotivoMovimiento", cInventoryH.idMotivoMovimiento);
                db.AddParameter("@idEstadoMovimiento", cInventoryH.idEstadoMovimiento);
                db.AddParameter("@idPersona", cInventoryH.idPersona);
                //db.AddParameter("@stockAntesMovimiento", cInventoryH.stockAntesMovimiento);
                db.AddParameter("@comentarios", cInventoryH.comentarios);
                db.AddParameter("@activo", cInventoryH.activo);
                db.AddParameter("@idEntidad", cInventoryH.idEntidad);
                db.AddParameter("@idUsuarioModifica", cInventoryH.idUsuarioModifica);
                db.Execute();

                // Ejecutar SP para insertar los detalles del movimiento de inventario
                foreach (InventoryD d in cInventoryD)
                {
                    db.SetCommand("sp_in_movimentosInventariosDetalles", true);
                    db.AddParameter("@folioMovimientoInventario", cInventoryH.folioMovimientoInventario);
                    db.AddParameter("@idProductoServicio", d.idProductoServicio);
                    db.AddParameter("@cantidad", d.cantidad);
                    db.AddParameter("@idUnidadMedida", d.idUnidadMedida);
                    db.AddParameter("@costoUnitario", d.costoUnitario);
                    db.AddParameter("@precioVentaUnitario", d.precioVentaUnitario);
                    db.AddParameter("@lote", d.lote);
                    db.AddParameter("@serie", d.serie);
                    db.AddParameter("@numeracion", d.numeracion);
                    db.AddParameter("@fechaVencimiento", d.fechaExpira);
                    db.AddParameter("@comentarios", d.comentarios);
                    db.AddParameter("@activo", d.activo);
                    db.AddParameter("@idEntidad", d.idEntidad);
                    db.AddParameter("@idUsuarioModifica", d.idUsuarioModifica);
                    db.Execute();
                }

                // Ejecutar SP para actualizar el inventario
                foreach (InventoryD d in cInventoryD)
                {
                    db.SetCommand("sp_up_inventarioV2", true);
                    db.AddParameter("@folioMovimientoInventario", cInventoryH.folioMovimientoInventario);
                    db.AddParameter("@idProductoServicio", d.idProductoServicio);
                    db.AddParameter("@idProveedor", d.idEntidad); // Suponiendo que el proveedor se deriva del idEntidad
                    db.AddParameter("@cantidad", d.cantidad);
                    db.AddParameter("@idUnidadMedida", d.idUnidadMedida);
                    db.AddParameter("@idTipoMovimientoInventario", cInventoryH.idTipoMovimientoInventario);
                    db.AddParameter("@lote", d.lote);
                    db.AddParameter("@serie", d.serie);
                    db.AddParameter("@unidadMedidaBase", d.numeracion);
                    db.AddParameter("@numeracion", d.numeracion);
                    db.AddParameter("@fechaVencimiento", d.fechaExpira);
                    db.AddParameter("@costoUnitario", d.costoUnitario);
                    db.AddParameter("@precioVenta", d.precioVentaUnitario);
                    db.AddParameter("@idEntidad", d.idEntidad);
                    db.AddParameter("@idUsuarioModifica", d.idUsuarioModifica);
                    db.Execute();
                }

                db.Commit();

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message);

            }
            catch (SqlException exsql)
            {
                db.Rollback();
                Code = false;
                Message = "Ex: " + exsql.Message;
                Response = MyToolsController.ToJson(Code, Message);
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
        [Route("get-tipoMovInv")]
        public IActionResult GetTipoMovInv(tipMovInvRequest rtipoMovInv)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            string NombreTablaEnBD = "cat_tiposMovmientosInventario";
            DataSet ds;
            DataBase2 db = new DataBase2();

            try
            {
                db.SetCommand("sp_se_catalogos", true);
                db.AddParameter("id", rtipoMovInv.id.ToString());
                db.AddParameter("idEntidad", rtipoMovInv.idEntidad.ToString());
                db.AddParameter("isAdmin", rtipoMovInv.isAdmin.ToString());
                db.AddParameter("catalogo", NombreTablaEnBD);

                /*Define return success*/
                ds = db.ExecuteWithDataSet();
                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Succes";

                Response = MyToolsController.ToJson(Code, Message, ds.Tables[0]);
            }
            catch (Exception ex)
            {
                /*Define return ex*/
                Code = false;
                Message = "Exception: " + ex;
                Response = MyToolsController.ToJson(Code, Message);

            }
            return Response;
        }
        public IActionResult InventoryMovementPutSale(InventoryData data)
        {
            // Declarar variables
            JsonResult Response;
            bool Code;
            string Message;
            //DataTable dt;
            DataSet ds;
            int idFoliadorMovInv = 4; // FOLIO DE MOVIMIENTO INVETNARIO
            string FolioMovimiento = "";

            // Referencias
            DataBase2 db = data.cDB;
            MyToolsController tools = new MyToolsController();
            InventoryH? cInventoryH = data.CInventoryH;
            List<InventoryD>? cInventoryD = data.CInventoryD;

            try
            {
                // Ejecutar SP para insertar el encabezado del movimiento de inventario
                db.SetCommand("sp_in_movimentosInventarios", true);
                db.AddParameter("@folioMovimientoInventario", cInventoryH.folioMovimientoInventario);
                db.AddParameter("@idTipoMovimientoInventario", cInventoryH.idTipoMovimientoInventario);
                db.AddParameter("@idDocumentoReferencia", cInventoryH.idDocumentoReferencia);
                db.AddParameter("@idAlmacen", cInventoryH.idAlmacen);
                db.AddParameter("@idMotivoMovimiento", cInventoryH.idMotivoMovimiento);
                db.AddParameter("@idEstadoMovimiento", cInventoryH.idEstadoMovimiento);
                db.AddParameter("@idPersona", cInventoryH.idPersona);
                //db.AddParameter("@stockAntesMovimiento", cInventoryH.stockAntesMovimiento);
                db.AddParameter("@comentarios", cInventoryH.comentarios);
                db.AddParameter("@activo", cInventoryH.activo);
                db.AddParameter("@idEntidad", cInventoryH.idEntidad);
                db.AddParameter("@idUsuarioModifica", cInventoryH.idUsuarioModifica);
                db.Execute();

                // Ejecutar SP para insertar los detalles del movimiento de inventario
                foreach (InventoryD d in cInventoryD)
                {
                    db.SetCommand("sp_in_movimentosInventariosDetalles", true);
                    db.AddParameter("@folioMovimientoInventario", cInventoryH.folioMovimientoInventario);
                    db.AddParameter("@idProductoServicio", d.idProductoServicio);
                    db.AddParameter("@cantidad", d.cantidad);
                    db.AddParameter("@idUnidadMedida", d.idUnidadMedida);
                    db.AddParameter("@costoUnitario", d.costoUnitario);
                    db.AddParameter("@precioVentaUnitario", d.precioVentaUnitario);
                    db.AddParameter("@lote", d.lote);
                    db.AddParameter("@serie", d.serie);
                    db.AddParameter("@fechaVencimiento", d.fechaExpira);
                    db.AddParameter("@comentarios", d.comentarios);
                    db.AddParameter("@activo", d.activo);
                    db.AddParameter("@idEntidad", d.idEntidad);
                    db.AddParameter("@idUsuarioModifica", d.idUsuarioModifica);
                    db.Execute();
                }

                // Ejecutar SP para actualizar el inventario
                foreach (InventoryD d in cInventoryD)
                {
                    db.SetCommand("sp_up_inventarioV2", true);
                    db.AddParameter("@folioMovimientoInventario", cInventoryH.folioMovimientoInventario);
                    db.AddParameter("@idProductoServicio", d.idProductoServicio);
                    db.AddParameter("@idProveedor", d.idEntidad); // Suponiendo que el proveedor se deriva del idEntidad
                    db.AddParameter("@cantidad", d.cantidad);
                    db.AddParameter("@idUnidadMedida", d.idUnidadMedida);
                    db.AddParameter("@idTipoMovimientoInventario", cInventoryH.idTipoMovimientoInventario);
                    db.AddParameter("@lote", d.lote);
                    db.AddParameter("@serie", d.serie);
                    db.AddParameter("@numeracion", d.numeracion);
                    db.AddParameter("@fechaVencimiento", d.fechaExpira);
                    db.AddParameter("@costoUnitario", d.costoUnitario);
                    db.AddParameter("@precioVenta", d.precioVentaUnitario);
                    db.AddParameter("@idEntidad", d.idEntidad);
                    db.AddParameter("@idUsuarioModifica", d.idUsuarioModifica);
                    db.Execute();
                }

                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message);

            }
            catch (SqlException exsql)
            {
                db.Rollback();
                Code = false;
                Message = "Ex: " + exsql.Message;
                Response = MyToolsController.ToJson(Code, Message);
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
