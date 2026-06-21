ALTER PROCEDURE dbo.sp_ui_agendaDetalleServicioReprogramacion
(
    @folioAgendaDetalleServicio int,
    @fechaHoraNuevaInicio datetime,
    @fechaHoraNuevaFin datetime,
    @folioEmpleadoNuevo int = NULL,
    @motivo varchar(450) = NULL,
    @comentarios varchar(450) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @folioAgenda int,
        @idSucursal int,
        @claveAgenda varchar(50),
        @claveDetalle varchar(50),
        @fechaHoraAnteriorInicio datetime,
        @fechaHoraAnteriorFin datetime,
        @duracionOriginalMin int,
        @duracionNuevaMin int,
        @folioEmpleadoAnterior int,
        @folioEmpleadoFinal int,
        @empleadosActivos int,
        @idTipoMovimientoAgenda int,
        @folioAgendaDetalleServicioReprogramacion int,
        @horaInicioGlobal datetime,
        @horaFinGlobal datetime;

    BEGIN TRY
        BEGIN TRAN;

        /* =========================================================
           1) LEER DETALLE BASE CON BLOQUEO
           ========================================================= */
        SELECT
            @folioAgenda = ds.folioAgenda,
            @fechaHoraAnteriorInicio = ds.horaInicioProgramada,
            @fechaHoraAnteriorFin = ds.horaFinProgramada,
            @claveDetalle = eds.clave
        FROM dbo.proc_agendaDetalleServicio ds WITH (UPDLOCK, HOLDLOCK)
        INNER JOIN dbo.cat_estatusAgendaDetalleServicio eds
            ON eds.id = ds.idEstatusAgendaDetalleServicio
           AND eds.idEntidad = ds.idEntidad
        WHERE ds.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
          AND ds.idEntidad = @idEntidad
          AND ISNULL(ds.activo,1) = 1;

        IF ISNULL(@folioAgenda,0) <= 0
            RAISERROR('No existe el detalle de servicio indicado.',16,1);

        IF @fechaHoraAnteriorInicio IS NULL OR @fechaHoraAnteriorFin IS NULL
            RAISERROR('El detalle de servicio no tiene horario programado válido.',16,1);

        IF ISNULL(@claveDetalle,'') IN ('CANCELADO','CONCLUIDO','EN_PROCESO')
            RAISERROR('No se puede reprogramar un servicio cancelado, concluido o en proceso.',16,1);

        /* =========================================================
           2) LEER AGENDA BASE CON BLOQUEO
           ========================================================= */
        SELECT
            @idSucursal = a.idSucursal,
            @claveAgenda = ea.clave
        FROM dbo.proc_agenda a WITH (UPDLOCK, HOLDLOCK)
        INNER JOIN dbo.cat_estatusAgenda ea
            ON ea.id = a.idEstatusAgenda
           AND ea.idEntidad = a.idEntidad
        WHERE a.folioAgenda = @folioAgenda
          AND a.idEntidad = @idEntidad
          AND ISNULL(a.activo,1) = 1;

        IF ISNULL(@idSucursal,0) <= 0
            RAISERROR('La agenda no tiene una sucursal válida.',16,1);

        IF ISNULL(@claveAgenda,'') IN ('CANCELADA','CONCLUIDA')
            RAISERROR('No se puede reprogramar un servicio de una agenda cancelada o concluida.',16,1);

        /* =========================================================
           3) VALIDACIONES DE FECHA/HORA
           ========================================================= */
        IF @fechaHoraNuevaFin <= @fechaHoraNuevaInicio
            RAISERROR('La nueva hora fin debe ser mayor a la hora inicio.',16,1);

        IF CONVERT(date,@fechaHoraNuevaInicio) <> CONVERT(date,@fechaHoraNuevaFin)
            RAISERROR('La reprogramación del servicio debe quedar dentro del mismo día.',16,1);

        IF @fechaHoraNuevaInicio < dbo.fn_GetDateMX()
            RAISERROR('No se puede reprogramar el servicio a una fecha/hora pasada.',16,1);

        SET @duracionOriginalMin = DATEDIFF(MINUTE, @fechaHoraAnteriorInicio, @fechaHoraAnteriorFin);
        SET @duracionNuevaMin = DATEDIFF(MINUTE, @fechaHoraNuevaInicio, @fechaHoraNuevaFin);

     IF @duracionOriginalMin <> @duracionNuevaMin
            RAISERROR('La reprogramación debe conservar la duración original del servicio.',16,1);

        IF OBJECT_ID('dbo.proc_agendaDetalleServicioReprogramacion','U') IS NULL
            RAISERROR('No existe la tabla proc_agendaDetalleServicioReprogramacion.',16,1);

        /* =========================================================
           4) OBTENER EMPLEADO ACTUAL
           ========================================================= */
        SELECT
            @empleadosActivos = COUNT(1),
            @folioEmpleadoAnterior = MAX(dse.folioEmpleado)
        FROM dbo.proc_agendaDetalleServicioEmpleado dse WITH (UPDLOCK, HOLDLOCK)
        WHERE dse.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
          AND dse.idEntidad = @idEntidad
          AND ISNULL(dse.activo,1) = 1;

        IF ISNULL(@empleadosActivos,0) = 0
            RAISERROR('El detalle de servicio no tiene empleado activo asignado.',16,1);

        IF ISNULL(@empleadosActivos,0) > 1
            RAISERROR('El detalle de servicio tiene más de un empleado activo asignado. Reprogramación individual no permitida.',16,1);

        SET @folioEmpleadoFinal = ISNULL(NULLIF(@folioEmpleadoNuevo,0), @folioEmpleadoAnterior);

        IF ISNULL(@folioEmpleadoFinal,0) <= 0
            RAISERROR('El empleado final no es válido.',16,1);

        /* =========================================================
           5) VALIDAR EMPLEADO EN SUCURSAL, SI EXISTE TABLA RELACIÓN
           ========================================================= */
        IF OBJECT_ID('dbo.proc_empleadoSucursal','U') IS NOT NULL
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM dbo.proc_empleadoSucursal es
                WHERE es.folioEmpleado = @folioEmpleadoFinal
                  AND es.idSucursal = @idSucursal
                  AND es.idEntidad = @idEntidad
                  AND ISNULL(es.activo,1) = 1
            )
            BEGIN
                RAISERROR('El empleado seleccionado no está asignado a la sucursal de la agenda.',16,1);
            END
        END

        /* =========================================================
           6) OBTENER TIPO DE MOVIMIENTO
           ========================================================= */
        SELECT @idTipoMovimientoAgenda = ctm.id
        FROM dbo.cat_tipoMovimientoAgenda ctm
        WHERE ctm.idEntidad = @idEntidad
          AND ctm.clave = 'EDICION'
          AND ISNULL(ctm.activo,1) = 1;

        IF ISNULL(@idTipoMovimientoAgenda,0) <= 0
            RAISERROR('No existe el tipo de movimiento EDICION.',16,1);

        /* =========================================================
           7) VALIDAR HORARIO LABORAL DEL EMPLEADO
           Lunes = 1
           ========================================================= */
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.proc_empleadoHorario eh
            WHERE eh.folioEmpleado = @folioEmpleadoFinal
              AND eh.idEntidad = @idEntidad
              AND eh.idSucursal = @idSucursal
              AND eh.diaSemana = ((DATEDIFF(DAY, '19000101', CAST(@fechaHoraNuevaInicio AS date)) % 7) + 1)
              AND ISNULL(eh.activo,1) = 1
              AND CAST(@fechaHoraNuevaInicio AS time) >= CAST(eh.horaEntrada AS time)
              AND CAST(@fechaHoraNuevaFin AS time) <= CAST(eh.horaSalida AS time)
        )
        BEGIN
            RAISERROR('La nueva fecha/hora queda fuera del horario laboral del empleado.',16,1);
        END

        /* =========================================================
           8) VALIDAR BLOQUEOS DEL EMPLEADO
           ========================================================= */
        IF EXISTS
        (
            SELECT 1
            FROM dbo.proc_empleadoBloqueoHorario ebh
            WHERE ebh.folioEmpleado = @folioEmpleadoFinal
              AND ebh.idEntidad = @idEntidad
              AND ebh.idSucursal = @idSucursal
              AND ISNULL(ebh.activo,1) = 1
              AND CONVERT(date, ebh.fecha) = CONVERT(date, @fechaHoraNuevaInicio)
              AND @fechaHoraNuevaInicio < ebh.horaFin
              AND @fechaHoraNuevaFin > ebh.horaInicio
        )
        BEGIN
            RAISERROR('La nueva fecha/hora genera conflicto con un bloqueo del empleado.',16,1);
        END

        /* =========================================================
           9) VALIDAR EMPALMES CONTRA OTROS SERVICIOS/AGENDAS
           IMPORTANTE:
           - Excluye solo el mismo detalle.
           - Sí valida contra otros servicios de la misma agenda.
           - No filtra por sucursal: el empleado no puede tener dos citas al mismo tiempo.
           ========================================================= */
        IF EXISTS
        (
            SELECT 1
            FROM dbo.proc_agendaDetalleServicioEmpleado dse
            INNER JOIN dbo.proc_agendaDetalleServicio ds
                ON ds.folioAgendaDetalleServicio = dse.folioAgendaDetalleServicio
               AND ds.idEntidad = dse.idEntidad
            INNER JOIN dbo.proc_agenda a
                ON a.folioAgenda = ds.folioAgenda
               AND a.idEntidad = ds.idEntidad
            INNER JOIN dbo.cat_estatusAgenda ea
                ON ea.id = a.idEstatusAgenda
               AND ea.idEntidad = a.idEntidad
            LEFT JOIN dbo.cat_estatusAgendaDetalleServicio eds
                ON eds.id = ds.idEstatusAgendaDetalleServicio
               AND eds.idEntidad = ds.idEntidad
            WHERE dse.folioEmpleado = @folioEmpleadoFinal
              AND dse.idEntidad = @idEntidad
              AND ISNULL(dse.activo,1) = 1
              AND ISNULL(ds.activo,1) = 1
              AND ISNULL(ds.cancelado,0) = 0
              AND ISNULL(a.activo,1) = 1
              AND ds.folioAgendaDetalleServicio <> @folioAgendaDetalleServicio
              AND ea.clave NOT IN ('CANCELADA','CONCLUIDA')
              AND ISNULL(eds.clave,'') NOT IN ('CANCELADO','CONCLUIDO')
              AND @fechaHoraNuevaInicio < ISNULL(ds.horaFinProgramada, a.horaFinProgramada)
              AND @fechaHoraNuevaFin > ISNULL(ds.horaInicioProgramada, a.horaInicioProgramada)
        )
        BEGIN
            RAISERROR('La nueva fecha/hora genera empalme con otro servicio o agenda del empleado.',16,1);
        END

        /* =========================================================
           10) INSERT HISTORIAL DE REPROGRAMACIÓN DEL DETALLE
           ========================================================= */
        INSERT INTO dbo.proc_agendaDetalleServicioReprogramacion
        (
            folioAgenda,
            folioAgendaDetalleServicio,
            fechaHoraAnteriorInicio,
            fechaHoraAnteriorFin,
            fechaHoraNuevaInicio,
            fechaHoraNuevaFin,
            folioEmpleadoAnterior,
            folioEmpleadoNuevo,
            motivo,
            comentarios,
            activo,
            idEntidad,
            fechaModificacion,
            idUsuarioModifica,
            fechaAlta,
            idUsuarioAlta
        )
        VALUES
        (
            @folioAgenda,
            @folioAgendaDetalleServicio,
            @fechaHoraAnteriorInicio,
            @fechaHoraAnteriorFin,
            @fechaHoraNuevaInicio,
            @fechaHoraNuevaFin,
            @folioEmpleadoAnterior,
            @folioEmpleadoFinal,
            @motivo,
            @comentarios,
            1,
            @idEntidad,
            NULL,
            NULL,
            dbo.fn_GetDateMX(),
            @idUsuarioAlta
        );

        SET @folioAgendaDetalleServicioReprogramacion = SCOPE_IDENTITY();

        /* =========================================================
           11) UPDATE DETALLE SERVICIO
    ========================================================= */
        UPDATE dbo.proc_agendaDetalleServicio
           SET horaInicioProgramada = @fechaHoraNuevaInicio,
               horaFinProgramada = @fechaHoraNuevaFin,
               fechaModificacion = dbo.fn_GetDateMX(),
               idUsuarioModifica = @idUsuarioAlta
         WHERE folioAgendaDetalleServicio = @folioAgendaDetalleServicio
           AND folioAgenda = @folioAgenda
           AND idEntidad = @idEntidad
           AND ISNULL(activo,1) = 1
           AND ISNULL(cancelado,0) = 0;

        /* =========================================================
           12) UPDATE EMPLEADO SI CAMBIÓ
           ========================================================= */
        IF @folioEmpleadoFinal <> @folioEmpleadoAnterior
        BEGIN
            UPDATE dbo.proc_agendaDetalleServicioEmpleado
               SET folioEmpleado = @folioEmpleadoFinal,
                   fechaModificacion = dbo.fn_GetDateMX(),
                   idUsuarioModifica = @idUsuarioAlta
             WHERE folioAgendaDetalleServicio = @folioAgendaDetalleServicio
               AND idEntidad = @idEntidad
               AND ISNULL(activo,1) = 1;
        END

        /* =========================================================
           13) RECALCULAR HORARIO GLOBAL DE LA AGENDA
           ========================================================= */
        SELECT
            @horaInicioGlobal = MIN(ds.horaInicioProgramada),
            @horaFinGlobal = MAX(ds.horaFinProgramada)
        FROM dbo.proc_agendaDetalleServicio ds
        WHERE ds.folioAgenda = @folioAgenda
          AND ds.idEntidad = @idEntidad
          AND ISNULL(ds.activo,1) = 1
          AND ISNULL(ds.cancelado,0) = 0;

        IF @horaInicioGlobal IS NULL OR @horaFinGlobal IS NULL
            RAISERROR('No existen servicios activos para recalcular el horario global de la agenda.',16,1);

        UPDATE dbo.proc_agenda
           SET fechaCita = CONVERT(date, @horaInicioGlobal),
               horaInicioProgramada = @horaInicioGlobal,
               horaFinProgramada = @horaFinGlobal,
               fechaModificacion = dbo.fn_GetDateMX(),
               idUsuarioModifica = @idUsuarioAlta
         WHERE folioAgenda = @folioAgenda
           AND idEntidad = @idEntidad
           AND ISNULL(activo,1) = 1;

        /* =========================================================
           14) BITÁCORA
           ========================================================= */
        INSERT INTO dbo.proc_agendaBitacora
        (
            folioAgenda,
            folioAgendaDetalleServicio,
            idTipoMovimientoAgenda,
            idEstatusAnterior,
            idEstatusNuevo,
            descripcionMovimiento,
            datosAntes,
            datosDespues,
            fechaMovimiento,
            comentarios,
            activo,
            idEntidad,
            fechaModificacion,
            idUsuarioModifica,
            fechaAlta,
            idUsuarioAlta
        )
        VALUES
        (
            @folioAgenda,
            @folioAgendaDetalleServicio,
            @idTipoMovimientoAgenda,
            NULL,
            NULL,
            'Reprogramación de servicio de agenda',
            CONCAT
            (
                'Empleado=', @folioEmpleadoAnterior,
                '; Inicio=', CONVERT(varchar(19), @fechaHoraAnteriorInicio, 120),
                '; Fin=', CONVERT(varchar(19), @fechaHoraAnteriorFin, 120)
            ),
            CONCAT
            (
                'Empleado=', @folioEmpleadoFinal,
                '; Inicio=', CONVERT(varchar(19), @fechaHoraNuevaInicio, 120),
                '; Fin=', CONVERT(varchar(19), @fechaHoraNuevaFin, 120)
            ),
            dbo.fn_GetDateMX(),
            @comentarios,
            1,
            @idEntidad,
            NULL,
            NULL,
            dbo.fn_GetDateMX(),
            @idUsuarioAlta
        );

        COMMIT TRAN;

        SELECT
            @folioAgenda AS folioAgenda,
            @folioAgendaDetalleServicio AS folioAgendaDetalleServicio,
            @folioAgendaDetalleServicioReprogramacion AS folioAgendaDetalleServicioReprogramacion,
            @folioEmpleadoAnterior AS folioEmpleadoAnterior,
            @folioEmpleadoFinal AS folioEmpleadoNuevo,
            @fechaHoraAnteriorInicio AS fechaHoraAnteriorInicio,
            @fechaHoraAnteriorFin AS fechaHoraAnteriorFin,
            @fechaHoraNuevaInicio AS fechaHoraNuevaInicio,
            @fechaHoraNuevaFin AS fechaHoraNuevaFin,
            @horaInicioGlobal AS horaInicioAgenda,
            @horaFinGlobal AS horaFinAgenda;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        DECLARE @ErrorMessage varchar(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine int = ERROR_LINE();

        RAISERROR('Error en reprogramación de servicio. Línea: %d. Mensaje: %s',16,1,@ErrorLine,@ErrorMessage);
    END CATCH
END

