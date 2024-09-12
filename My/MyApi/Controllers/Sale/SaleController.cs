using Microsoft.AspNetCore.Mvc;
using System.Data;
using Newtonsoft.Json;
using MyApi.Models.MyDB;
using MyApi.Class.Tools;
using MyApi.Models.User;
using MyApi.Models.ProductoServicio;
using MyApi.Models.Sale;
using System.Net.Http.Headers;
using MyApi.Controllers.MyTools;
using Microsoft.Extensions.ObjectPool;
using static MyApi.Controllers.MyTools.MyToolsController;

namespace MyApi.Controllers.Sale
{
    [ApiController]
    [Route("[controller]")]
    public class SaleController : ControllerBase
    {


        [HttpPost]
        [Route("insert-sale")]
        public IActionResult SalePut(TruckingData data)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            int idFolioEntradaSalida = 5; // FOLIO DE ENTRADA SALIDA
            int idFolioMov = 4; // FOLIO DE MOVIMIENTO INVETNARIO
            int idTipoEntradaSalida = 3; //VENTA POR PUBLICO GENERAL
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

                FolioEntradaSalida = tools.generatFolio(idFolioEntradaSalida, cSaleH.idEntidad, cSaleH.idUsuarioModifica, db);
                FolioMovimiento = tools.generatFolio(idFolioMov, cSaleH.idEntidad, cSaleH.idUsuarioModifica, db);
                cSaleH.folioEntradaSalida = Convert.ToInt32(FolioEntradaSalida);
                cSaleH.folioMovimientoInventario = Convert.ToInt32(FolioMovimiento);

                db.SetCommand("sp_ui_entradasSalidas", true);
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
                    db.SetCommand("sp_in_trasladosDetalles", true);
                    db.AddParameter("@folioEntradaSalida", cSaleH.folioEntradaSalida);
                    db.AddParameter("@idProductoServicio", d.idProductoServicio);
                    db.AddParameter("@idUnidadMedida", d.idUnidadMedida);
                    db.AddParameter("@cantidad", d.cantidad);
                    db.AddParameter("@comentarios", d.comentarios);
                    db.AddParameter("@activo", cSaleH.activo);
                    db.AddParameter("@idEntidad", cSaleH.idEntidad);
                    db.AddParameter("@idUsuarioModifica", cSaleH.idUsuarioModifica);
                    db.Execute();
                }

                db.SetCommand("sp_in_movimentosInventarios", true);
                db.AddParameter("@folioMovimientoInventario", cSaleH.folioMovimientoInventario);
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

        [HttpPost]
        [Route("update-productoservicio")]
        public IActionResult ProductoServicioUpdate(ProductoServicio cProductoServicio)
        {
            /*Se declaran variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", cProductoServicio.id.ToString()),
                    new Parametro("idTipoProductoServicio", cProductoServicio.idTipoProductoServicio.ToString()),
                    new Parametro("folioProductoServicio", cProductoServicio.folioProductoServicio.ToString()),
                    new Parametro("precio", cProductoServicio.precio.ToString()),
                    new Parametro("descripcion", cProductoServicio.descripcion.ToString()),
                    new Parametro("recurrente", cProductoServicio.recurrente.ToString()),
                    new Parametro("comentarios", cProductoServicio.comentarios.ToString()),
                    new Parametro("activo", cProductoServicio.activo.ToString()),
                    new Parametro("idEntidad", cProductoServicio.idEntidad.ToString()),
                    new Parametro("idUsuarioModifica", cProductoServicio.idUsuarioModifica.ToString()),
                };

                dt = DataBase.Listar("sp_ui_productosServicios", parametros);
                Code = true;
                Message = "Succes";
                Response = MyToolsController.ToJson(Code, Message, dt);

            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }
            return Response;


        }

        [HttpPost]
        [Route("delete-productoservicio")]
        public IActionResult ProductoServicioDelete(int id, string nombreTabla = "")
        {
            /*Define variables*/
            JsonResult Response;
            bool Code;
            string Message;
            nombreTabla = "cat_productosServicios";

            try
            {
                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", id.ToString()),
                    new Parametro("nombreTabla", nombreTabla.ToString())
                };

                DataBase.Ejecutar("sp_del_fromNameTable", parametros);
                Code = true;
                Message = "Succes";

                Response = MyToolsController.ToJson(Code, Message);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;

                Response = MyToolsController.ToJson(Code, Message);
            }
            return Response;
        }

        #region Catalogos 

        [HttpPost]
        [Route("get-traslados-bancos")]
        public IActionResult GetBancos(GenericReques rEmpresa)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds;
            DataBase2 db = new DataBase2();

            try
            {
                db.SetCommand("sp_se_bancos", true);
                db.AddParameter("id", rEmpresa.id.ToString());
                db.AddParameter("idEntidad", rEmpresa.idEntidad.ToString());
                db.AddParameter("isAdmin", rEmpresa.isAdmin.ToString());

                /*Define return success*/
                ds = db.ExecuteWithDataSet();
                ds.Tables[0].TableName = "Data";
                ds.Tables[1].TableName = "Data2";
                Code = true;
                Message = "Succes";

                Response = MyToolsController.ToJson(Code, Message, ds);
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

        [HttpPost]
        [Route("get-empresa")]
        public IActionResult GetEmpresa(GenericReques rEmpresa)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            DataBase2 db = new DataBase2();

            try
            {
                db.SetCommand("sp_se_empresas", true);
                db.AddParameter("id", rEmpresa.id.ToString());
                db.AddParameter("idEntidad", rEmpresa.idEntidad.ToString());
                db.AddParameter("isAdmin", rEmpresa.isAdmin.ToString());

                /*Define return success*/
                dt = db.ExecuteWithDataSet().Tables[0];
                Code = true;
                Message = "Succes";

                Response = MyToolsController.ToJson(Code, Message, dt);
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

        [HttpPost]
        [Route("get-unidadmedida")]
        public IActionResult GetUnidadMedida(GenericReques rUnidadMedida)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            string NombreTablaEnBD = "cat_unidadesMedida";
            DataSet ds;
            DataBase2 db = new DataBase2();


            try
            {
                db.SetCommand("sp_se_catalogos", true);
                db.AddParameter("id", rUnidadMedida.id.ToString());
                db.AddParameter("idEntidad", rUnidadMedida.idEntidad.ToString());
                db.AddParameter("isAdmin", rUnidadMedida.isAdmin.ToString());
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

        [HttpPost]
        [Route("get-vehiculo")]
        public IActionResult GetVehiculo(GenericReques rUnidadMedida)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            string NombreTablaEnBD = "cat_vehiculos";
            DataSet ds;
            DataBase2 db = new DataBase2();


            try
            {
                db.SetCommand("sp_se_catalogos", true);
                db.AddParameter("id", rUnidadMedida.id.ToString());
                db.AddParameter("idEntidad", rUnidadMedida.idEntidad.ToString());
                db.AddParameter("isAdmin", rUnidadMedida.isAdmin.ToString());
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

        #endregion

    }
}