namespace MyApi.Models.Notificacion
{
    public class EnviaPushTokenRequest
    {
        public string token { get; set; } = string.Empty;
        public string titulo { get; set; } = string.Empty;
        public string mensaje { get; set; } = string.Empty;
        public string? imagenUrl { get; set; }

        public string tipoNotificacion { get; set; } = "PRUEBA";
        public string? referenciaTipo { get; set; }
        public string? referenciaId { get; set; }

        public Dictionary<string, string>? data { get; set; }
    }
}