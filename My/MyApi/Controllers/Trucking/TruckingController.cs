using Microsoft.AspNetCore.Mvc;
using System.Data;
using Newtonsoft.Json;
using MyApi.Models.MyDB;
using MyApi.Class.Tools;
using MyApi.Models.User;
using MyApi.Models.ProductoServicio;
using MyApi.Models.Trucking;
using System.Net.Http.Headers;
using MyApi.Controllers.MyTools;
using Microsoft.Extensions.ObjectPool;

namespace MyApi.Controllers.Trucking
{
    [ApiController]
    [Route("[controller]")]
    public class TruckingController : ControllerBase
    {

        [HttpPost]
        [Route("get-trucking")]
        public IActionResult TruckingGet(int id = 0, int idEntidad = 0, int isAdmin = 0)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            //Referencias
            DataBase2 db = new DataBase2();
            try
            {
                db.Open();

                db.SetCommand("sp_se_productosServicio", true);
                db.AddParameter("id", id);
                db.AddParameter("idEntidad", idEntidad);
                db.AddParameter("isAdmin", isAdmin);

                DataSet ds = db.ExecuteWithDataSet();

                db.Close();

                ds.Tables[0].TableName = "Data";
                ds.Tables[1].TableName = "Pager";

                Code = true;
                Message = "Succes";
                Response = ToolsController.ToJson(Code, Message, ds);

            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = ToolsController.ToJson(Code, Message);
            }
            return Response;
        }

        [HttpPost]
        [Route("insert-trucking")]
        public IActionResult TruckingPut(TruckingH cTrasladoH)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            int idFolioTras = 1; // FOLIO DE TRASLADOS
            int idFolioMov = 4; // FOLIO DE MOVIMIENTO INVETNARIO
            int idTipoMovInv = 4; //Movimiento por traslado salida
            string FolioTraslado = "";
            string FolioMovimiento = "";
            //Referencias
            DataBase2 db = new DataBase2();
            ToolsController tools = new ToolsController();   

            try
            {
                db.BeginTransaction();

                FolioTraslado = tools.generatFolio(idFolioTras, cTrasladoH.idEntidad, cTrasladoH.idUsuarioModifica, db);
                FolioMovimiento = tools.generatFolio(idFolioMov, cTrasladoH.idEntidad, cTrasladoH.idUsuarioModifica, db);
                cTrasladoH.folioTraslado = Convert.ToInt32(FolioTraslado);
                cTrasladoH.folioMovimientoInventario = Convert.ToInt32(FolioMovimiento);

                db.SetCommand("sp_in_traslados", true);
                db.AddParameter("@folioTraslado", cTrasladoH.folioTraslado);
                db.AddParameter("@folioMovimientoInventario", cTrasladoH.folioMovimientoInventario);
                db.AddParameter("@idUbicacionOrigen", cTrasladoH.idUbicacionOrigen);
                db.AddParameter("@idUbicacionDestino", cTrasladoH.idUbicacionDestino);
                db.AddParameter("@idVehiculo ", cTrasladoH.idVehiculo);
                db.AddParameter("@idEstadoTraslado", cTrasladoH.idEstadoTraslado);
                db.AddParameter("@idTipoTraslado", cTrasladoH.idTipoRegistro);
                db.AddParameter("@idTipoRegistro", cTrasladoH.idTipoRegistro);
                db.AddParameter("@comentarios", cTrasladoH.comentarios);
                db.AddParameter("@activo", cTrasladoH.activo);
                db.AddParameter("@idEntidad", cTrasladoH.idEntidad);
                db.AddParameter("@idUsuarioModifica", cTrasladoH.idUsuarioModifica);

                DataSet ds = db.ExecuteWithDataSet();
                db.ClearParameters();

                db.SetCommand("sp_in_movimentosInventarios", true);
                db.AddParameter("@folioMovimientoInventario", cTrasladoH.folioMovimientoInventario);
                db.AddParameter("@idTipoMovimientoInventario", idTipoMovInv);
                db.AddParameter("@comentarios", cTrasladoH.comentarios);
                db.AddParameter("@activo", cTrasladoH.activo);
                db.AddParameter("@idEntidad", cTrasladoH.idEntidad);
                db.AddParameter("@idUsuarioModifica", cTrasladoH.idUsuarioModifica);

                ds.Merge(db.ExecuteWithDataSet());

                db.Commit();

                Code = true;
                Message = "Succes";
                Response = ToolsController.ToJson(Code, Message, ds);

            }
            catch (Exception ex)
            {
                db.Rollback();
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = ToolsController.ToJson(Code, Message);
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
                Response = ToolsController.ToJson(Code, Message, dt);

            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = ToolsController.ToJson(Code, Message);
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

                Response = ToolsController.ToJson(Code, Message);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;

                Response = ToolsController.ToJson(Code, Message);
            }
            return Response;
        }


    }
}