using Microsoft.AspNetCore.Mvc;
using MyApi.Models.MyDB;
using System.Data;
using MyApi.Class.Auth;
using MyApi.Models.User;
using MyApi.Controllers.MyTools;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using static MyApi.Controllers.Menu.MenuController;

namespace MyApi.Controllers.Auth
{
    [ApiController]
    [Route("[controller]")]
    public class AuthController : Controller
    {
       
        public DataTable GetVerifyUser(ValidaUsuario oUsuario)
        {
            /*Declara variables*/
            DataTable dt = new DataTable();

            /*Definiciones*/

            try
            {
                /*Definiciones de las variables*/

                /*Inicia proceso*/
                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("user", oUsuario.username)

                };
                dt = DataBase.Listar("sp_proc_ValidaLogin", parametros);

                return dt;

            }
            catch (Exception)
            {
                /*Define return ex*/
                throw;
            }

        }

        
        [HttpPost]
        [Route("VerifySession")]
        public IActionResult VerifySession(ValidaUsuario user)
        {

            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dtUsuario = new DataTable();
            bool Verify = false;
            string Hash;
            string Token = null;

            /*Definicion de Variables*/
            try
            {
                /*Inicia proceso*/
                dtUsuario = GetVerifyUser(user);

                if (dtUsuario.Rows.Count > 0)
                {

                    Hash = BCrypt.Net.BCrypt.HashPassword(user.password, dtUsuario.Rows[0]["salt"].ToString());
                    Verify = dtUsuario.Rows[0]["hashpassword"].ToString() == Hash;

                    if (Verify)
                    {
                        // Usuario verificado correctamente, genera el token
                        Token = GenerateJwtToken(dtUsuario.Rows[0]);
                        Code = true;
                        Message = "Access Authorized";
                    }
                    else
                    {
                        Code = false;
                        Message = "Incorrect password";
                    }
                }
                else 
                {
                    Code = false;
                    Message = "Incorrect user";
                }

                if (!Code)
                    dtUsuario.Clear();
                /*Define return */
                
                Response = MyToolsController.ToJson(Code, Message,dtUsuario,Token,true);

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

        private string GenerateJwtToken(DataRow userInfo)
        {
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("your_secret_key_here")); // Asegúrate de almacenar esto de forma segura y no hard-codearlo así
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, userInfo["id"].ToString()),
                // Agrega cualquier claim adicional que necesites
            };

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddHours(1), // El token expira en 1 hora
                SigningCredentials = credentials
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }

        [HttpPost]
        [Route("ChangePassword")]
        public IActionResult ChangePassword(ValidaUsuario Usuarios)
        {
            /*Declara variables*/
            JsonResult Response;
            bool Code;
            string Message;
            DataTable dt;
            string salt;

            try
            {
                /*Inicia proceso*/

                salt = BCrypt.Net.BCrypt.GenerateSalt();

                Usuarios.password = BCrypt.Net.BCrypt.HashPassword(Usuarios.password,salt);

                List<Parametro> parametros = new List<Parametro>{
                    new Parametro("id", Usuarios.id.ToString()),
                    new Parametro("usuario", Usuarios.username.ToString()),
                    new Parametro("password", Usuarios.password.ToString()),
                    new Parametro("salt", salt),
                    new Parametro("comentarios", Usuarios.comentarios.ToString()),
                    new Parametro("idUsuarioModifica", Usuarios.idUsuarioModifica.ToString())
                };

                dt = DataBase.Listar("sp_proc_UpdatePassword", parametros);

                /*Define return success*/
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
            /* Retorna  */
            return Response;

        }

        #region sesion de usuarios
        [HttpPost]
        [Route("ExpiraSesionVencidas")]
        public IActionResult ExpiraSesionVencidas([FromBody] ExpiraSesionRequest req)
        {
            JsonResult response;
            bool code;
            string message;
            DataBase2 db = new DataBase2();

            try
            {
                if (req == null || req.idEntidad <= 0)
                    return MyToolsController.ToJson(false, "El idEntidad es obligatorio.");

                db.Open();
                db.SetCommand("sp_sys_usuario_session_expirar_vencidas", true);
                db.AddParameter("idEntidad", req.idEntidad);

                db.Execute();
                db.Close();

                code = true;
                message = "Sesiones vencidas procesadas correctamente.";
                response = MyToolsController.ToJson(code, message);
            }
            catch (Exception ex)
            {
                try { db.Close(); } catch { }
                code = false;
                message = "Ex: " + ex.Message;
                response = MyToolsController.ToJson(code, message);
            }

            return response;
        }

        [HttpPost]
        [Route("IniciarSesionUsuario")]
        public IActionResult IniciarSesionUsuario([FromBody] IniciarSesionUsuarioRequest req)
        {
            JsonResult response;
            bool code;
            string message;
            DataBase2 db = new DataBase2();

            try
            {
                if (req == null)
                    return MyToolsController.ToJson(false, "Request inválido.");

                if (req.idEntidad <= 0)
                    return MyToolsController.ToJson(false, "El idEntidad es obligatorio.");

                if (req.idUsuario <= 0)
                    return MyToolsController.ToJson(false, "El idUsuario es obligatorio.");

                if (string.IsNullOrWhiteSpace(req.token))
                    return MyToolsController.ToJson(false, "El token es obligatorio.");

                if (req.idUsuarioAlta <= 0)
                    req.idUsuarioAlta = req.idUsuario;

                if (req.minutosSesion <= 0)
                    req.minutosSesion = 5;

                db.Open();
                db.SetCommand("sp_sys_usuario_session_iniciar", true);
                db.AddParameter("idEntidad", req.idEntidad);
                db.AddParameter("idUsuario", req.idUsuario);
                db.AddParameter("Token", req.token);
                db.AddParameter("ip", string.IsNullOrWhiteSpace(req.ip) ? (object)DBNull.Value : req.ip);
                db.AddParameter("userAgent", string.IsNullOrWhiteSpace(req.userAgent) ? (object)DBNull.Value : req.userAgent);
                db.AddParameter("comentarios", string.IsNullOrWhiteSpace(req.comentarios) ? (object)DBNull.Value : req.comentarios);
                db.AddParameter("idUsuarioAlta", req.idUsuarioAlta);
                db.AddParameter("minutosSesion", req.minutosSesion);

                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                if (ds != null && ds.Tables.Count > 0)
                    ds.Tables[0].TableName = "Data";

                code = true;
                message = "Sesión iniciada correctamente.";
                response = MyToolsController.ToJson(code, message, ds);
            }
            catch (Exception ex)
            {
                try { db.Close(); } catch { }
                code = false;
                message = "Ex: " + ex.Message;
                response = MyToolsController.ToJson(code, message);
            }

            return response;
        }

        [HttpPost]
        [Route("ValidaSesionUsuario")]
        public IActionResult ValidaSesionUsuario([FromBody] ValidaSesionUsuarioRequest req)
        {
            JsonResult response;
            bool code;
            string message;
            DataBase2 db = new DataBase2();

            try
            {
                if (req == null)
                    return MyToolsController.ToJson(false, "Request inválido.");

                if (req.idEntidad <= 0)
                    return MyToolsController.ToJson(false, "El idEntidad es obligatorio.");

                if (string.IsNullOrWhiteSpace(req.token))
                    return MyToolsController.ToJson(false, "El token es obligatorio.");

                db.Open();
                db.SetCommand("sp_sys_usuario_session_validar", true);
                db.AddParameter("idEntidad", req.idEntidad);
                db.AddParameter("Token", req.token);

                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                if (ds != null && ds.Tables.Count > 0)
                    ds.Tables[0].TableName = "Data";

                bool sesionValida = false;

                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    sesionValida = Convert.ToInt32(ds.Tables[0].Rows[0]["ok"]) == 1;
                }

                code = sesionValida;
                message = sesionValida ? "Sesión válida." : "Sesión inválida o expirada.";
                response = MyToolsController.ToJson(code, message, ds);
            }
            catch (Exception ex)
            {
                try { db.Close(); } catch { }
                code = false;
                message = "Ex: " + ex.Message;
                response = MyToolsController.ToJson(code, message);
            }

            return response;
        }

        [HttpPost]
        [Route("HeartbeatSesionUsuario")]
        public IActionResult HeartbeatSesionUsuario([FromBody] HeartbeatSesionUsuarioRequest req)
        {
            JsonResult response;
            bool code;
            string message;
            DataBase2 db = new DataBase2();

            try
            {
                if (req == null)
                    return MyToolsController.ToJson(false, "Request inválido.");

                if (req.idEntidad <= 0)
                    return MyToolsController.ToJson(false, "El idEntidad es obligatorio.");

                if (string.IsNullOrWhiteSpace(req.token))
                    return MyToolsController.ToJson(false, "El token es obligatorio.");

                if (req.minutosSesion <= 0)
                    req.minutosSesion = 5;

                db.Open();
                db.SetCommand("sp_sys_usuario_session_heartbeat", true);
                db.AddParameter("idEntidad", req.idEntidad);
                db.AddParameter("Token", req.token);
                db.AddParameter("minutosSesion", req.minutosSesion);

                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                if (ds != null && ds.Tables.Count > 0)
                    ds.Tables[0].TableName = "Data";

                bool heartbeatOk = false;

                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    heartbeatOk = Convert.ToInt32(ds.Tables[0].Rows[0]["ok"]) == 1;
                }

                code = heartbeatOk;
                message = heartbeatOk ? "Heartbeat aplicado." : "Sesión inválida o expirada.";
                response = MyToolsController.ToJson(code, message, ds);
            }
            catch (Exception ex)
            {
                try { db.Close(); } catch { }
                code = false;
                message = "Ex: " + ex.Message;
                response = MyToolsController.ToJson(code, message);
            }

            return response;
        }

        [HttpPost]
        [Route("CerrarSesionUsuario")]
        public IActionResult CerrarSesionUsuario([FromBody] CerrarSesionUsuarioRequest req)
        {
            JsonResult response;
            bool code;
            string message;
            DataBase2 db = new DataBase2();

            try
            {
                if (req == null)
                    return MyToolsController.ToJson(false, "Request inválido.");

                if (req.idEntidad <= 0)
                    return MyToolsController.ToJson(false, "El idEntidad es obligatorio.");

                if (string.IsNullOrWhiteSpace(req.token))
                    return MyToolsController.ToJson(false, "El token es obligatorio.");

                db.Open();
                db.SetCommand("sp_sys_usuario_session_cerrar", true);
                db.AddParameter("idEntidad", req.idEntidad);
                db.AddParameter("Token", req.token);
                db.AddParameter("idUsuarioModifica", req.idUsuarioModifica.HasValue ? (object)req.idUsuarioModifica.Value : DBNull.Value);
                db.AddParameter("comentarios", string.IsNullOrWhiteSpace(req.comentarios) ? (object)DBNull.Value : req.comentarios);

                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                if (ds != null && ds.Tables.Count > 0)
                    ds.Tables[0].TableName = "Data";

                bool logoutOk = false;

                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    logoutOk = Convert.ToInt32(ds.Tables[0].Rows[0]["ok"]) == 1;
                }

                code = logoutOk;
                message = logoutOk ? "Sesión cerrada correctamente." : "No se encontró una sesión activa para cerrar.";
                response = MyToolsController.ToJson(code, message, ds);
            }
            catch (Exception ex)
            {
                try { db.Close(); } catch { }
                code = false;
                message = "Ex: " + ex.Message;
                response = MyToolsController.ToJson(code, message);
            }

            return response;
        }

        [HttpPost]
        [Route("ObtieneSesionActivaUsuario")]
        public IActionResult ObtieneSesionActivaUsuario([FromBody] ObtenerSesionActivaUsuarioRequest req)
        {
            JsonResult response;
            bool code;
            string message;
            DataBase2 db = new DataBase2();

            try
            {
                if (req == null)
                    return MyToolsController.ToJson(false, "Request inválido.");

                if (req.idEntidad <= 0)
                    return MyToolsController.ToJson(false, "El idEntidad es obligatorio.");

                if (req.idUsuario <= 0)
                    return MyToolsController.ToJson(false, "El idUsuario es obligatorio.");

                db.Open();
                db.SetCommand("sp_sys_usuario_session_obtener_activa", true);
                db.AddParameter("idEntidad", req.idEntidad);
                db.AddParameter("idUsuario", req.idUsuario);

                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                if (ds != null && ds.Tables.Count > 0)
                    ds.Tables[0].TableName = "Data";

                bool existeSesion = ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0;

                code = true;
                message = existeSesion ? "Sesión activa encontrada." : "El usuario no tiene sesión activa.";
                response = MyToolsController.ToJson(code, message, ds);
            }
            catch (Exception ex)
            {
                try { db.Close(); } catch { }
                code = false;
                message = "Ex: " + ex.Message;
                response = MyToolsController.ToJson(code, message);
            }

            return response;
        }
        #endregion
    }
}
