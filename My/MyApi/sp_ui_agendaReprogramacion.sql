/* =========================================================    
   9) REPROGRAMACION DE AGENDA    
   ========================================================= */    
CREATE    PROCEDURE dbo.sp_ui_agendaReprogramacion    
(    
    @folioAgenda int,    
    @fechaHoraNuevaInicio datetime,    
    @fechaHoraNuevaFin datetime,    
    @motivo varchar(450) = NULL,    
    @comentarios varchar(450) = NULL,    
    @idEntidad int,    
    @idUsuarioAlta int    
)    
AS    sp_ui_agendaReprogramacion    
BEGIN    
    SET NOCOUNT ON;    
    
    DECLARE @fechaHoraAnteriorInicio datetime,    
            @fechaHoraAnteriorFin datetime,    
            @idTipoMovimientoAgenda int,    
            @claveAgenda varchar(50);    
    
    SELECT    
        @fechaHoraAnteriorInicio = a.horaInicioProgramada,    
        @fechaHoraAnteriorFin = a.horaFinProgramada,    
        @claveAgenda = ea.clave    
    FROM dbo.proc_agenda a    
    INNER JOIN dbo.cat_estatusAgenda ea    
        ON ea.id = a.idEstatusAgenda    
       AND ea.idEntidad = a.idEntidad    
    WHERE a.folioAgenda = @folioAgenda    
      AND a.idEntidad = @idEntidad    
      AND ISNULL(a.activo,1) = 1;    
    
    IF @fechaHoraAnteriorInicio IS NULL    
    BEGIN    
        RAISERROR('No existe la agenda indicada.',16,1);    
        RETURN;    
    END    
    
    IF @claveAgenda IN ('CANCELADA','CONCLUIDA')    
    BEGIN    
        RAISERROR('No se puede reprogramar una agenda cancelada o concluida.',16,1);    
        RETURN;    
    END    
    
    IF @fechaHoraNuevaFin <= @fechaHoraNuevaInicio    
    BEGIN    
        RAISERROR('La nueva hora fin debe ser mayor a la hora inicio.',16,1);    
        RETURN;    
    END    
    
    IF CONVERT(date,@fechaHoraNuevaInicio) <> CONVERT(date,@fechaHoraNuevaFin)    
    BEGIN    
        RAISERROR('La reprogramación debe quedar dentro del mismo día.',16,1);    
        RETURN;    
    END    
    
    IF OBJECT_ID('dbo.proc_agendaReprogramacion','U') IS NULL    
    BEGIN    
        CREATE TABLE dbo.proc_agendaReprogramacion    
        (    
            folioAgendaReprogramacion int IDENTITY(1,1) NOT NULL PRIMARY KEY,    
            folioAgenda int NOT NULL,    
            fechaHoraAnteriorInicio datetime NOT NULL,    
            fechaHoraAnteriorFin datetime NOT NULL,    
            fechaHoraNuevaInicio datetime NOT NULL,    
            fechaHoraNuevaFin datetime NOT NULL,    
            motivo varchar(450) NULL,    
            comentarios varchar(450) NULL,    
            activo bit NULL,    
            idEntidad int NOT NULL,    
            fechaModificacion datetime NULL,    
            idUsuarioModifica int NULL,    
            fechaAlta datetime NOT NULL,    
            idUsuarioAlta int NOT NULL,    
            CONSTRAINT FK_proc_agendaReprogramacion_proc_agenda    
                FOREIGN KEY (folioAgenda) REFERENCES dbo.proc_agenda(folioAgenda)    
        );    
    END    
    
    IF EXISTS    
    (    
        SELECT 1    
        FROM dbo.proc_agendaDetalleServicio dsActual    
        INNER JOIN dbo.proc_agendaDetalleServicioEmpleado dseActual    
            ON dseActual.folioAgendaDetalleServicio = dsActual.folioAgendaDetalleServicio    
           AND dseActual.idEntidad = dsActual.idEntidad    
        WHERE dsActual.folioAgenda = @folioAgenda    
          AND dsActual.idEntidad = @idEntidad    
          AND ISNULL(dsActual.activo,1) = 1    
          AND ISNULL(dsActual.cancelado,0) = 0    
          AND ISNULL(dseActual.activo,1) = 1    
          AND    
          (    
              NOT EXISTS    
              (    
                  SELECT 1    
                  FROM dbo.proc_empleadoHorario eh    
                  WHERE eh.folioEmpleado = dseActual.folioEmpleado    
                    AND eh.idEntidad = @idEntidad    
                    AND eh.diaSemana = DATEPART(WEEKDAY,@fechaHoraNuevaInicio)    
                    AND ISNULL(eh.activo,1) = 1    
                    AND CAST(@fechaHoraNuevaInicio AS time) >= CAST(eh.horaEntrada AS time)    
                    AND CAST(@fechaHoraNuevaFin AS time) <= CAST(eh.horaSalida AS time)    
              )    
              OR EXISTS    
              (    
                  SELECT 1    
                  FROM dbo.proc_empleadoBloqueoHorario ebh    
     WHERE ebh.folioEmpleado = dseActual.folioEmpleado    
                    AND ebh.idEntidad = @idEntidad    
                    AND ISNULL(ebh.activo,1) = 1    
                    AND CONVERT(date, ebh.fecha) = CONVERT(date,@fechaHoraNuevaInicio)    
                    AND @fechaHoraNuevaInicio < ebh.horaFin    
                    AND @fechaHoraNuevaFin > ebh.horaInicio    
              )    
              OR EXISTS    
              (    
                  SELECT 1    
                  FROM dbo.proc_agendaDetalleServicioEmpleado dse    
                  INNER JOIN dbo.proc_agendaDetalleServicio ds    
                      ON ds.folioAgendaDetalleServicio = dse.folioAgendaDetalleServicio    
                     AND ds.idEntidad = dse.idEntidad    
                  INNER JOIN dbo.proc_agenda a    
                      ON a.folioAgenda = ds.folioAgenda    
                     AND a.idEntidad = ds.idEntidad    
                  WHERE dse.folioEmpleado = dseActual.folioEmpleado    
                    AND dse.idEntidad = @idEntidad    
                    AND ISNULL(dse.activo,1) = 1    
                    AND ISNULL(ds.activo,1) = 1    
                    AND ISNULL(a.activo,1) = 1    
                    AND ISNULL(ds.cancelado,0) = 0    
                    AND ds.folioAgenda <> @folioAgenda    
                    AND @fechaHoraNuevaInicio < ISNULL(ds.horaFinProgramada, a.horaFinProgramada)    
                    AND @fechaHoraNuevaFin > ISNULL(ds.horaInicioProgramada, a.horaInicioProgramada)    
              )    
          )    
    )    
    BEGIN    
        RAISERROR('La nueva fecha/hora genera conflicto de horario, bloqueo o empalme para uno o más empleados asignados.',16,1);    
        RETURN;    
    END    
    
    SELECT @idTipoMovimientoAgenda = ctm.id    
    FROM dbo.cat_tipoMovimientoAgenda ctm    
    WHERE ctm.idEntidad = @idEntidad    
      AND ctm.clave = 'EDICION'    
      AND ISNULL(ctm.activo,1) = 1;    
    
    IF ISNULL(@idTipoMovimientoAgenda,0) = 0    
    BEGIN    
        RAISERROR('No existe el tipo de movimiento EDICION.',16,1);    
        RETURN;    
    END    
    
    INSERT INTO dbo.proc_agendaReprogramacion    
    (    
        folioAgenda, fechaHoraAnteriorInicio, fechaHoraAnteriorFin,    
        fechaHoraNuevaInicio, fechaHoraNuevaFin, motivo,    
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta    
    )    
    VALUES    
    (    
        @folioAgenda, @fechaHoraAnteriorInicio, @fechaHoraAnteriorFin,    
        @fechaHoraNuevaInicio, @fechaHoraNuevaFin, @motivo,    
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta    
    );    
    
    UPDATE dbo.proc_agenda    
       SET fechaCita = @fechaHoraNuevaInicio,    
           horaInicioProgramada = @fechaHoraNuevaInicio,    
           horaFinProgramada = @fechaHoraNuevaFin,    
           fechaModificacion = GETDATE(),    
           idUsuarioModifica = @idUsuarioAlta    
     WHERE folioAgenda = @folioAgenda    
       AND idEntidad = @idEntidad;    
    
    UPDATE dbo.proc_agendaDetalleServicio    
       SET horaInicioProgramada = CASE WHEN horaInicioProgramada IS NOT NULL THEN @fechaHoraNuevaInicio ELSE horaInicioProgramada END,    
           horaFinProgramada = CASE WHEN horaFinProgramada IS NOT NULL THEN @fechaHoraNuevaFin ELSE horaFinProgramada END,    
           fechaModificacion = GETDATE(),    
           idUsuarioModifica = @idUsuarioAlta    
     WHERE folioAgenda = @folioAgenda    
       AND idEntidad = @idEntidad    
       AND ISNULL(activo,1) = 1    
       AND ISNULL(cancelado,0) = 0;    
    
    INSERT INTO dbo.proc_agendaBitacora    
    (    
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda,    
        idEstatusAnterior, idEstatusNuevo, descripcionMovimiento,    
        datosAntes, datosDespues, fechaMovimiento,    
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta    
    )    
    VALUES    
    (    
        @folioAgenda, NULL, @idTipoMovimientoAgenda,    
        NULL, NULL, 'Reprogramación de agenda',    
        CONCAT('Inicio=',CONVERT(varchar(19),@fechaHoraAnteriorInicio,120),'; Fin=',CONVERT(varchar(19),@fechaHoraAnteriorFin,120)),    
        CONCAT('Inicio=',CONVERT(varchar(19),@fechaHoraNuevaInicio,120),'; Fin=',CONVERT(varchar(19),@fechaHoraNuevaFin,120)),    
        GETDATE(),    
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta    
    );    
    
    SELECT @folioAgenda AS folioAgenda;    
END 