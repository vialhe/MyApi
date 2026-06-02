namespace MyApi.Services.Firebase
{
    public class FirebasePushRequest
    {
        public string Token { get; set; } = string.Empty;

        public string Titulo { get; set; } = string.Empty;
        public string Mensaje { get; set; } = string.Empty;
        public string? ImagenUrl { get; set; }

        public string TipoNotificacion { get; set; } = string.Empty;
        public string? ReferenciaTipo { get; set; }
        public string? ReferenciaId { get; set; }

        public Dictionary<string, string> Data { get; set; } = new();
    }
}