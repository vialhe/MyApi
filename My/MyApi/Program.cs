using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using MyApi.Services.Firebase;
using MyApi.Services.Notificaciones;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy( builder => { builder.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod(); });
});

var firebaseEnabled = builder.Configuration.GetValue<bool>("Firebase:Enabled");
var firebaseCredentialPath = builder.Configuration["Firebase:CredentialPath"];

if (firebaseEnabled)
{
    if (string.IsNullOrWhiteSpace(firebaseCredentialPath))
        throw new Exception("No se configuró Firebase:CredentialPath en appsettings.json.");

    if (FirebaseApp.DefaultInstance == null)
    {
        FirebaseApp.Create(new AppOptions
        {
            Credential = GoogleCredential.FromFile(firebaseCredentialPath)
        });
    }
}

// Registrar servicios personalizados
builder.Services.AddSingleton<IFirebasePushService, FirebasePushService>();

builder.Services.AddScoped<INotificacionWorkerService, NotificacionWorkerService>();
builder.Services.AddHostedService<NotificacionBackgroundService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}


app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseCors();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
