SET NOCOUNT ON;

DECLARE @idEntidad int = 10007;
DECLARE @idUsuario int = 1;
DECLARE @folioCliente int = 1121;
DECLARE @idSucursal int = 1;
DECLARE @idProductoServicio int = 2650;
DECLARE @folioEmpleado int = 1132;
DECLARE @idTipoPago int = 1; -- efectivo

DECLARE @idOrigenAgenda int;
DECLARE @idRolPrincipal int;
DECLARE @idTipoMovimientoPagoLiquidacion int;
DECLARE @idEstatusEnProcesoDetalle int;
DECLARE @idEstatusConcluidoDetalle int;
DECLARE @idEstatusConcluidaAgenda int;
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

SELECT @idTipoMovimientoPagoLiquidacion = idTipoMovimientoPagoAgenda
FROM cat_tipoMovimientoPagoAgenda
WHERE clave = 'LIQUIDACION'
  AND idEntidad = @idEntidad;

SELECT @idEstatusEnProcesoDetalle = idEstatusAgendaDetalleServicio
FROM cat_estatusAgendaDetalleServicio
WHERE clave = 'ENPROCESO'
  AND idEntidad = @idEntidad;

SELECT @idEstatusConcluidoDetalle = idEstatusAgendaDetalleServicio
FROM cat_estatusAgendaDetalleServicio
WHERE clave = 'CONCLUIDO'
  AND idEntidad = @idEntidad;

SELECT @idEstatusConcluidaAgenda = idEstatusAgenda
FROM cat_estatusAgenda
WHERE clave = 'CONCLUIDA'
  AND idEntidad = @idEntidad;

SELECT @idTipoBloqueoHorarioComida = idTipoBloqueoHorario
FROM cat_tipoBloqueoHorario
WHERE clave = 'COMIDA'
  AND idEntidad = @idEntidad;

IF @idOrigenAgenda IS NULL OR
   @idRolPrincipal IS NULL OR
   @idTipoMovimientoPagoLiquidacion IS NULL OR
   @idEstatusEnProcesoDetalle IS NULL OR
   @idEstatusConcluidoDetalle IS NULL OR
   @idEstatusConcluidaAgenda IS NULL OR
   @idTipoBloqueoHorarioComida IS NULL
BEGIN
    RAISERROR('Faltan catálogos base para ejecutar la prueba.',16,1);
    RETURN;
END

BEGIN TRY
    BEGIN TRAN;

    /* 1) Horario empleado */
    EXEC dbo.sp_ui_empleadoHorario
        @folioEmpleadoHorario = 0,
        @folioEmpleado = @folioEmpleado,
        @diaSemana = 6,
        @horaEntrada = '2026-04-11 09:00:00',
        @horaSalida = '2026-04-11 18:00:00',
        @comentarios = 'Horario jueves prueba',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 2) Bloqueo comida */
    EXEC dbo.sp_ui_empleadoBloqueoHorario
        @folioEmpleadoBloqueoHorario = 0,
        @folioEmpleado = @folioEmpleado,
        @fecha = '2026-04-11',
        @horaInicio = '2026-04-11 14:00:00',
        @horaFin = '2026-04-11 15:00:00',
        @idTipoBloqueoHorario = @idTipoBloqueoHorarioComida,
        @motivo = 'Comida',
        @comentarios = 'Bloqueo de comida prueba',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 3) Disponibilidad */
    EXEC dbo.sp_se_horariosDisponiblesServicio
        @idProductoServicio = @idProductoServicio,
        @fecha = '2026-04-11',
        @idEntidad = @idEntidad,
        @folioEmpleado = @folioEmpleado,
        @intervaloMin = 60;

    /* 4) Crear agenda */
    INSERT INTO @folioAgenda(folioAgenda)
    EXEC dbo.sp_ui_agenda
        @folioAgenda = 0,
        @folioCliente = @folioCliente,
        @idSucursal = @idSucursal,
        @fechaCita = '2026-04-11 10:00:00',
        @horaInicioProgramada = '2026-04-11 10:00:00',
        @horaFinProgramada = '2026-04-11 11:00:00',
        @idOrigenAgenda = @idOrigenAgenda,
        @requiereConfirmacion = 1,
        @observacionesInternas = 'Caso feliz de prueba',
        @comentarios = 'Alta de agenda',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaGenerado = folioAgenda FROM @folioAgenda;

    /* 5) Crear detalle */
    INSERT INTO @folioAgendaDetalle(folioAgendaDetalleServicio)
    EXEC dbo.sp_ui_agendaDetalleServicio
        @folioAgendaDetalleServicio = 0,
        @folioAgenda = @folioAgendaGenerado,
        @idProductoServicio = @idProductoServicio,
        @precioFinal = 350.00,
        @descuento = 0,
        @cantidad = 1,
        @ordenServicio = 1,
        @horaInicioProgramada = '2026-04-11 10:00:00',
        @horaFinProgramada = '2026-04-11 11:00:00',
        @comentarios = 'Servicio principal',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaDetalleGenerado = folioAgendaDetalleServicio FROM @folioAgendaDetalle;

    /* 6) Asignar empleado */
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

    /* 7) Confirmar agenda */
    EXEC dbo.sp_ui_confirmarAgenda
        @folioAgenda = @folioAgendaGenerado,
        @comentarios = 'Confirmada por mostrador',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 8) Registrar pago */
    EXEC dbo.sp_ui_agendaPago
        @folioAgenda = @folioAgendaGenerado,
        @idTipoMovimientoPagoAgenda = @idTipoMovimientoPagoLiquidacion,
        @idTipoPago = @idTipoPago,
        @montoPago = 100.00,
        @numeroAutorizacion = NULL,
        @referenciaOperacion = NULL,
        @referenciaExterna = 'PAGO-PRUEBA-001',
        @comentarios = 'Pago inicial',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 9) Iniciar servicio */
    EXEC dbo.sp_ui_agendaCambioEstatusDetalleServicio
        @folioAgendaDetalleServicio = @folioAgendaDetalleGenerado,
        @idEstatusAgendaDetalleServicioNuevo = @idEstatusEnProcesoDetalle,
        @descripcionMovimiento = 'Inicio del servicio',
        @comentarios = 'Se comenzó atención',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 10) Concluir servicio */
    EXEC dbo.sp_ui_agendaCambioEstatusDetalleServicio
        @folioAgendaDetalleServicio = @folioAgendaDetalleGenerado,
        @idEstatusAgendaDetalleServicioNuevo = @idEstatusConcluidoDetalle,
        @descripcionMovimiento = 'Servicio concluido',
        @comentarios = 'Se terminó correctamente',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 11) Concluir agenda */
    EXEC dbo.sp_ui_agendaCambioEstatus
        @folioAgenda = @folioAgendaGenerado,
        @idEstatusAgendaNuevo = @idEstatusConcluidaAgenda,
        @descripcionMovimiento = 'Agenda concluida',
        @comentarios = 'Todos los servicios terminados',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 12) Consultar resultado final */
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

    RAISERROR('Error en script maestro. Línea: %d. Mensaje: %s',16,1,@ErrorLine,@ErrorMessage);
END CATCH;