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

DECLARE @folioAgendaA TABLE (folioAgenda int);
DECLARE @folioAgendaDetalleA TABLE (folioAgendaDetalleServicio int);
DECLARE @folioAgendaB TABLE (folioAgenda int);
DECLARE @folioAgendaDetalleB TABLE (folioAgendaDetalleServicio int);

DECLARE @folioAgendaGeneradoA int;
DECLARE @folioAgendaDetalleGeneradoA int;
DECLARE @folioAgendaGeneradoB int;
DECLARE @folioAgendaDetalleGeneradoB int;

SELECT @idOrigenAgenda = idOrigenAgenda
FROM cat_origenAgenda
WHERE clave = 'POS' AND idEntidad = @idEntidad;

SELECT @idRolPrincipal = idRolParticipacionServicio
FROM cat_rolParticipacionServicio
WHERE clave = 'PRINCIPAL' AND idEntidad = @idEntidad;

SELECT @idTipoMovimientoPagoLiquidacion = idTipoMovimientoPagoAgenda
FROM cat_tipoMovimientoPagoAgenda
WHERE clave = 'LIQUIDACION' AND idEntidad = @idEntidad;

SELECT @idEstatusEnProcesoDetalle = idEstatusAgendaDetalleServicio
FROM cat_estatusAgendaDetalleServicio
WHERE clave = 'ENPROCESO' AND idEntidad = @idEntidad;

SELECT @idEstatusConcluidoDetalle = idEstatusAgendaDetalleServicio
FROM cat_estatusAgendaDetalleServicio
WHERE clave = 'CONCLUIDO' AND idEntidad = @idEntidad;

SELECT @idEstatusConcluidaAgenda = idEstatusAgenda
FROM cat_estatusAgenda
WHERE clave = 'CONCLUIDA' AND idEntidad = @idEntidad;

SELECT @idTipoBloqueoHorarioComida = idTipoBloqueoHorario
FROM cat_tipoBloqueoHorario
WHERE clave = 'COMIDA' AND idEntidad = @idEntidad;

IF @idOrigenAgenda IS NULL OR
   @idRolPrincipal IS NULL OR
   @idTipoMovimientoPagoLiquidacion IS NULL OR
   @idEstatusEnProcesoDetalle IS NULL OR
   @idEstatusConcluidoDetalle IS NULL OR
   @idEstatusConcluidaAgenda IS NULL OR
   @idTipoBloqueoHorarioComida IS NULL
BEGIN
    RAISERROR('Faltan catálogos base para ejecutar la suite negativa.',16,1);
    RETURN;
END

BEGIN TRY
    BEGIN TRAN;

    /* Base: horario y bloqueo */
    EXEC dbo.sp_ui_empleadoHorario
        @folioEmpleadoHorario = 0,
        @folioEmpleado = @folioEmpleado,
        @diaSemana = 5,
        @horaEntrada = '2026-04-16 09:00:00',
        @horaSalida = '2026-04-16 18:00:00',
        @comentarios = 'Horario QA negativas',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_empleadoBloqueoHorario
        @folioEmpleadoBloqueoHorario = 0,
        @folioEmpleado = @folioEmpleado,
        @fecha = '2026-04-16',
        @horaInicio = '2026-04-16 14:00:00',
        @horaFin = '2026-04-16 15:00:00',
        @idTipoBloqueoHorario = @idTipoBloqueoHorarioComida,
        @motivo = 'Comida',
        @comentarios = 'Bloqueo QA negativas',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* Agenda A base: 10 a 11 */
    INSERT INTO @folioAgendaA(folioAgenda)
    EXEC dbo.sp_ui_agenda
        @folioAgenda = 0,
        @folioCliente = @folioCliente,
        @idSucursal = @idSucursal,
        @fechaCita = '2026-04-16 10:00:00',
        @horaInicioProgramada = '2026-04-16 10:00:00',
        @horaFinProgramada = '2026-04-16 11:00:00',
        @idOrigenAgenda = @idOrigenAgenda,
        @requiereConfirmacion = 1,
        @observacionesInternas = 'Base negativas A',
        @comentarios = 'Agenda A',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaGeneradoA = folioAgenda FROM @folioAgendaA;

    INSERT INTO @folioAgendaDetalleA(folioAgendaDetalleServicio)
    EXEC dbo.sp_ui_agendaDetalleServicio
        @folioAgendaDetalleServicio = 0,
        @folioAgenda = @folioAgendaGeneradoA,
        @idProductoServicio = @idProductoServicio,
        @precioFinal = 350.00,
        @descuento = 0,
        @cantidad = 1,
        @ordenServicio = 1,
        @horaInicioProgramada = '2026-04-16 10:00:00',
        @horaFinProgramada = '2026-04-16 11:00:00',
        @comentarios = 'Detalle A',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaDetalleGeneradoA = folioAgendaDetalleServicio FROM @folioAgendaDetalleA;

    EXEC dbo.sp_ui_agendaDetalleServicioEmpleado
        @folioAgendaDetalleServicioEmpleado = 0,
        @folioAgendaDetalleServicio = @folioAgendaDetalleGeneradoA,
        @folioEmpleado = @folioEmpleado,
        @idRolParticipacionServicio = @idRolPrincipal,
        @porcentajeParticipacion = 100,
        @comisionCalculada = 0,
        @comentarios = 'Empleado A',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 1) NEGATIVA: empleado duplicado en mismo detalle */
    BEGIN TRY
        EXEC dbo.sp_ui_agendaDetalleServicioEmpleado
            @folioAgendaDetalleServicioEmpleado = 0,
            @folioAgendaDetalleServicio = @folioAgendaDetalleGeneradoA,
            @folioEmpleado = @folioEmpleado,
            @idRolParticipacionServicio = @idRolPrincipal,
            @porcentajeParticipacion = 100,
            @comisionCalculada = 0,
            @comentarios = 'Duplicado',
            @activo = 1,
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;

        RAISERROR('FAIL: Se permitió asignar el mismo empleado dos veces al mismo detalle.',16,1);
    END TRY
    BEGIN CATCH
        PRINT 'OK duplicado empleado: ' + ERROR_MESSAGE();
    END CATCH;

    /* Agenda B base */
    INSERT INTO @folioAgendaB(folioAgenda)
    EXEC dbo.sp_ui_agenda
        @folioAgenda = 0,
        @folioCliente = @folioCliente,
        @idSucursal = @idSucursal,
        @fechaCita = '2026-04-16 10:30:00',
        @horaInicioProgramada = '2026-04-16 10:30:00',
        @horaFinProgramada = '2026-04-16 11:30:00',
        @idOrigenAgenda = @idOrigenAgenda,
        @requiereConfirmacion = 1,
        @observacionesInternas = 'Base negativas B',
        @comentarios = 'Agenda B',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaGeneradoB = folioAgenda FROM @folioAgendaB;

    INSERT INTO @folioAgendaDetalleB(folioAgendaDetalleServicio)
    EXEC dbo.sp_ui_agendaDetalleServicio
        @folioAgendaDetalleServicio = 0,
        @folioAgenda = @folioAgendaGeneradoB,
        @idProductoServicio = @idProductoServicio,
        @precioFinal = 350.00,
        @descuento = 0,
        @cantidad = 1,
        @ordenServicio = 1,
        @horaInicioProgramada = '2026-04-16 10:30:00',
        @horaFinProgramada = '2026-04-16 11:30:00',
        @comentarios = 'Detalle B',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaDetalleGeneradoB = folioAgendaDetalleServicio FROM @folioAgendaDetalleB;

    /* 2) NEGATIVA: empalme */
    BEGIN TRY
        EXEC dbo.sp_ui_agendaDetalleServicioEmpleado
            @folioAgendaDetalleServicioEmpleado = 0,
            @folioAgendaDetalleServicio = @folioAgendaDetalleGeneradoB,
            @folioEmpleado = @folioEmpleado,
            @idRolParticipacionServicio = @idRolPrincipal,
            @porcentajeParticipacion = 100,
            @comisionCalculada = 0,
            @comentarios = 'Empalme',
            @activo = 1,
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;

        RAISERROR('FAIL: Se permitió asignar empleado con empalme.',16,1);
    END TRY
    BEGIN CATCH
        PRINT 'OK empalme: ' + ERROR_MESSAGE();
    END CATCH;

    /* 3) NEGATIVA: fuera de horario */
    BEGIN TRY
        EXEC dbo.sp_ui_agendaDetalleServicio
            @folioAgendaDetalleServicio = @folioAgendaDetalleGeneradoB,
            @folioAgenda = @folioAgendaGeneradoB,
            @idProductoServicio = @idProductoServicio,
            @precioFinal = 350.00,
            @descuento = 0,
            @cantidad = 1,
            @ordenServicio = 1,
            @horaInicioProgramada = '2026-04-16 08:00:00',
            @horaFinProgramada = '2026-04-16 09:00:00',
            @comentarios = 'Fuera horario',
            @activo = 1,
            @idEntidad = @idEntidad,
            @idUsuarioModifica = @idUsuario,
            @idUsuarioAlta = @idUsuario;

        EXEC dbo.sp_ui_agendaDetalleServicioEmpleado
            @folioAgendaDetalleServicioEmpleado = 0,
            @folioAgendaDetalleServicio = @folioAgendaDetalleGeneradoB,
            @folioEmpleado = @folioEmpleado,
            @idRolParticipacionServicio = @idRolPrincipal,
            @porcentajeParticipacion = 100,
            @comisionCalculada = 0,
            @comentarios = 'Fuera horario',
            @activo = 1,
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;

        RAISERROR('FAIL: Se permitió asignación fuera de horario.',16,1);
    END TRY
    BEGIN CATCH
        PRINT 'OK fuera de horario: ' + ERROR_MESSAGE();
    END CATCH;

    /* 4) NEGATIVA: bloqueo comida */
    BEGIN TRY
        EXEC dbo.sp_se_disponibilidadEmpleado
            @folioEmpleado = @folioEmpleado,
            @fecha = '2026-04-16 14:00:00',
            @horaInicio = '2026-04-16 14:00:00',
            @horaFin = '2026-04-16 15:00:00',
            @idEntidad = @idEntidad,
            @folioAgendaDetalleServicioExcluir = NULL;
    END TRY
    BEGIN CATCH
        RAISERROR('FAIL: La consulta de disponibilidad no debía explotar.',16,1);
    END CATCH;

    /* 5) NEGATIVA: sobrepago */
    EXEC dbo.sp_ui_confirmarAgenda
        @folioAgenda = @folioAgendaGeneradoA,
        @comentarios = 'Confirmada A',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    BEGIN TRY
        EXEC dbo.sp_ui_agendaPago
            @folioAgenda = @folioAgendaGeneradoA,
            @idTipoMovimientoPagoAgenda = @idTipoMovimientoPagoLiquidacion,
            @idTipoPago = @idTipoPago,
            @montoPago = 9999.00,
            @referenciaExterna = 'SOBREPAGO',
            @comentarios = 'Sobrepago prueba',
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;

        RAISERROR('FAIL: Se permitió sobrepago.',16,1);
    END TRY
    BEGIN CATCH
        PRINT 'OK sobrepago: ' + ERROR_MESSAGE();
    END CATCH;

    /* 6) NEGATIVA: concluir agenda sin concluir detalle */
    BEGIN TRY
        EXEC dbo.sp_ui_agendaCambioEstatus
            @folioAgenda = @folioAgendaGeneradoA,
            @idEstatusAgendaNuevo = @idEstatusConcluidaAgenda,
            @descripcionMovimiento = 'Intento concluir sin concluir detalle',
            @comentarios = 'Negativa',
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;

        RAISERROR('FAIL: Se permitió concluir agenda sin concluir detalle.',16,1);
    END TRY
    BEGIN CATCH
        PRINT 'OK concluir agenda inválida: ' + ERROR_MESSAGE();
    END CATCH;

    /* 7) Preparación: concluir detalle A */
    EXEC dbo.sp_ui_agendaCambioEstatusDetalleServicio
        @folioAgendaDetalleServicio = @folioAgendaDetalleGeneradoA,
        @idEstatusAgendaDetalleServicioNuevo = @idEstatusEnProcesoDetalle,
        @descripcionMovimiento = 'Inicio detalle A',
        @comentarios = 'Preparación negativa',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_agendaCambioEstatusDetalleServicio
        @folioAgendaDetalleServicio = @folioAgendaDetalleGeneradoA,
        @idEstatusAgendaDetalleServicioNuevo = @idEstatusConcluidoDetalle,
        @descripcionMovimiento = 'Concluir detalle A',
        @comentarios = 'Preparación negativa',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 8) NEGATIVA: cancelar detalle concluido */
    BEGIN TRY
        EXEC dbo.sp_ui_cancelarDetalleServicio
            @folioAgendaDetalleServicio = @folioAgendaDetalleGeneradoA,
            @motivoCancelacion = 'No debería dejar',
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;

        RAISERROR('FAIL: Se permitió cancelar detalle concluido.',16,1);
    END TRY
    BEGIN CATCH
        PRINT 'OK cancelar detalle concluido: ' + ERROR_MESSAGE();
    END CATCH;

    /* 9) Preparación: concluir agenda A */
    EXEC dbo.sp_ui_agendaCambioEstatus
        @folioAgenda = @folioAgendaGeneradoA,
        @idEstatusAgendaNuevo = @idEstatusConcluidaAgenda,
        @descripcionMovimiento = 'Concluir agenda A',
        @comentarios = 'Preparación negativa',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    /* 10) NEGATIVA: reprogramar agenda concluida */
    BEGIN TRY
        EXEC dbo.sp_ui_agendaReprogramacion
            @folioAgenda = @folioAgendaGeneradoA,
            @fechaHoraNuevaInicio = '2026-04-16 16:00:00',
            @fechaHoraNuevaFin = '2026-04-16 17:00:00',
            @motivo = 'No debería dejar',
            @comentarios = 'Negativa reprogramación',
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;

        RAISERROR('FAIL: Se permitió reprogramar agenda concluida.',16,1);
    END TRY
    BEGIN CATCH
        PRINT 'OK reprogramar agenda concluida: ' + ERROR_MESSAGE();
    END CATCH;

    /* 11) NEGATIVA: cancelar agenda concluida */
    BEGIN TRY
        EXEC dbo.sp_ui_cancelarAgenda
            @folioAgenda = @folioAgendaGeneradoA,
            @motivoCancelacion = 'No debería dejar',
            @cancelarDetalles = 1,
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;

        RAISERROR('FAIL: Se permitió cancelar agenda concluida.',16,1);
    END TRY
    BEGIN CATCH
        PRINT 'OK cancelar agenda concluida: ' + ERROR_MESSAGE();
    END CATCH;

    COMMIT TRAN;

    SELECT
        @folioAgendaGeneradoA AS folioAgendaBase,
        @folioAgendaDetalleGeneradoA AS folioAgendaDetalleBase,
        @folioAgendaGeneradoB AS folioAgendaNegativaEmpalme,
        @folioAgendaDetalleGeneradoB AS folioAgendaDetalleNegativoEmpalme;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    DECLARE @ErrorMessage varchar(4000) = ERROR_MESSAGE();
    DECLARE @ErrorLine int = ERROR_LINE();

    RAISERROR('FAIL suite negativa. Línea: %d. Mensaje: %s',16,1,@ErrorLine,@ErrorMessage);
END CATCH;