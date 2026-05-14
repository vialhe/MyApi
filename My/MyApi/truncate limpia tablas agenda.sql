sp_ui_cancelarAgenda
Select * From cat_estatusAgendaDetalleServicio
Select * From cat_personas where id = 1132 and idEntidad = 10007
Select * From cat_tiposPersonas WHERE idEntidad = 10007 and id = 30
Select * From cat_tipoBloqueoHorario
Select * From proc_empleadoHorario
Select * From proc_empleadoBloqueoHorario
Select * From cat_productosServicios where id = 2650 
Select * From proc_agenda
Select * From proc_agendaDetalleServicio
Select * From proc_agendaBitacora
Select * From cat_origenAgenda 

exec sp_ui_agenda
--Update cat_productosServicios set duracionBaseMin = 90,mostrarEnAgenda = 1, esServicio = 1 where id = 2650 
--Select * From sys_entidades

--exec sp_ui_empleado
--	@id = 0
--	,@nombre	 = 'Julion'
--	,@apellidoP = 'AlvareZ'
--	,@apellidoM = ''
--	,@numeroTelefono = '5556967640'
--	,@correo = 'julion@gmail.com'
--	,@comentarios = ''
--	,@activo = 1
--	,@idEntidad = 10007
--	,@idUsuarioModifica = 1
--	,@fechaNacimiento = '20011010'


--Update cat_origenAgenda						set idEntidad = 10007
--Update cat_rolParticipacionServicio			set idEntidad = 10007
--Update cat_tipoMovimientoPagoAgenda			set idEntidad = 10007
--Update cat_estatusAgendaDetalleServicio		set idEntidad = 10007
--Update cat_estatusAgendaDetalleServicio		set idEntidad = 10007
--Update cat_estatusAgenda					set idEntidad = 10007
----Update cat_tipoMovimientoAgenda				set idEntidad = 10007
--Update cat_tipoBloqueoHorario				set idEntidad = 10007
--Update cat_estatusPagoAgenda				set idEntidad = 10007

--Delete From proc_agendaDetalleServicio
--Delete From proc_agenda
--Truncate table proc_agendaDetalleServicio
--Truncate table proc_agenda
--truncate table proc_agendaDetalleServicioEmpleado
--truncate table proc_agendaBitacora
--Truncate table  cat_estatusAgendaDetalleServicio
--truncate table proc_agendaDetalleServicioEmpleado
--truncate table proc_agendaReprogramacion

sp_se_catalogos
cat_origenAgenda

EXEC dbo.sp_se_horariosDisponiblesServicio
    @idProductoServicio = 2650,
    @fecha = '2026-04-25',
    @idEntidad = 10007,
    @folioEmpleado = 0,
    @intervaloMin = 30,
	@idSucursal = 1
	sp_se_horariosDisponiblesServicio
--update proc_empleadoHorario set diaSemana = 6 ,comentarios = ''
--Select  DATEPART(WEEKDAY, '20260419');  
Select top 1 * From proc_empleadoHorario
Select top 1 * From proc_empleadoBloqueoHorario
Select top 1 * From proc_agenda
Select top 1 * From proc_agendaDetalleServicio
Select top 1 * From proc_agendaDetalleServicioEmpleado
Select top 1 * From proc_agendaPago
Select top 1 * From proc_agendaPagoDetalle
Select top 1 * From proc_agendaBitacora
Select top 1 * From proc_agendaReprogramacion
EXEC dbo.sp_se_agendaDetalleCompleto    @folioAgenda = 11,    @idEntidad = 10007
--sp_ui_cancelarAgenda
Delete proc_empleadoHorario
Delete proc_empleadoBloqueoHorario

Delete proc_agendaDetalleServicioEmpleado
Delete proc_agendaDetalleServicio
Delete proc_agendaPago
Delete proc_agendaPagoDetalle
Delete proc_agenda
Delete proc_agendaBitacora
Delete proc_agendaReprogramacion
Delete proc_agendaDetalleServicioReprogramacion

Delete proc_empleadoSucursal

--Truncate table proc_empleadoHorario
--Truncate table proc_empleadoBloqueoHorario
--Truncate table proc_agendaDetalleServicioEmpleado
--Truncate table proc_agendaPagoDetalle
--Truncate table proc_agendaBitacora
--Truncate table proc_agendaReprogramacion
--Truncate table proc_agendaPago
--Truncate table proc_agendaDetalleServicio
--Truncate table proc_agenda

DBCC CHECKIDENT ('proc_empleadoHorario', RESEED, 0);
DBCC CHECKIDENT ('proc_empleadoBloqueoHorario', RESEED, 0);

DBCC CHECKIDENT ('proc_agendaDetalleServicioEmpleado', RESEED, 0);
DBCC CHECKIDENT ('proc_agendaPagoDetalle', RESEED, 0);
DBCC CHECKIDENT ('proc_agendaBitacora', RESEED, 0);
DBCC CHECKIDENT ('proc_agendaReprogramacion', RESEED, 0);
DBCC CHECKIDENT ('proc_agendaDetalleServicioReprogramacion', RESEED, 0);
DBCC CHECKIDENT ('proc_agendaPago', RESEED, 0);
DBCC CHECKIDENT ('proc_agendaDetalleServicio', RESEED, 0);
DBCC CHECKIDENT ('proc_agenda', RESEED, 0);

DBCC CHECKIDENT ('proc_empleadoSucursal', RESEED, 0);


--Insert sys_folios (descripcion,comentarios,activo,idEntidad,fechaAlta,idUsuarioAlta)
--Select 'Folio Agenda', '',1,1,GETDATE(),1


DECLARE @idEntidad int = 10007;
DECLARE @folioEmpleado int = 1132;
DECLARE @fechaIni date = '2026-04-14';
DECLARE @fechaFin date = '2026-04-30';

SELECT
    a.folioAgenda,
    ds.folioAgendaDetalleServicio,
    dse.folioAgendaDetalleServicioEmpleado,
    dse.folioEmpleado,
    a.fechaCita,
    a.horaInicioProgramada AS horaInicioAgenda,
    a.horaFinProgramada AS horaFinAgenda,
    ds.horaInicioProgramada AS horaInicioDetalle,
    ds.horaFinProgramada AS horaFinDetalle,
    ds.cancelado,
    a.activo AS agendaActiva,
    ds.activo AS detalleActivo,
    dse.activo AS detalleEmpleadoActivo
FROM dbo.proc_agendaDetalleServicioEmpleado dse
INNER JOIN dbo.proc_agendaDetalleServicio ds
    ON ds.folioAgendaDetalleServicio = dse.folioAgendaDetalleServicio
   AND ds.idEntidad = dse.idEntidad
INNER JOIN dbo.proc_agenda a
    ON a.folioAgenda = ds.folioAgenda
   AND a.idEntidad = ds.idEntidad
WHERE dse.folioEmpleado = @folioEmpleado
  AND dse.idEntidad = @idEntidad
  AND CONVERT(date, a.fechaCita) between @fechaIni and @fechaFin
ORDER BY ISNULL(ds.horaInicioProgramada, a.horaInicioProgramada);



--Select * From proc_empleadoHorario
--Select * From proc_empleadoBloqueoHorario
Select * From sys_folios
Select * From sys_foliosContador where idFolio = 8
sp_ui_agendaReprogramacion

go
DECLARE @folioAgenda int = 10;
DECLARE @idEntidad int = 10007;
DECLARE @fechaHoraNuevaInicio datetime = '2026-04-26 12:00:00';

DECLARE @fechaHoraAnteriorInicio datetime;
DECLARE @idSucursal int;

SELECT
    @fechaHoraAnteriorInicio = a.horaInicioProgramada,
    @idSucursal = a.idSucursal
FROM proc_agenda a
WHERE a.folioAgenda = @folioAgenda
  AND a.idEntidad = @idEntidad;

;WITH Detalles AS
(
    SELECT
        ds.folioAgendaDetalleServicio,
        ds.horaInicioProgramada AS horaInicioAnterior,
        ds.horaFinProgramada AS horaFinAnterior,
        DATEADD(MINUTE, DATEDIFF(MINUTE, @fechaHoraAnteriorInicio, ds.horaInicioProgramada), @fechaHoraNuevaInicio) AS horaInicioNueva,
        DATEADD(MINUTE, DATEDIFF(MINUTE, @fechaHoraAnteriorInicio, ds.horaFinProgramada), @fechaHoraNuevaInicio) AS horaFinNueva
    FROM proc_agendaDetalleServicio ds
    WHERE ds.folioAgenda = @folioAgenda
      AND ds.idEntidad = @idEntidad
      AND ISNULL(ds.activo,1) = 1
      AND ISNULL(ds.cancelado,0) = 0
)
SELECT
    d.folioAgendaDetalleServicio,
    dse.folioEmpleado,
    d.horaInicioNueva,
    d.horaFinNueva,
    ((DATEDIFF(DAY, '19000101', CAST(d.horaInicioNueva AS date)) % 7) + 1) AS diaSemanaCalculado
FROM Detalles d
INNER JOIN proc_agendaDetalleServicioEmpleado dse
    ON dse.folioAgendaDetalleServicio = d.folioAgendaDetalleServicio
   AND dse.idEntidad = @idEntidad
   AND ISNULL(dse.activo,1) = 1;

   Go
   Select * From proc_empleadoSucursal
   Select * From proc_empleadoHorario order by folioEmpleado, horaEntrada, diaSemana
   Select * From proc_empleadoBloqueoHorario order by folioEmpleado

   

Select * From proc_agenda
Select * From proc_agendaDetalleServicio
Select * From proc_agendaBitacora
Select * From proc_agendaReprogramacion


CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaDetalleServicioReprogramacion
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

        IF @fechaHoraNuevaInicio < GETDATE()
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
            GETDATE(),
            @idUsuarioAlta
        );

        SET @folioAgendaDetalleServicioReprogramacion = SCOPE_IDENTITY();

        /* =========================================================
           11) UPDATE DETALLE SERVICIO
           ========================================================= */
        UPDATE dbo.proc_agendaDetalleServicio
           SET horaInicioProgramada = @fechaHoraNuevaInicio,
               horaFinProgramada = @fechaHoraNuevaFin,
               fechaModificacion = GETDATE(),
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
                   fechaModificacion = GETDATE(),
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
               fechaModificacion = GETDATE(),
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
            GETDATE(),
            @comentarios,
            1,
            @idEntidad,
            NULL,
            NULL,
            GETDATE(),
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

Select * From proc_agenda
Select * From proc_agendaDetalleServicio
Select * From proc_agendaBitacora	
Select * From proc_agendaReprogramacion
Select * From proc_agendaDetalleServicioReprogramacion