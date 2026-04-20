SET NOCOUNT ON;

DECLARE @idEntidad int = 10007;
DECLARE @idUsuario int = 1;
DECLARE @folioCliente int = 1121;
DECLARE @idSucursal int = 1;
DECLARE @idProductoServicio int = 2650;
DECLARE @folioEmpleado int = 1132;
DECLARE @idTipoPago int = 1;

DECLARE @idOrigenAgenda int;
DECLARE @idRolPrincipal int;
DECLARE @idTipoMovimientoPagoAnticipo int;
DECLARE @idTipoMovimientoPagoLiquidacion int;
DECLARE @idEstatusEnProcesoDetalle int;
DECLARE @idEstatusConcluidoDetalle int;
DECLARE @idEstatusConcluidaAgenda int;
DECLARE @idTipoBloqueoHorarioComida int;
DECLARE @idEstatusCanceladaAgenda int;

DECLARE @Resultados TABLE
(
    orden int IDENTITY(1,1),
    caso varchar(200),
    resultado varchar(20),
    detalle varchar(1000)
);

DECLARE @ok bit;

/* =========================================================
   CATALOGOS BASE
   ========================================================= */
SELECT @idOrigenAgenda = idOrigenAgenda
FROM cat_origenAgenda
WHERE clave = 'POS'
  AND idEntidad = @idEntidad;

SELECT @idRolPrincipal = idRolParticipacionServicio
FROM cat_rolParticipacionServicio
WHERE clave = 'PRINCIPAL'
  AND idEntidad = @idEntidad;

SELECT @idTipoMovimientoPagoAnticipo = idTipoMovimientoPagoAgenda
FROM cat_tipoMovimientoPagoAgenda
WHERE clave = 'ANTICIPO'
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

SELECT @idEstatusCanceladaAgenda = idEstatusAgenda
FROM cat_estatusAgenda
WHERE clave = 'CANCELADA'
  AND idEntidad = @idEntidad;

SELECT @idTipoBloqueoHorarioComida = idTipoBloqueoHorario
FROM cat_tipoBloqueoHorario
WHERE clave = 'COMIDA'
  AND idEntidad = @idEntidad;

IF @idOrigenAgenda IS NULL OR
   @idRolPrincipal IS NULL OR
   @idTipoMovimientoPagoAnticipo IS NULL OR
   @idTipoMovimientoPagoLiquidacion IS NULL OR
   @idEstatusEnProcesoDetalle IS NULL OR
   @idEstatusConcluidoDetalle IS NULL OR
   @idEstatusConcluidaAgenda IS NULL OR
   @idEstatusCanceladaAgenda IS NULL OR
   @idTipoBloqueoHorarioComida IS NULL
BEGIN
    RAISERROR('Faltan catálogos base para ejecutar la validación final.',16,1);
    RETURN;
END

BEGIN TRY
    BEGIN TRAN;

    /* =========================================================
       PREPARACION HORARIO / BLOQUEO
       ========================================================= */
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoHorario
        WHERE idEntidad = @idEntidad
          AND folioEmpleado = @folioEmpleado
          AND diaSemana = 5
          AND horaEntrada = '2026-04-16 09:00:00'
          AND horaSalida = '2026-04-16 18:00:00'
          AND ISNULL(activo,1) = 1
    )
    BEGIN
        EXEC dbo.sp_ui_empleadoHorario
            @folioEmpleadoHorario = 0,
            @folioEmpleado = @folioEmpleado,
            @diaSemana = 5,
            @horaEntrada = '2026-04-16 09:00:00',
            @horaSalida = '2026-04-16 18:00:00',
            @comentarios = 'Horario validación final',
            @activo = 1,
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END

	IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoHorario
        WHERE idEntidad = @idEntidad
          AND folioEmpleado = @folioEmpleado
          AND diaSemana = 6
          AND horaEntrada = '2026-04-17 09:00:00'
          AND horaSalida = '2026-04-17 18:00:00'
          AND ISNULL(activo,1) = 1
    )
    BEGIN
        EXEC dbo.sp_ui_empleadoHorario
            @folioEmpleadoHorario = 0,
            @folioEmpleado = @folioEmpleado,
            @diaSemana = 6,
            @horaEntrada = '2026-04-17 09:00:00',
            @horaSalida = '2026-04-17 18:00:00',
            @comentarios = 'Horario validación final',
            @activo = 1,
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END

	IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoHorario
        WHERE idEntidad = @idEntidad
          AND folioEmpleado = @folioEmpleado
          AND diaSemana = 7
          AND horaEntrada = '2026-04-18 09:00:00'
          AND horaSalida = '2026-04-18 18:00:00'
          AND ISNULL(activo,1) = 1
    )
    BEGIN
        EXEC dbo.sp_ui_empleadoHorario
            @folioEmpleadoHorario = 0,
            @folioEmpleado = @folioEmpleado,
            @diaSemana = 7,
            @horaEntrada = '2026-04-18 09:00:00',
            @horaSalida = '2026-04-18 18:00:00',
            @comentarios = 'Horario validación final',
            @activo = 1,
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END

	IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoHorario
        WHERE idEntidad = @idEntidad
          AND folioEmpleado = @folioEmpleado
          AND diaSemana = 1
          AND horaEntrada = '2026-04-19 09:00:00'
          AND horaSalida = '2026-04-19 18:00:00'
          AND ISNULL(activo,1) = 1
    )
    BEGIN
        EXEC dbo.sp_ui_empleadoHorario
            @folioEmpleadoHorario = 0,
            @folioEmpleado = @folioEmpleado,
            @diaSemana = 1,
            @horaEntrada = '2026-04-19 09:00:00',
            @horaSalida = '2026-04-19 18:00:00',
            @comentarios = 'Horario validación final',
            @activo = 1,
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoBloqueoHorario
        WHERE idEntidad = @idEntidad
          AND folioEmpleado = @folioEmpleado
          AND CONVERT(date, fecha) = '2026-04-16'
          AND horaInicio = '2026-04-16 14:00:00'
          AND horaFin = '2026-04-16 15:00:00'
          AND idTipoBloqueoHorario = @idTipoBloqueoHorarioComida
          AND ISNULL(activo,1) = 1
    )
    BEGIN
        EXEC dbo.sp_ui_empleadoBloqueoHorario
            @folioEmpleadoBloqueoHorario = 0,
            @folioEmpleado = @folioEmpleado,
            @fecha = '2026-04-16',
            @horaInicio = '2026-04-16 14:00:00',
            @horaFin = '2026-04-16 15:00:00',
            @idTipoBloqueoHorario = @idTipoBloqueoHorarioComida,
            @motivo = 'Comida',
            @comentarios = 'Bloqueo validación final',
            @activo = 1,
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END

	IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoBloqueoHorario
        WHERE idEntidad = @idEntidad
          AND folioEmpleado = @folioEmpleado
          AND CONVERT(date, fecha) = '2026-04-17'
          AND horaInicio = '2026-04-17 14:00:00'
          AND horaFin = '2026-04-17 15:00:00'
          AND idTipoBloqueoHorario = @idTipoBloqueoHorarioComida
          AND ISNULL(activo,1) = 1
    )
    BEGIN
        EXEC dbo.sp_ui_empleadoBloqueoHorario
            @folioEmpleadoBloqueoHorario = 0,
            @folioEmpleado = @folioEmpleado,
            @fecha = '2026-04-17',
            @horaInicio = '2026-04-17 14:00:00',
            @horaFin = '2026-04-17 15:00:00',
            @idTipoBloqueoHorario = @idTipoBloqueoHorarioComida,
            @motivo = 'Comida',
            @comentarios = 'Bloqueo validación final',
            @activo = 1,
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END

	IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoBloqueoHorario
        WHERE idEntidad = @idEntidad
          AND folioEmpleado = @folioEmpleado
          AND CONVERT(date, fecha) = '2026-04-18'
          AND horaInicio = '2026-04-18 14:00:00'
          AND horaFin = '2026-04-18 15:00:00'
          AND idTipoBloqueoHorario = @idTipoBloqueoHorarioComida
          AND ISNULL(activo,1) = 1
    )
    BEGIN
        EXEC dbo.sp_ui_empleadoBloqueoHorario
            @folioEmpleadoBloqueoHorario = 0,
            @folioEmpleado = @folioEmpleado,
            @fecha = '2026-04-18',
            @horaInicio = '2026-04-18 14:00:00',
            @horaFin = '2026-04-18 15:00:00',
            @idTipoBloqueoHorario = @idTipoBloqueoHorarioComida,
            @motivo = 'Comida',
            @comentarios = 'Bloqueo validación final',
            @activo = 1,
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END

	IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoBloqueoHorario
        WHERE idEntidad = @idEntidad
          AND folioEmpleado = @folioEmpleado
          AND CONVERT(date, fecha) = '2026-04-19'
          AND horaInicio = '2026-04-19 14:00:00'
          AND horaFin = '2026-04-19 15:00:00'
          AND idTipoBloqueoHorario = @idTipoBloqueoHorarioComida
          AND ISNULL(activo,1) = 1
    )
    BEGIN
        EXEC dbo.sp_ui_empleadoBloqueoHorario
            @folioEmpleadoBloqueoHorario = 0,
            @folioEmpleado = @folioEmpleado,
            @fecha = '2026-04-19',
            @horaInicio = '2026-04-19 14:00:00',
            @horaFin = '2026-04-19 15:00:00',
            @idTipoBloqueoHorario = @idTipoBloqueoHorarioComida,
            @motivo = 'Comida',
            @comentarios = 'Bloqueo validación final',
            @activo = 1,
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END

    /* =========================================================
       CASO 1 - HAPPY PATH
       ========================================================= */
    DECLARE @AgendaHappy TABLE(folioAgenda int);
    DECLARE @DetalleHappy TABLE(folioAgendaDetalleServicio int);
    DECLARE @folioAgendaHappy int;
    DECLARE @folioDetalleHappy int;

    INSERT INTO @AgendaHappy(folioAgenda)
    EXEC dbo.sp_ui_agenda
        @folioAgenda = 0,
        @folioCliente = @folioCliente,
        @idSucursal = @idSucursal,
        @fechaCita = '2026-04-16 09:00:00',
        @horaInicioProgramada = '2026-04-16 09:00:00',
        @horaFinProgramada = '2026-04-16 10:00:00',
        @idOrigenAgenda = @idOrigenAgenda,
        @requiereConfirmacion = 1,
        @observacionesInternas = 'QA cierre happy',
        @comentarios = 'Happy path',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaHappy = folioAgenda FROM @AgendaHappy;

    INSERT INTO @DetalleHappy(folioAgendaDetalleServicio)
    EXEC dbo.sp_ui_agendaDetalleServicio
        @folioAgendaDetalleServicio = 0,
        @folioAgenda = @folioAgendaHappy,
        @idProductoServicio = @idProductoServicio,
        @precioFinal = 350,
        @descuento = 0,
        @cantidad = 1,
        @ordenServicio = 1,
        @horaInicioProgramada = '2026-04-16 09:00:00',
        @horaFinProgramada = '2026-04-16 10:00:00',
        @comentarios = 'Happy detalle',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioDetalleHappy = folioAgendaDetalleServicio FROM @DetalleHappy;

    EXEC dbo.sp_ui_agendaDetalleServicioEmpleado
        @folioAgendaDetalleServicioEmpleado = 0,
        @folioAgendaDetalleServicio = @folioDetalleHappy,
        @folioEmpleado = @folioEmpleado,
        @idRolParticipacionServicio = @idRolPrincipal,
        @porcentajeParticipacion = 100,
        @comisionCalculada = 0,
        @comentarios = 'Empleado happy',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_confirmarAgenda
        @folioAgenda = @folioAgendaHappy,
        @comentarios = 'Confirmación happy',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_agendaPago
        @folioAgenda = @folioAgendaHappy,
        @idTipoMovimientoPagoAgenda = @idTipoMovimientoPagoAnticipo,
        @idTipoPago = @idTipoPago,
        @montoPago = 100,
        @referenciaExterna = 'QA-HAPPY-100',
        @comentarios = 'Anticipo happy',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_agendaPago
        @folioAgenda = @folioAgendaHappy,
        @idTipoMovimientoPagoAgenda = @idTipoMovimientoPagoLiquidacion,
        @idTipoPago = @idTipoPago,
        @montoPago = 250,
        @referenciaExterna = 'QA-HAPPY-250',
        @comentarios = 'Liquidación happy',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_agendaCambioEstatusDetalleServicio
        @folioAgendaDetalleServicio = @folioDetalleHappy,
        @idEstatusAgendaDetalleServicioNuevo = @idEstatusEnProcesoDetalle,
        @descripcionMovimiento = 'Inicio happy',
        @comentarios = 'Inicio happy',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_agendaCambioEstatusDetalleServicio
        @folioAgendaDetalleServicio = @folioDetalleHappy,
        @idEstatusAgendaDetalleServicioNuevo = @idEstatusConcluidoDetalle,
        @descripcionMovimiento = 'Fin happy',
        @comentarios = 'Fin happy',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_agendaCambioEstatus
        @folioAgenda = @folioAgendaHappy,
        @idEstatusAgendaNuevo = @idEstatusConcluidaAgenda,
        @descripcionMovimiento = 'Cierre happy',
        @comentarios = 'Cierre happy',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SET @ok = 0;
    IF EXISTS
    (
        SELECT 1
        FROM dbo.proc_agenda a
        INNER JOIN dbo.cat_estatusAgenda ea
            ON ea.idEstatusAgenda = a.idEstatusAgenda
           AND ea.idEntidad = a.idEntidad
        WHERE a.folioAgenda = @folioAgendaHappy
          AND a.idEntidad = @idEntidad
          AND ea.clave = 'CONCLUIDA'
          AND ISNULL(a.totalPagado,0) = 350
          AND ISNULL(a.totalCotizado,0) = 350
    )
        SET @ok = 1;

    INSERT INTO @Resultados(caso, resultado, detalle)
    VALUES ('Happy path completo', IIF(@ok=1,'PASS','FAIL'),
            CONCAT('folioAgenda=',@folioAgendaHappy));

    /* =========================================================
       CASO 2 - AGENDA CON 2 DETALLES
       ========================================================= */
    DECLARE @AgendaMulti TABLE(folioAgenda int);
    DECLARE @Det1 TABLE(folioAgendaDetalleServicio int);
    DECLARE @Det2 TABLE(folioAgendaDetalleServicio int);
    DECLARE @folioAgendaMulti int;
    DECLARE @folioDet1 int;
    DECLARE @folioDet2 int;

    INSERT INTO @AgendaMulti(folioAgenda)
    EXEC dbo.sp_ui_agenda
        @folioAgenda = 0,
        @folioCliente = @folioCliente,
        @idSucursal = @idSucursal,
        @fechaCita = '2026-04-17 10:00:00',
        @horaInicioProgramada = '2026-04-17 10:00:00',
        @horaFinProgramada = '2026-04-17 12:00:00',
        @idOrigenAgenda = @idOrigenAgenda,
        @requiereConfirmacion = 1,
        @observacionesInternas = 'QA multi detalle',
        @comentarios = 'Multi detalle',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaMulti = folioAgenda FROM @AgendaMulti;

    INSERT INTO @Det1(folioAgendaDetalleServicio)
    EXEC dbo.sp_ui_agendaDetalleServicio
        @folioAgendaDetalleServicio = 0,
        @folioAgenda = @folioAgendaMulti,
        @idProductoServicio = @idProductoServicio,
        @precioFinal = 200,
        @descuento = 0,
        @cantidad = 1,
        @ordenServicio = 1,
        @horaInicioProgramada = '2026-04-17 10:00:00',
        @horaFinProgramada = '2026-04-17 11:00:00',
        @comentarios = 'Detalle 1',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    INSERT INTO @Det2(folioAgendaDetalleServicio)
    EXEC dbo.sp_ui_agendaDetalleServicio
        @folioAgendaDetalleServicio = 0,
        @folioAgenda = @folioAgendaMulti,
        @idProductoServicio = @idProductoServicio,
        @precioFinal = 150,
        @descuento = 0,
        @cantidad = 1,
        @ordenServicio = 2,
        @horaInicioProgramada = '2026-04-17 11:00:00',
        @horaFinProgramada = '2026-04-17 12:00:00',
        @comentarios = 'Detalle 2',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioDet1 = folioAgendaDetalleServicio FROM @Det1;
    SELECT TOP 1 @folioDet2 = folioAgendaDetalleServicio FROM @Det2;

    EXEC dbo.sp_ui_agendaDetalleServicioEmpleado
        @folioAgendaDetalleServicioEmpleado = 0,
        @folioAgendaDetalleServicio = @folioDet1,
        @folioEmpleado = @folioEmpleado,
        @idRolParticipacionServicio = @idRolPrincipal,
        @porcentajeParticipacion = 100,
        @comisionCalculada = 0,
        @comentarios = 'Emp det1',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_agendaDetalleServicioEmpleado
        @folioAgendaDetalleServicioEmpleado = 0,
        @folioAgendaDetalleServicio = @folioDet2,
        @folioEmpleado = @folioEmpleado,
        @idRolParticipacionServicio = @idRolPrincipal,
        @porcentajeParticipacion = 100,
        @comisionCalculada = 0,
        @comentarios = 'Emp det2',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SET @ok = 0;
    IF EXISTS
    (
        SELECT 1
        FROM dbo.proc_agenda
        WHERE folioAgenda = @folioAgendaMulti
          AND idEntidad = @idEntidad
          AND totalCotizado = 350
    )
        SET @ok = 1;

    INSERT INTO @Resultados(caso, resultado, detalle)
    VALUES ('Agenda con 2 detalles', IIF(@ok=1,'PASS','FAIL'),
            CONCAT('folioAgenda=',@folioAgendaMulti));

    /* =========================================================
       CASO 3 - CONFIRMACION INVALIDA SIN DETALLE
       ========================================================= */
    DECLARE @AgendaSinDetalle TABLE(folioAgenda int);
    DECLARE @folioAgendaSinDetalle int;
    DECLARE @falloEsperado bit;

    INSERT INTO @AgendaSinDetalle(folioAgenda)
    EXEC dbo.sp_ui_agenda
        @folioAgenda = 0,
        @folioCliente = @folioCliente,
        @idSucursal = @idSucursal,
        @fechaCita = '2026-04-18 09:00:00',
        @horaInicioProgramada = '2026-04-18 09:00:00',
        @horaFinProgramada = '2026-04-18 10:00:00',
        @idOrigenAgenda = @idOrigenAgenda,
        @requiereConfirmacion = 1,
        @observacionesInternas = 'Sin detalle',
        @comentarios = 'Sin detalle',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaSinDetalle = folioAgenda FROM @AgendaSinDetalle;

    SET @falloEsperado = 0;
    BEGIN TRY
        EXEC dbo.sp_ui_confirmarAgenda
            @folioAgenda = @folioAgendaSinDetalle,
            @comentarios = 'Debe fallar',
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END TRY
    BEGIN CATCH
        SET @falloEsperado = 1;
    END CATCH;

    INSERT INTO @Resultados(caso, resultado, detalle)
    VALUES ('Confirmación inválida sin detalle', IIF(@falloEsperado=1,'PASS','FAIL'),
            CONCAT('folioAgenda=',@folioAgendaSinDetalle));

    /* =========================================================
       CASO 4 - CONFIRMACION INVALIDA SIN EMPLEADO
       ========================================================= */
    DECLARE @AgendaSinEmpleado TABLE(folioAgenda int);
    DECLARE @DetalleSinEmpleado TABLE(folioAgendaDetalleServicio int);
    DECLARE @folioAgendaSinEmpleado int;

    INSERT INTO @AgendaSinEmpleado(folioAgenda)
    EXEC dbo.sp_ui_agenda
        @folioAgenda = 0,
        @folioCliente = @folioCliente,
        @idSucursal = @idSucursal,
        @fechaCita = '2026-04-18 11:00:00',
        @horaInicioProgramada = '2026-04-18 11:00:00',
        @horaFinProgramada = '2026-04-18 12:00:00',
        @idOrigenAgenda = @idOrigenAgenda,
        @requiereConfirmacion = 1,
        @observacionesInternas = 'Sin empleado',
        @comentarios = 'Sin empleado',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaSinEmpleado = folioAgenda FROM @AgendaSinEmpleado;

    INSERT INTO @DetalleSinEmpleado(folioAgendaDetalleServicio)
    EXEC dbo.sp_ui_agendaDetalleServicio
        @folioAgendaDetalleServicio = 0,
        @folioAgenda = @folioAgendaSinEmpleado,
        @idProductoServicio = @idProductoServicio,
        @precioFinal = 350,
        @descuento = 0,
        @cantidad = 1,
        @ordenServicio = 1,
        @horaInicioProgramada = '2026-04-18 11:00:00',
        @horaFinProgramada = '2026-04-18 12:00:00',
        @comentarios = 'Detalle sin emp',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SET @falloEsperado = 0;
    BEGIN TRY
        EXEC dbo.sp_ui_confirmarAgenda
            @folioAgenda = @folioAgendaSinEmpleado,
            @comentarios = 'Debe fallar sin empleado',
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END TRY
    BEGIN CATCH
        SET @falloEsperado = 1;
    END CATCH;

    INSERT INTO @Resultados(caso, resultado, detalle)
    VALUES ('Confirmación inválida sin empleado', IIF(@falloEsperado=1,'PASS','FAIL'),
            CONCAT('folioAgenda=',@folioAgendaSinEmpleado));

    /* =========================================================
       CASO 5 - SOBREPAGO POSTERIOR
       ========================================================= */
    SET @falloEsperado = 0;
    BEGIN TRY
        EXEC dbo.sp_ui_agendaPago
            @folioAgenda = @folioAgendaHappy,
            @idTipoMovimientoPagoAgenda = @idTipoMovimientoPagoLiquidacion,
            @idTipoPago = @idTipoPago,
            @montoPago = 1,
            @referenciaExterna = 'QA-SOBRANTE',
            @comentarios = 'Debe fallar',
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END TRY
    BEGIN CATCH
        SET @falloEsperado = 1;
    END CATCH;

    INSERT INTO @Resultados(caso, resultado, detalle)
    VALUES ('Sobrepago posterior', IIF(@falloEsperado=1,'PASS','FAIL'),
            CONCAT('folioAgenda=',@folioAgendaHappy));

    /* =========================================================
       CASO 6 - REPROGRAMACION NEGATIVA A BLOQUEO
       ========================================================= */
    DECLARE @AgendaReprog TABLE(folioAgenda int);
    DECLARE @DetalleReprog TABLE(folioAgendaDetalleServicio int);
    DECLARE @folioAgendaReprog int;
    DECLARE @folioDetalleReprog int;

    INSERT INTO @AgendaReprog(folioAgenda)
    EXEC dbo.sp_ui_agenda
        @folioAgenda = 0,
        @folioCliente = @folioCliente,
        @idSucursal = @idSucursal,
        @fechaCita = '2026-04-16 12:00:00',
        @horaInicioProgramada = '2026-04-16 12:00:00',
        @horaFinProgramada = '2026-04-16 13:00:00',
        @idOrigenAgenda = @idOrigenAgenda,
        @requiereConfirmacion = 1,
        @observacionesInternas = 'Reprog bloqueo',
        @comentarios = 'Reprog bloqueo',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaReprog = folioAgenda FROM @AgendaReprog;

    INSERT INTO @DetalleReprog(folioAgendaDetalleServicio)
    EXEC dbo.sp_ui_agendaDetalleServicio
        @folioAgendaDetalleServicio = 0,
        @folioAgenda = @folioAgendaReprog,
        @idProductoServicio = @idProductoServicio,
        @precioFinal = 350,
        @descuento = 0,
        @cantidad = 1,
        @ordenServicio = 1,
        @horaInicioProgramada = '2026-04-16 12:00:00',
        @horaFinProgramada = '2026-04-16 13:00:00',
        @comentarios = 'Det reprog',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioDetalleReprog = folioAgendaDetalleServicio FROM @DetalleReprog;

    EXEC dbo.sp_ui_agendaDetalleServicioEmpleado
        @folioAgendaDetalleServicioEmpleado = 0,
        @folioAgendaDetalleServicio = @folioDetalleReprog,
        @folioEmpleado = @folioEmpleado,
        @idRolParticipacionServicio = @idRolPrincipal,
        @porcentajeParticipacion = 100,
        @comisionCalculada = 0,
        @comentarios = 'Emp reprog',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_confirmarAgenda
        @folioAgenda = @folioAgendaReprog,
        @comentarios = 'Confirmada reprog',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SET @falloEsperado = 0;
    BEGIN TRY
        EXEC dbo.sp_ui_agendaReprogramacion
            @folioAgenda = @folioAgendaReprog,
            @fechaHoraNuevaInicio = '2026-04-16 14:00:00',
            @fechaHoraNuevaFin = '2026-04-16 15:00:00',
            @motivo = 'Debe fallar por bloqueo',
            @comentarios = 'Negativa bloqueo',
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END TRY
    BEGIN CATCH
        SET @falloEsperado = 1;
    END CATCH;

    INSERT INTO @Resultados(caso, resultado, detalle)
    VALUES ('Reprogramación negativa a bloqueo', IIF(@falloEsperado=1,'PASS','FAIL'),
            CONCAT('folioAgenda=',@folioAgendaReprog));

    /* =========================================================
       CASO 7 - REPROGRAMACION NEGATIVA FUERA DE HORARIO
       ========================================================= */
    SET @falloEsperado = 0;
    BEGIN TRY
        EXEC dbo.sp_ui_agendaReprogramacion
            @folioAgenda = @folioAgendaReprog,
            @fechaHoraNuevaInicio = '2026-04-16 08:00:00',
            @fechaHoraNuevaFin = '2026-04-16 09:00:00',
            @motivo = 'Debe fallar por horario',
            @comentarios = 'Negativa horario',
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END TRY
    BEGIN CATCH
        SET @falloEsperado = 1;
    END CATCH;

    INSERT INTO @Resultados(caso, resultado, detalle)
    VALUES ('Reprogramación negativa fuera de horario', IIF(@falloEsperado=1,'PASS','FAIL'),
            CONCAT('folioAgenda=',@folioAgendaReprog));

    /* =========================================================
       CASO 8 - REPROGRAMACION NEGATIVA CON EMPALME
       ========================================================= */
    DECLARE @AgendaEmpalme TABLE(folioAgenda int);
    DECLARE @DetalleEmpalme TABLE(folioAgendaDetalleServicio int);
    DECLARE @folioAgendaEmpalme int;
    DECLARE @folioDetalleEmpalme int;

    INSERT INTO @AgendaEmpalme(folioAgenda)
    EXEC dbo.sp_ui_agenda
        @folioAgenda = 0,
        @folioCliente = @folioCliente,
        @idSucursal = @idSucursal,
        @fechaCita = '2026-04-16 16:00:00',
        @horaInicioProgramada = '2026-04-16 16:00:00',
        @horaFinProgramada = '2026-04-16 17:00:00',
        @idOrigenAgenda = @idOrigenAgenda,
        @requiereConfirmacion = 1,
        @observacionesInternas = 'Agenda base empalme',
        @comentarios = 'Empalme base',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaEmpalme = folioAgenda FROM @AgendaEmpalme;

    INSERT INTO @DetalleEmpalme(folioAgendaDetalleServicio)
    EXEC dbo.sp_ui_agendaDetalleServicio
        @folioAgendaDetalleServicio = 0,
        @folioAgenda = @folioAgendaEmpalme,
        @idProductoServicio = @idProductoServicio,
        @precioFinal = 350,
        @descuento = 0,
        @cantidad = 1,
        @ordenServicio = 1,
        @horaInicioProgramada = '2026-04-16 16:00:00',
        @horaFinProgramada = '2026-04-16 17:00:00',
        @comentarios = 'Det empalme',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioDetalleEmpalme = folioAgendaDetalleServicio FROM @DetalleEmpalme;

    EXEC dbo.sp_ui_agendaDetalleServicioEmpleado
        @folioAgendaDetalleServicioEmpleado = 0,
        @folioAgendaDetalleServicio = @folioDetalleEmpalme,
        @folioEmpleado = @folioEmpleado,
        @idRolParticipacionServicio = @idRolPrincipal,
        @porcentajeParticipacion = 100,
        @comisionCalculada = 0,
        @comentarios = 'Emp empalme',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_confirmarAgenda
        @folioAgenda = @folioAgendaEmpalme,
        @comentarios = 'Confirmada empalme',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SET @falloEsperado = 0;
    BEGIN TRY
        EXEC dbo.sp_ui_agendaReprogramacion
            @folioAgenda = @folioAgendaReprog,
            @fechaHoraNuevaInicio = '2026-04-16 16:30:00',
            @fechaHoraNuevaFin = '2026-04-16 17:30:00',
            @motivo = 'Debe fallar por empalme',
            @comentarios = 'Negativa empalme',
            @idEntidad = @idEntidad,
            @idUsuarioAlta = @idUsuario;
    END TRY
    BEGIN CATCH
        SET @falloEsperado = 1;
    END CATCH;

    INSERT INTO @Resultados(caso, resultado, detalle)
    VALUES ('Reprogramación negativa con empalme', IIF(@falloEsperado=1,'PASS','FAIL'),
            CONCAT('folioAgenda=',@folioAgendaReprog));

    /* =========================================================
       CASO 9 - CANCELACION MIXTA
       ========================================================= */
    DECLARE @AgendaMixta TABLE(folioAgenda int);
    DECLARE @DetMixto1 TABLE(folioAgendaDetalleServicio int);
    DECLARE @DetMixto2 TABLE(folioAgendaDetalleServicio int);
    DECLARE @folioAgendaMixta int;
    DECLARE @folioDetMixto1 int;
    DECLARE @folioDetMixto2 int;

    INSERT INTO @AgendaMixta(folioAgenda)
    EXEC dbo.sp_ui_agenda
        @folioAgenda = 0,
        @folioCliente = @folioCliente,
        @idSucursal = @idSucursal,
        @fechaCita = '2026-04-19 10:00:00',
        @horaInicioProgramada = '2026-04-19 10:00:00',
        @horaFinProgramada = '2026-04-19 12:00:00',
        @idOrigenAgenda = @idOrigenAgenda,
        @requiereConfirmacion = 1,
        @observacionesInternas = 'Cancelación mixta',
        @comentarios = 'Cancelación mixta',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioAgendaMixta = folioAgenda FROM @AgendaMixta;

    INSERT INTO @DetMixto1(folioAgendaDetalleServicio)
    EXEC dbo.sp_ui_agendaDetalleServicio
        @folioAgendaDetalleServicio = 0,
        @folioAgenda = @folioAgendaMixta,
        @idProductoServicio = @idProductoServicio,
        @precioFinal = 200,
        @descuento = 0,
        @cantidad = 1,
        @ordenServicio = 1,
        @horaInicioProgramada = '2026-04-19 10:00:00',
        @horaFinProgramada = '2026-04-19 11:00:00',
        @comentarios = 'Mixto 1',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    INSERT INTO @DetMixto2(folioAgendaDetalleServicio)
    EXEC dbo.sp_ui_agendaDetalleServicio
        @folioAgendaDetalleServicio = 0,
        @folioAgenda = @folioAgendaMixta,
        @idProductoServicio = @idProductoServicio,
        @precioFinal = 150,
        @descuento = 0,
        @cantidad = 1,
        @ordenServicio = 2,
        @horaInicioProgramada = '2026-04-19 11:00:00',
        @horaFinProgramada = '2026-04-19 12:00:00',
        @comentarios = 'Mixto 2',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SELECT TOP 1 @folioDetMixto1 = folioAgendaDetalleServicio FROM @DetMixto1;
    SELECT TOP 1 @folioDetMixto2 = folioAgendaDetalleServicio FROM @DetMixto2;

    EXEC dbo.sp_ui_agendaDetalleServicioEmpleado
        @folioAgendaDetalleServicioEmpleado = 0,
        @folioAgendaDetalleServicio = @folioDetMixto1,
        @folioEmpleado = @folioEmpleado,
        @idRolParticipacionServicio = @idRolPrincipal,
        @porcentajeParticipacion = 100,
        @comisionCalculada = 0,
        @comentarios = 'Mixto det1',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_agendaDetalleServicioEmpleado
        @folioAgendaDetalleServicioEmpleado = 0,
        @folioAgendaDetalleServicio = @folioDetMixto2,
        @folioEmpleado = @folioEmpleado,
        @idRolParticipacionServicio = @idRolPrincipal,
        @porcentajeParticipacion = 100,
        @comisionCalculada = 0,
        @comentarios = 'Mixto det2',
        @activo = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_confirmarAgenda
        @folioAgenda = @folioAgendaMixta,
        @comentarios = 'Confirmada mixta',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_agendaCambioEstatusDetalleServicio
        @folioAgendaDetalleServicio = @folioDetMixto1,
        @idEstatusAgendaDetalleServicioNuevo = @idEstatusEnProcesoDetalle,
        @descripcionMovimiento = 'Mixto en proceso',
        @comentarios = 'Mixto en proceso',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_agendaCambioEstatusDetalleServicio
        @folioAgendaDetalleServicio = @folioDetMixto1,
        @idEstatusAgendaDetalleServicioNuevo = @idEstatusConcluidoDetalle,
        @descripcionMovimiento = 'Mixto concluido',
        @comentarios = 'Mixto concluido',
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    EXEC dbo.sp_ui_cancelarAgenda
        @folioAgenda = @folioAgendaMixta,
        @motivoCancelacion = 'Cancelar solo pendiente',
        @cancelarDetalles = 1,
        @idEntidad = @idEntidad,
        @idUsuarioAlta = @idUsuario;

    SET @ok = 0;
    IF EXISTS
    (
        SELECT 1
        FROM dbo.proc_agenda a
        INNER JOIN dbo.cat_estatusAgenda ea
            ON ea.idEstatusAgenda = a.idEstatusAgenda
           AND ea.idEntidad = a.idEntidad
        WHERE a.folioAgenda = @folioAgendaMixta
          AND a.idEntidad = @idEntidad
          AND ea.clave = 'CANCELADA'
    )
    AND EXISTS
    (
        SELECT 1
        FROM dbo.proc_agendaDetalleServicio ds
        INNER JOIN dbo.cat_estatusAgendaDetalleServicio eds
            ON eds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
           AND eds.idEntidad = ds.idEntidad
        WHERE ds.folioAgenda = @folioAgendaMixta
          AND ds.folioAgendaDetalleServicio = @folioDetMixto1
          AND eds.clave = 'CONCLUIDO'
    )
    AND EXISTS
    (
        SELECT 1
        FROM dbo.proc_agendaDetalleServicio ds
        INNER JOIN dbo.cat_estatusAgendaDetalleServicio eds
            ON eds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
           AND eds.idEntidad = ds.idEntidad
        WHERE ds.folioAgenda = @folioAgendaMixta
          AND ds.folioAgendaDetalleServicio = @folioDetMixto2
          AND eds.clave = 'CANCELADO'
    )
        SET @ok = 1;

    INSERT INTO @Resultados(caso, resultado, detalle)
    VALUES ('Cancelación mixta', IIF(@ok=1,'PASS','FAIL'),
            CONCAT('folioAgenda=',@folioAgendaMixta));

    /* =========================================================
       RESULTADOS FINALES
       ========================================================= */
    SELECT *
    FROM @Resultados
    ORDER BY orden;

    SELECT
        SUM(CASE WHEN resultado = 'PASS' THEN 1 ELSE 0 END) AS totalPass,
        SUM(CASE WHEN resultado = 'FAIL' THEN 1 ELSE 0 END) AS totalFail
    FROM @Resultados;

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    DECLARE @ErrorMessage varchar(4000) = ERROR_MESSAGE();
    DECLARE @ErrorLine int = ERROR_LINE();

    RAISERROR('Error en validación final. Línea: %d. Mensaje: %s',16,1,@ErrorLine,@ErrorMessage);
END CATCH;