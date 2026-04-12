SET NOCOUNT ON;

DECLARE @idEntidad int = 10007;
DECLARE @idUsuario int = 1;
DECLARE @folioCliente int = 1121;
DECLARE @idSucursal int = 1;
DECLARE @idProductoServicio int = 2650;
DECLARE @folioEmpleado int = 1132;

DECLARE @idOrigenAgenda int;
DECLARE @idRolPrincipal int;

DECLARE @folioAgenda TABLE (folioAgenda int);
DECLARE @folioAgendaDetalle TABLE (folioAgendaDetalleServicio int);

DECLARE @folioAgendaGenerado int;
DECLARE @folioAgendaDetalleGenerado int;

SELECT @idOrigenAgenda = idOrigenAgenda
FROM cat_origenAgenda
WHERE clave = 'POS'
  AND idEntidad = @idEntidad;

SELECT @idRolPrincipal = idRolParticipacionServicio
FROM cat_rolParticipacionServicio
WHERE clave = 'PRINCIPAL'
  AND idEntidad = @idEntidad;

IF @idOrigenAgenda IS NULL OR @idRolPrincipal IS NULL
BEGIN
    RAISERROR('Faltan catálogos base para ejecutar la prueba de cancelación.',16,1);
    RETURN;
END

BEGIN TRY
    BEGIN TRAN;

    /* 1) Crear agenda */
    INSERT INTO @folioAgenda(folioAgenda)
    EXEC dbo.sp_ui_agenda
        @folioAgenda = 0,
        @folioCliente = @folioCliente,
        @idSucursal = @idSucursal,
        @fechaCita = '2026-04-12 10:00:00',
        @horaInicioProgramada = '2026-04-12 10:00:00',
        @horaFinProgramada = '2026-04-12 11:00:00',
        @idOrigenAgenda = @idOrigenAgenda,
        @requiereConfirmacion = 1,
        @observacionesInternas = 'Prueba cancelación detalle',
        @comentarios = 'Alta agenda para cancelar detalle',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaGenerado = folioAgenda FROM @folioAgenda;

    /* 2) Crear detalle */
    INSERT INTO @folioAgendaDetalle(folioAgendaDetalleServicio)
    EXEC dbo.sp_ui_agendaDetalleServicio
        @folioAgendaDetalleServicio = 0,
        @folioAgenda = @folioAgendaGenerado,
        @idProductoServicio = @idProductoServicio,
        @precioFinal = 350.00,
        @descuento = 0,
        @cantidad = 1,
        @ordenServicio = 1,
        @horaInicioProgramada = '2026-04-12 10:00:00',
        @horaFinProgramada = '2026-04-12 11:00:00',
        @comentarios = 'Servicio principal',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaDetalleGenerado = folioAgendaDetalleServicio FROM @folioAgendaDetalle;

    /* 3) Asignar empleado */
    EXEC dbo.sp_ui_agendaDetalleServicioEmpleado
        @folioAgendaDetalleServicioEmpleado = 0,
        @folioAgendaDetalleServicio = @folioAgendaDetalleGenerado,
        @folioEmpleado = @folioEmpleado,
        @idRolParticipacionServicio = @idRolPrincipal,
        @porcentajeParticipacion = 100,
        @comisionCalculada = 0,
        @horaInicioReal = NULL,
        @horaFinReal = NULL,
        @comentarios = 'Empleado principal',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 4) Confirmar agenda */
    EXEC dbo.sp_ui_confirmarAgenda
        @folioAgenda = @folioAgendaGenerado,
        @comentarios = 'Confirmada para cancelación de detalle',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 5) Cancelar detalle */
    EXEC dbo.sp_ui_cancelarDetalleServicio
        @folioAgendaDetalleServicio = @folioAgendaDetalleGenerado,
        @motivoCancelacion = 'Cliente ya no quiso el servicio',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 6) Consultar resultado */
    EXEC dbo.sp_se_agendaDetalleCompleto
        @folioAgenda = @folioAgendaGenerado,
        @idEntidad = @idEntidad;

    COMMIT TRAN;

    SELECT
        @folioAgendaGenerado AS folioAgenda,
        @folioAgendaDetalleGenerado AS folioAgendaDetalleServicio;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    DECLARE @ErrorMessage varchar(4000) = ERROR_MESSAGE();
    DECLARE @ErrorLine int = ERROR_LINE();

    RAISERROR('Error en script maestro de cancelación de detalle. Línea: %d. Mensaje: %s',16,1,@ErrorLine,@ErrorMessage);
END CATCH;