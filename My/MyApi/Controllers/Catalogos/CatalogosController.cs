using Microsoft.AspNetCore.Mvc;
using System.Data;
using MyApi.Models.MyDB;
using MyApi.Controllers.MyTools;
using MyApi.Models.Catalogos;

namespace MyApi.Controllers.Agenda
{
    [ApiController]
    [Route("[controller]")]
    public class CatalogosController : ControllerBase
    {
        
        #region Catalogos Genericos

        [HttpPost]
        [Route("get-agenda-estatus")]
        public IActionResult GetAgendaEstatus([FromBody] CatalogoRequest request)
        {
            return GetCatalogo(request, "cat_estatusAgenda");
        }

        [HttpPost]
        [Route("get-agenda-detail-estatus")]
        public IActionResult GetAgendaDetailEstatus([FromBody] CatalogoRequest request)
        {
            return GetCatalogo(request, "cat_estatusAgendaDetalleServicio");
        }

        [HttpPost]
        [Route("get-tipo-bloqueo-horario")]
        public IActionResult GetTipoBloqueoHorario([FromBody] CatalogoRequest request)
        {
            return GetCatalogo(request, "cat_tipoBloqueoHorario");
        }

        [HttpPost]
        [Route("get-origen-agenda")]
        public IActionResult GetOrigenAgenda([FromBody] CatalogoRequest request)
        {
            return GetCatalogo(request, "cat_origenAgenda");
        }

        [HttpPost]
        [Route("get-rol-participacion-servicio")]
        public IActionResult GetRolParticipacionServicio([FromBody] CatalogoRequest request)
        {
            return GetCatalogo(request, "cat_rolParticipacionServicio");
        }

        [HttpPost]
        [Route("get-tipo-movimiento-pago-agenda")]
        public IActionResult GetTipoMovimientoPagoAgenda([FromBody] CatalogoRequest request)
        {
            return GetCatalogo(request, "cat_tipoMovimientoPagoAgenda");
        }

        private IActionResult GetCatalogo(CatalogoRequest request, string nombreTablaEnBD)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds;
            DataBase2 db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_se_catalogos", true);
                db.AddParameter("id", request.id.ToString());
                db.AddParameter("idEntidad", request.idEntidad.ToString());
                db.AddParameter("isAdmin", request.isAdmin.ToString());
                db.AddParameter("catalogo", nombreTablaEnBD);

                ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds.Tables[0]);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Exception: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }

            return Response;
        }

        #endregion

        [HttpPost]
        [Route("get-agenda-servicios")]
        public IActionResult GetAgendaServicios([FromBody] ServicioAgendaRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds;
            DataBase2 db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_se_agendaServiciosActivos", true);
                db.AddParameter("idProductoServicio", request.idProductoServicio.ToString());
                db.AddParameter("idEntidad", request.idEntidad.ToString());

                ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds.Tables[0]);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Exception: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }

            return Response;
        }

        [HttpPost]
        [Route("get-clientes")]
        public IActionResult GetClientes([FromBody] ClienteRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataSet ds;
            DataBase2 db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_se_clientesByIdEntidad", true);
                db.AddParameter("idCliente", request.idCliente.ToString());
                db.AddParameter("idEntidad", request.idEntidad.ToString());

                ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds.Tables[0]);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Exception: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }

            return Response;
        }

    }
}