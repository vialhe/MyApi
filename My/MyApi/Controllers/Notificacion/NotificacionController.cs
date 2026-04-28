using Microsoft.AspNetCore.Mvc;
using System.Data;
using MyApi.Models.MyDB;
using MyApi.Models.Notificacion;
using MyApi.Controllers.MyTools;

namespace MyApi.Controllers.Notificacion
{
    [ApiController]
    [Route("[controller]")]
    public class NotificacionController : ControllerBase
    {

        #region Tokens FCM

        [HttpPost]
        [Route("insert-token")]
        public IActionResult GuardaToken([FromBody] GuardaTokenFCMRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                dt = ExecuteDataTable("sp_ui_guardaTokenFCM", db =>
                {
                    db.AddParameter("@idUsuario", request.idUsuario);
                    db.AddParameter("@token", request.token);
                    db.AddParameter("@dispositivo", request.dispositivo);
                    db.AddParameter("@plataforma", request.plataforma);
                    db.AddParameter("@versionApp", request.versionApp);
                    db.AddParameter("@comentarios", request.comentarios ?? "");
                    db.AddParameter("@idEntidad", request.idEntidad);
                    db.AddParameter("@idUsuarioAlta", request.idUsuarioAlta);
                });

                Code = true;
                Message = "Success";
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
        [Route("update-token-last-connection")]
        public IActionResult ActualizaTokenUltimaConexion([FromBody] ActualizaTokenUltimaConexionRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                dt = ExecuteDataTable("sp_up_actualizaTokenUltimaConexion", db =>
                {
                    db.AddParameter("@idUsuario", request.idUsuario);
                    db.AddParameter("@token", request.token);
                    db.AddParameter("@dispositivo", request.dispositivo);
                    db.AddParameter("@plataforma", request.plataforma);
                    db.AddParameter("@versionApp", request.versionApp);
                    db.AddParameter("@idEntidad", request.idEntidad);
                    db.AddParameter("@idUsuarioModifica", request.idUsuarioModifica);
                });

                Code = true;
                Message = "Success";
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
        [Route("get-token-list")]
        public IActionResult ObtieneListaToken([FromBody] ObtieneTokenFCMRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                dt = ExecuteDataTable("sp_se_tokenFCM", db =>
                {
                    db.AddParameter("@idEntidad", request.idEntidad);
                    db.AddParameter("@idUsuario", request.idUsuario);
                    db.AddParameter("@soloActivos", request.soloActivos);
                    db.AddParameter("@plataforma", request.plataforma ?? "");
                });

                Code = true;
                Message = "Success";
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
        [Route("deactivate-token")]
        public IActionResult DesactivaToken([FromBody] DesactivaTokenFCMRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                dt = ExecuteDataTable("sp_up_desactivaTokenFCM", db =>
                {
                    db.AddParameter("@idEntidad", request.idEntidad);
                    db.AddParameter("@token", request.token);
                    db.AddParameter("@idUsuario", request.idUsuario);
                    db.AddParameter("@idUsuarioModifica", request.idUsuarioModifica);
                    db.AddParameter("@comentarios", request.comentarios ?? "");
                });

                Code = true;
                Message = "Success";
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

        #endregion

        #region Notificaciones FCM

        [HttpPost]
        [Route("insert-notification-user")]
        public IActionResult InsertaNotificacionUsuario([FromBody] InsertaNotificacionFCMPorUsuarioRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                dt = ExecuteDataTable("sp_ui_insertaNotificacionFCMPorUsuario", db =>
                {
                    db.AddParameter("@idUsuario", request.idUsuario);
                    db.AddParameter("@titulo", request.titulo);
                    db.AddParameter("@mensaje", request.mensaje);
                    db.AddParameter("@comentarios", request.comentarios ?? "");
                    db.AddParameter("@idEntidad", request.idEntidad);
                    db.AddParameter("@idUsuarioAlta", request.idUsuarioAlta);
                });

                Code = true;
                Message = "Success";
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
        [Route("insert-notification-entity")]
        public IActionResult InsertaNotificacionEntidad([FromBody] InsertaNotificacionFCMPorEntidadRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                dt = ExecuteDataTable("sp_ui_insertaNotificacionFCMPorEntidad", db =>
                {
                    db.AddParameter("@idEntidad", request.idEntidad);
                    db.AddParameter("@titulo", request.titulo);
                    db.AddParameter("@mensaje", request.mensaje);
                    db.AddParameter("@comentarios", request.comentarios ?? "");
                    db.AddParameter("@idUsuarioAlta", request.idUsuarioAlta);
                });

                Code = true;
                Message = "Success";
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
        [Route("insert-notification-general")]
        public IActionResult InsertaNotificacionGeneral([FromBody] InsertaNotificacionFCMGeneralRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                dt = ExecuteDataTable("sp_ui_insertaNotificacionFCMGeneral", db =>
                {
                    db.AddParameter("@titulo", request.titulo);
                    db.AddParameter("@mensaje", request.mensaje);
                    db.AddParameter("@comentarios", request.comentarios ?? "");
                    db.AddParameter("@idUsuarioAlta", request.idUsuarioAlta);
                });

                Code = true;
                Message = "Success";
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
        [Route("get-notifications-pending")]
        public IActionResult ObtieneNotificacionesPendientes([FromBody] ObtieneNotificacionesPendientesRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                dt = ExecuteDataTable("sp_se_notificacionesFCMPendientes", db =>
                {
                    db.AddParameter("@tipo", request.tipo);
                    db.AddParameter("@idEntidad", request.idEntidad);
                    db.AddParameter("@idUsuario", request.idUsuario);
                    db.AddParameter("@top", request.top);
                    db.AddParameter("@incluirImagen", request.incluirImagen);
                });

                Code = true;
                Message = "Success";
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
        [Route("set-notification-sent")]
        public IActionResult MarcaNotificacionEnviada([FromBody] MarcaNotificacionFCMEnviadaRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                dt = ExecuteDataTable("sp_up_notificacionFCMEnviada", db =>
                {
                    db.AddParameter("@idNotificacionFCM", request.idNotificacionFCM);
                    db.AddParameter("@idUsuarioModifica", request.idUsuarioModifica);
                    db.AddParameter("@comentarios", request.comentarios ?? "");
                });

                Code = true;
                Message = "Success";
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
        [Route("cancel-notification")]
        public IActionResult CancelaNotificacion([FromBody] CancelaNotificacionFCMRequest request)
        {
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;

            try
            {
                dt = ExecuteDataTable("sp_up_cancelaNotificacionFCM", db =>
                {
                    db.AddParameter("@idNotificacionFCM", request.idNotificacionFCM);
                    db.AddParameter("@idUsuarioModifica", request.idUsuarioModifica);
                    db.AddParameter("@comentarios", request.comentarios ?? "");
                });

                Code = true;
                Message = "Success";
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
        #endregion

        #region Helpers
        private DataTable ExecuteDataTable(string storedProcedure, Action<DataBase2> setParameters)
        {
            var db = new DataBase2();

            db.SetCommand(storedProcedure, true);
            setParameters(db);

            DataSet ds = db.ExecuteWithDataSet();

            if (ds == null || ds.Tables.Count == 0)
                return new DataTable();

            return ds.Tables[0];
        }
        #endregion
    }
}