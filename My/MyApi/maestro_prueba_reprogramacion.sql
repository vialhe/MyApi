SET NOCOUNT ON;

DECLARE @idEntidad int = 10007;
DECLARE @idUsuario int = 1;
DECLARE @folioCliente int = 1121;
DECLARE @idSucursal int = 1;
DECLARE @idProductoServicio int = 2650;
DECLARE @folioEmpleado int = 1132;

DECLARE @idOrigenAgenda int;
DECLARE @idRolPrincipal int;
DECLARE @idTipoBloqueoHorarioComida int;

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

SELECT @idTipoBloqueoHorarioComida = idTipoBloqueoHorario
FROM cat_tipoBloqueoHorario
WHERE clave = 'COMIDA'
  AND idEntidad = @idEntidad;

IF @idOrigenAgenda IS NULL OR
   @idRolPrincipal IS NULL OR
   @idTipoBloqueoHorarioComida IS NULL
BEGIN
    RAISERROR('Faltan catálogos base para ejecutar la prueba de reprogramación.',16,1);
    RETURN;
END

BEGIN TRY
    BEGIN TRAN;

    /* 1) Horario del empleado */
    EXEC dbo.sp_ui_empleadoHorario
        @folioEmpleadoHorario = 0,
        @folioEmpleado = @folioEmpleado,
        @diaSemana = 7,
        @horaEntrada = '2026-04-12 09:00:00',
        @horaSalida = '2026-04-12 18:00:00',
        @comentarios = '',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 2) Bloqueo de comida */
    EXEC dbo.sp_ui_empleadoBloqueoHorario
        @folioEmpleadoBloqueoHorario = 0,
        @folioEmpleado = @folioEmpleado,
        @fecha = '2026-04-12',
        @horaInicio = '2026-04-12 14:00:00',
        @horaFin = '2026-04-12 15:00:00',
        @idTipoBloqueoHorario = @idTipoBloqueoHorarioComida,
        @motivo = 'Comida',
        @comentarios = 'Bloqueo comida reprogramación',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 3) Crear agenda inicial 10:00 a 11:00 */
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
        @observacionesInternas = 'Prueba reprogramación',
        @comentarios = 'Alta agenda para reprogramar',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaGenerado = folioAgenda FROM @folioAgenda;

    /* 4) Crear detalle */
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

    /* 5) Asignar empleado */
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

    /* 6) Confirmar agenda */
    EXEC dbo.sp_ui_confirmarAgenda
        @folioAgenda = @folioAgendaGenerado,
        @comentarios = 'Confirmada para reprogramación',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 7) Consultar disponibilidad antes de reprogramar */
    EXEC dbo.sp_se_horariosDisponiblesServicio
        @idProductoServicio = @idProductoServicio,
        @fecha = '2026-04-12',
        @idEntidad = @idEntidad,
        @folioEmpleado = @folioEmpleado,
        @intervaloMin = 60;

    /* 8) Reprogramar a 12:00 a 13:00 */
    EXEC dbo.sp_ui_agendaReprogramacion
        @folioAgenda = @folioAgendaGenerado,
        @fechaHoraNuevaInicio = '2026-04-12 12:00:00',
        @fechaHoraNuevaFin = '2026-04-12 13:00:00',
        @motivo = 'Cliente pidió mover horario',
        @comentarios = 'Reprogramación de prueba',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 9) Consultar resultado final */
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

    RAISERROR('Error en script maestro de reprogramación. Línea: %d. Mensaje: %s',16,1,@ErrorLine,@ErrorMessage);
END CATCH;