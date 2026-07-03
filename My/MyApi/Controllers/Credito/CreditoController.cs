using Microsoft.AspNetCore.Mvc;
using System.Data;
using MyApi.Models.MyDB;
using MyApi.Models.Credito;
using MyApi.Controllers.MyTools;

namespace MyApi.Controllers.Credito
{
    [ApiController]
    [Route("[controller]")]
    public class CreditoController : ControllerBase
    {
        // ================================================================
        // A) CONFIGURACION
        // ================================================================

        [HttpPost]
        [Route("configuracion-get")]
        public IActionResult ConfiguracionGet(ConfiguracionCreditoRequest data)
        {
            if (data == null)
                return BadRequest("Los datos no pueden ser nulos.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_ui_creditoConfiguracionGet", true);
                db.AddParameter("@idEntidad", data.idEntidad);
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
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
        [Route("configuracion-guardar")]
        public IActionResult ConfiguracionGuardar(ConfiguracionCreditoGuardarRequest data)
        {
            if (data == null)
                return BadRequest("Los datos no pueden ser nulos.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_ui_creditoConfiguracionGuardar", true);
                db.AddParameter("@idEntidad", data.idEntidad);
                db.AddParameter("@tipoValorRecargo", data.tipoValorRecargo);
                db.AddParameter("@nivelAplicacion", data.nivelAplicacion);
                db.AddParameter("@valorRecargo", data.valorRecargo);
                db.AddParameter("@diasVencimientoCargo", data.diasVencimientoCargo);
                db.AddParameter("@limiteCreditoDefaultExpress", data.limiteCreditoDefaultExpress);
                db.AddParameter("@idUsuarioAlta", data.idUsuarioAlta);
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }
            return Response;
        }

        // ================================================================
        // B) CLIENTE / LIMITE
        // ================================================================

        [HttpPost]
        [Route("cliente-habilitar")]
        public IActionResult ClienteHabilitar(ClienteHabilitarRequest data)
        {
            if (data == null)
                return BadRequest("Los datos no pueden ser nulos.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_ui_creditoClienteHabilitar", true);
                db.AddParameter("@idPersona", data.idPersona);
                db.AddParameter("@creditoHabilitado", data.creditoHabilitado);
                db.AddParameter("@limiteCredito", data.limiteCredito.HasValue ? data.limiteCredito.Value : (object)DBNull.Value);
                db.AddParameter("@idEntidad", data.idEntidad);
                db.AddParameter("@idUsuarioAlta", data.idUsuarioAlta);
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
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
        [Route("limite-actualizar")]
        public IActionResult LimiteActualizar(LimiteActualizarRequest data)
        {
            if (data == null)
                return BadRequest("Los datos no pueden ser nulos.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_ui_creditoLimiteActualizar", true);
                db.AddParameter("@idPersona", data.idPersona);
                db.AddParameter("@limiteNuevo", data.limiteNuevo);
                db.AddParameter("@motivo", data.motivo);
                db.AddParameter("@idEntidad", data.idEntidad);
                db.AddParameter("@idSucursal", data.idSucursal);
                db.AddParameter("@idUsuarioAlta", data.idUsuarioAlta);
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }
            return Response;
        }

        // ================================================================
        // C) NUCLEO TRANSACCIONAL
        // ================================================================

        [HttpPost]
        [Route("calcular-recargo")]
        public IActionResult CalcularRecargo(CalcularRecargoRequest data)
        {
            if (data == null || data.carrito == null || data.carrito.Count == 0)
                return BadRequest("El carrito no puede ser nulo o vacio.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                // fn_creditoCalcularRecargo es una funcion de tabla (TVF): se invoca
                // por texto, no como SP, para poder hacer SELECT * FROM dbo.fn_...().
                db.SetCommand(
                    "SELECT * FROM dbo.fn_creditoCalcularRecargo(@idEntidad, @carrito)",
                    false);
                db.AddParameter("@idEntidad", data.idEntidad);
                db.AddTableParameter("@carrito", BuildCarritoTable(data.carrito), "dbo.tvp_creditoCarritoItem");
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
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
        [Route("insert-cargo")]
        public IActionResult InsertCargo(InsertCargoRequest data)
        {
            // Nota: este endpoint se llama desde la API como paso adicional dentro
            // de la misma transaccion de la venta (sp_in_entradasSalidas /
            // sp_in_entradasSalidasDetalles / sp_in_EntradasSalidaPago), justo
            // despues de insertar en proc_entradasSalidaPago la fila con
            // idTipoPago = Credito. Por ahora queda como endpoint independiente;
            // la orquestacion con SaleController.SalePut es el siguiente paso
            // pendiente de confirmar contigo.
            if (data == null)
                return BadRequest("Los datos no pueden ser nulos.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_ui_creditoInsertCargo", true);
                db.AddParameter("@folioEntradaSalida", data.folioEntradaSalida);
                db.AddParameter("@idPersona", data.idPersona);
                db.AddParameter("@montoConRecargo", data.montoConRecargo);
                db.AddParameter("@idEntidad", data.idEntidad);
                db.AddParameter("@idSucursal", data.idSucursal);
                db.AddParameter("@idUsuarioAlta", data.idUsuarioAlta);
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
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
        [Route("insert-abono")]
        public IActionResult InsertAbono(InsertAbonoRequest data)
        {
            if (data == null || data.pagos == null || data.pagos.Count == 0)
                return BadRequest("Debe capturar al menos una forma de pago.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_ui_creditoInsertAbono", true);
                db.AddParameter("@idPersona", data.idPersona);
                db.AddTableParameter("@pagos", BuildPagosTable(data.pagos), "dbo.tvp_creditoPago");
                db.AddParameter("@esLiquidacion", data.esLiquidacion);
                db.AddParameter("@idEntidad", data.idEntidad);
                db.AddParameter("@idSucursal", data.idSucursal);
                db.AddParameter("@idUsuarioAlta", data.idUsuarioAlta);
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
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
        [Route("insert-ajuste")]
        public IActionResult InsertAjuste(InsertAjusteRequest data)
        {
            if (data == null)
                return BadRequest("Los datos no pueden ser nulos.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_ui_creditoInsertAjuste", true);
                db.AddParameter("@idPersona", data.idPersona);
                db.AddParameter("@monto", data.monto);
                db.AddParameter("@motivo", data.motivo);
                db.AddParameter("@idEntidad", data.idEntidad);
                db.AddParameter("@idSucursal", data.idSucursal);
                db.AddParameter("@idUsuarioAlta", data.idUsuarioAlta);
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
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
        [Route("reversa-cargo")]
        public IActionResult ReversaCargo(ReversaCargoRequest data)
        {
            // Nota: en el flujo normal esta reversa se dispara automaticamente desde
            // sp_in_movimentosInventarios cuando se cancela un ticket (tipo 1004).
            // Este endpoint queda disponible por si se necesita disparar la reversa
            // manualmente desde el API.
            if (data == null)
                return BadRequest("Los datos no pueden ser nulos.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_ui_creditoReversaCargo", true);
                db.AddParameter("@folioEntradaSalida", data.folioEntradaSalida);
                db.AddParameter("@idEntidad", data.idEntidad);
                db.AddParameter("@idSucursal", data.idSucursal);
                db.AddParameter("@idUsuarioAlta", data.idUsuarioAlta);
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }
            return Response;
        }

        // ================================================================
        // D) CONSULTA / LECTURA
        // ================================================================

        [HttpPost]
        [Route("get-saldo-cliente")]
        public IActionResult GetSaldoCliente(GetSaldoClienteRequest data)
        {
            if (data == null)
                return BadRequest("Los datos no pueden ser nulos.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_ui_creditoGetSaldoCliente", true);
                db.AddParameter("@idPersona", data.idPersona);
                db.AddParameter("@idEntidad", data.idEntidad);
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                if (ds.Tables[0].Rows.Count > 0)
                {
                    ds.Tables[0].TableName = "Data";
                    Code = true;
                    Message = "Success";
                    Response = MyToolsController.ToJson(Code, Message, ds);
                }
                else
                {
                    Code = false;
                    Message = "Cliente no encontrado";
                    Response = MyToolsController.ToJson(Code, Message);
                }
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
        [Route("get-historial-cliente")]
        public IActionResult GetHistorialCliente(GetHistorialClienteRequest data)
        {
            if (data == null)
                return BadRequest("Los datos no pueden ser nulos.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_ui_creditoGetHistorialCliente", true);
                db.AddParameter("@idPersona", data.idPersona);
                db.AddParameter("@idEntidad", data.idEntidad);
                db.AddParameter("@fechaInicio", data.fechaInicio.HasValue ? data.fechaInicio.Value : (object)DBNull.Value);
                db.AddParameter("@fechaFin", data.fechaFin.HasValue ? data.fechaFin.Value : (object)DBNull.Value);
                db.AddParameter("@clave", string.IsNullOrEmpty(data.clave) ? (object)DBNull.Value : data.clave);
                db.AddParameter("@pagina", data.pagina);
                db.AddParameter("@tamanoPagina", data.tamanoPagina);
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
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
        [Route("get-historial-global")]
        public IActionResult GetHistorialGlobal(GetHistorialGlobalRequest data)
        {
            if (data == null)
                return BadRequest("Los datos no pueden ser nulos.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_ui_creditoGetHistorialGlobal", true);
                db.AddParameter("@idEntidad", data.idEntidad);
                db.AddParameter("@idSucursal", data.idSucursal.HasValue ? data.idSucursal.Value : (object)DBNull.Value);
                db.AddParameter("@idUsuarioAlta", data.idUsuarioAlta.HasValue ? data.idUsuarioAlta.Value : (object)DBNull.Value);
                db.AddParameter("@clave", string.IsNullOrEmpty(data.clave) ? (object)DBNull.Value : data.clave);
                db.AddParameter("@fechaInicio", data.fechaInicio.HasValue ? data.fechaInicio.Value : (object)DBNull.Value);
                db.AddParameter("@fechaFin", data.fechaFin.HasValue ? data.fechaFin.Value : (object)DBNull.Value);
                db.AddParameter("@pagina", data.pagina);
                db.AddParameter("@tamanoPagina", data.tamanoPagina);
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
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
        [Route("get-listado-clientes")]
        public IActionResult GetListadoClientes(GetListadoClientesRequest data)
        {
            if (data == null)
                return BadRequest("Los datos no pueden ser nulos.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_ui_creditoGetListadoClientes", true);
                db.AddParameter("@idEntidad", data.idEntidad);
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "Data";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
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
        [Route("get-dashboard")]
        public IActionResult GetDashboard(GetDashboardCreditoRequest data)
        {
            if (data == null)
                return BadRequest("Los datos no pueden ser nulos.");

            JsonResult Response;
            bool Code;
            string Message;
            var db = new DataBase2();

            try
            {
                db.Open();
                db.SetCommand("sp_ui_creditoGetDashboard", true);
                db.AddParameter("@idEntidad", data.idEntidad);
                db.AddParameter("@fechaInicio", data.fechaInicio);
                db.AddParameter("@fechaFin", data.fechaFin);
                DataSet ds = db.ExecuteWithDataSet();
                db.Close();

                ds.Tables[0].TableName = "totalCartera";
                ds.Tables[1].TableName = "otorgadoVsCobrado";
                ds.Tables[2].TableName = "topRezago";
                Code = true;
                Message = "Success";
                Response = MyToolsController.ToJson(Code, Message, ds);
            }
            catch (Exception ex)
            {
                Code = false;
                Message = "Ex: " + ex.Message;
                Response = MyToolsController.ToJson(Code, Message);
            }
            return Response;
        }

        // ================================================================
        // Helpers: construccion de DataTable para los TVP
        // ================================================================

        private static DataTable BuildCarritoTable(List<CarritoCreditoItem> carrito)
        {
            var table = new DataTable();
            table.Columns.Add("idProductoServicio", typeof(int));
            table.Columns.Add("cantidad", typeof(decimal));
            table.Columns.Add("precio", typeof(decimal));

            foreach (var item in carrito)
            {
                table.Rows.Add(item.idProductoServicio, item.cantidad, item.precio);
            }
            return table;
        }

        private static DataTable BuildPagosTable(List<PagoCredito> pagos)
        {
            var table = new DataTable();
            table.Columns.Add("idTipoPago", typeof(int));
            table.Columns.Add("montoPago", typeof(decimal));
            table.Columns.Add("numeroAutorizacion", typeof(string));

            foreach (var pago in pagos)
            {
                table.Rows.Add(pago.idTipoPago, pago.montoPago, pago.numeroAutorizacion);
            }
            return table;
        }
    }
}
