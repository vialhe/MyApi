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
    }
}
