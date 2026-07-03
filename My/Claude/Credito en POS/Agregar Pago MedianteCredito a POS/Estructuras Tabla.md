-- ------------------------------------------------------------------------------------------
-- ESTRUCTURA BASE PARA TABLAS DE REGISTRSO DE CATALOGOS
-- ------------------------------------------------------------------------------------------
CREATE TABLE [dbo].[cat_tiposPago](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[descripcion] [varchar](450) NOT NULL,
	[comentarios] [varchar](450) NULL,
	[activo] [bit] NULL,
	[idEntidad] [int] NOT NULL,
	[fechaModificacion] [datetime] NULL,
	[idUsuarioModifica] [int] NULL,
	[fechaAlta] [datetime] NOT NULL,
	[idUsuarioAlta] [int] NOT NULL
) ON [PRIMARY]
GO

-- ------------------------------------------------------------------------------------------
-- ESTRUCTURA BASE PARA TABLAS DE PROCESO
-- ------------------------------------------------------------------------------------------
CREATE TABLE [dbo].[proc_movimientosInventarios](
	[folioMovimientoInventario] [int] NOT NULL,
	[idSucursal] [int] NOT NULL,
	[idTipoMovimientoInventario] [int] NOT NULL,
	[idDocumentoReferencia] [int] NULL,
	[idAlmacen] [int] NULL,
	[idMotivoMovimiento] [int] NULL,
	[idEstadoMovimiento] [int] NULL,
	[idPersona] [int] NULL,
	[stockAntesMovimiento] [decimal](18, 6) NULL,
	[comentarios] [varchar](450) NULL,
	[activo] [bit] NULL,
	[idEntidad] [int] NOT NULL,
	[fechaModificacion] [datetime] NULL,
	[idUsuarioModifica] [int] NULL,
	[fechaAlta] [datetime] NOT NULL,
	[idUsuarioAlta] [int] NOT NULL,
 CONSTRAINT [PK_proc_movimientosInventarios] PRIMARY KEY CLUSTERED 
(
	[folioMovimientoInventario] ASC,
	[idEntidad] ASC,
	[idSucursal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- ------------------------------------------------------------------------------------------
-- COMENTARIOS: Estos campos van en todas las tablas como estandar en la base de datos
-- ------------------------------------------------------------------------------------------
	[id] [int] IDENTITY(1,1) NOT NULL, <-- Estas solo aplican en algunos escenarios segun sea el contexto
	[descripcion] [varchar](450) NOT NULL, <-- Estas solo aplican en algunos escenarios segun sea el contexto
	[comentarios] [varchar](450) NULL,
	[activo] [bit] NULL,
	[idEntidad] [int] NOT NULL,
	[fechaModificacion] [datetime] NULL,
	[idUsuarioModifica] [int] NULL,
	[fechaAlta] [datetime] NOT NULL,
	[idUsuarioAlta] [int] NOT NULL,


-- ------------------------------------------------------------------------------------------
-- ESTRUCTURA BASE PARA LOS SP, SI VEZ PRIMERO REALIZA VALIDACIONES PARA BLINDAR EL PROCESO, TRAE TRANSACCIONES CON SU ROLLBACK
-- ------------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[sp_ui_agendaReprogramacion]  
(  
    @folioAgenda int,  
    @fechaHoraNuevaInicio datetime,  
    @fechaHoraNuevaFin datetime,  
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
        @fechaHoraAnteriorInicio datetime,  
        @fechaHoraAnteriorFin datetime,  
        @idTipoMovimientoAgenda int,  
        @claveAgenda varchar(50),  
        @idSucursal int,  
        @duracionOriginalMin int,  
        @duracionNuevaMin int,  
        @folioAgendaReprogramacion int;  
  
    DECLARE @Detalles TABLE  
    (  
        folioAgendaDetalleServicio int PRIMARY KEY,  
        horaInicioAnterior datetime NOT NULL,  
        horaFinAnterior datetime NOT NULL,  
        horaInicioNueva datetime NOT NULL,  
        horaFinNueva datetime NOT NULL  
    );  
  
    DECLARE @DetalleEmpleado TABLE  
    (  
        folioAgendaDetalleServicio int NOT NULL,  
        folioEmpleado int NOT NULL,  
        horaInicioNueva datetime NOT NULL,  
        horaFinNueva datetime NOT NULL  
    );  
  
    BEGIN TRY  
        BEGIN TRAN;  
  
        /* =========================================================  
           1) LEER AGENDA BASE CON BLOQUEO  
           ========================================================= */  
        SELECT  
            @fechaHoraAnteriorInicio = a.horaInicioProgramada,  
            @fechaHoraAnteriorFin = a.horaFinProgramada,  
            @idSucursal = a.idSucursal,  
            @claveAgenda = ea.clave  
        FROM dbo.proc_agenda a WITH (UPDLOCK, HOLDLOCK)  
        INNER JOIN dbo.cat_estatusAgenda ea  
            ON ea.id = a.idEstatusAgenda  
           AND ea.idEntidad = a.idEntidad  
        WHERE a.folioAgenda = @folioAgenda  
          AND a.idEntidad = @idEntidad  
          AND ISNULL(a.activo,1) = 1;  
  
        IF @fechaHoraAnteriorInicio IS NULL  
            RAISERROR('No existe la agenda indicada.',16,1);  
  
        IF @claveAgenda IN ('CANCELADA','CONCLUIDA')  
            RAISERROR('No se puede reprogramar una agenda cancelada o concluida.',16,1);  
  
        IF ISNULL(@idSucursal,0) <= 0  
            RAISERROR('La agenda no tiene una sucursal válida.',16,1);  
  
        IF @fechaHoraNuevaFin <= @fechaHoraNuevaInicio  
            RAISERROR('La nueva hora fin debe ser mayor a la hora inicio.',16,1);  
  
        IF CONVERT(date,@fechaHoraNuevaInicio) <> CONVERT(date,@fechaHoraNuevaFin)  
            RAISERROR('La reprogramación debe quedar dentro del mismo día.',16,1);  
  
        IF OBJECT_ID('dbo.proc_agendaReprogramacion','U') IS NULL  
            RAISERROR('No existe la tabla proc_agendaReprogramacion. Crea la tabla antes de ejecutar este proceso.',16,1);  
  
        SET @duracionOriginalMin = DATEDIFF(MINUTE, @fechaHoraAnteriorInicio, @fechaHoraAnteriorFin);  
        SET @duracionNuevaMin = DATEDIFF(MINUTE, @fechaHoraNuevaInicio, @fechaHoraNuevaFin);  
  
        IF @duracionOriginalMin <> @duracionNuevaMin  
            RAISERROR('La reprogramación debe conservar la duración original de la agenda.',16,1);  
  
        /* =========================================================  
           2) OBTENER TIPO DE MOVIMIENTO  
           ========================================================= */  
        SELECT @idTipoMovimientoAgenda = ctm.id  
        FROM dbo.cat_tipoMovimientoAgenda ctm  
        WHERE ctm.idEntidad = @idEntidad  
          AND ctm.clave = 'EDICION'  
          AND ISNULL(ctm.activo,1) = 1;  
  
        IF ISNULL(@idTipoMovimientoAgenda,0) <= 0  
            RAISERROR('No existe el tipo de movimiento EDICION.',16,1);  
  
        /* =========================================================  
           3) CARGAR DETALLES ACTIVOS/CANCELADOS = 0  
        PRESERVANDO OFFSETS RESPECTO AL HEADER  
           ========================================================= */  
        INSERT INTO @Detalles  
        (  
            folioAgendaDetalleServicio,  
            horaInicioAnterior,  
            horaFinAnterior,  
            horaInicioNueva,  
            horaFinNueva  
        )  
        SELECT  
            ds.folioAgendaDetalleServicio,  
            ISNULL(ds.horaInicioProgramada, @fechaHoraAnteriorInicio) AS horaInicioAnterior,  
            ISNULL(ds.horaFinProgramada, @fechaHoraAnteriorFin) AS horaFinAnterior,  
            DATEADD  
            (  
                MINUTE,  
                DATEDIFF(MINUTE, @fechaHoraAnteriorInicio, ISNULL(ds.horaInicioProgramada, @fechaHoraAnteriorInicio)),  
                @fechaHoraNuevaInicio  
            ) AS horaInicioNueva,  
            DATEADD  
            (  
                MINUTE,  
                DATEDIFF(MINUTE, @fechaHoraAnteriorInicio, ISNULL(ds.horaFinProgramada, @fechaHoraAnteriorFin)),  
                @fechaHoraNuevaInicio  
            ) AS horaFinNueva  
        FROM dbo.proc_agendaDetalleServicio ds  
        WHERE ds.folioAgenda = @folioAgenda  
          AND ds.idEntidad = @idEntidad  
          AND ISNULL(ds.activo,1) = 1  
          AND ISNULL(ds.cancelado,0) = 0;  
  
        IF NOT EXISTS (SELECT 1 FROM @Detalles)  
            RAISERROR('La agenda no tiene detalles activos para reprogramar.',16,1);  
  
        /* =========================================================  
           4) VALIDAR QUE CADA DETALLE TENGA EMPLEADO ACTIVO  
           ========================================================= */  
        IF EXISTS  
        (  
            SELECT 1  
            FROM @Detalles d  
            WHERE NOT EXISTS  
            (  
                SELECT 1  
                FROM dbo.proc_agendaDetalleServicioEmpleado dse  
                WHERE dse.folioAgendaDetalleServicio = d.folioAgendaDetalleServicio  
                  AND dse.idEntidad = @idEntidad  
                  AND ISNULL(dse.activo,1) = 1  
            )  
        )  
        BEGIN  
            RAISERROR('Uno o más detalles activos no tienen empleados asignados.',16,1);  
        END  
  
        INSERT INTO @DetalleEmpleado  
        (  
            folioAgendaDetalleServicio,  
            folioEmpleado,  
            horaInicioNueva,  
            horaFinNueva  
        )  
        SELECT  
            d.folioAgendaDetalleServicio,  
            dse.folioEmpleado,  
            d.horaInicioNueva,  
            d.horaFinNueva  
        FROM @Detalles d  
        INNER JOIN dbo.proc_agendaDetalleServicioEmpleado dse  
            ON dse.folioAgendaDetalleServicio = d.folioAgendaDetalleServicio  
           AND dse.idEntidad = @idEntidad  
           AND ISNULL(dse.activo,1) = 1;  
  
        IF NOT EXISTS (SELECT 1 FROM @DetalleEmpleado)  
            RAISERROR('No existen empleados activos asignados para la reprogramación.',16,1);  
  
        /* =========================================================  
           5) VALIDAR HORARIO POR DETALLE/EMPLEADO/SUCURSAL  
           ========================================================= */  
        IF EXISTS  
        (  
            SELECT 1  
            FROM @DetalleEmpleado de  
            WHERE NOT EXISTS  
            (  
                SELECT 1  
                FROM dbo.proc_empleadoHorario eh  
                WHERE eh.folioEmpleado = de.folioEmpleado  
                  AND eh.idEntidad = @idEntidad  
                  AND eh.idSucursal = @idSucursal  
                  AND eh.diaSemana = ((DATEDIFF(DAY, '19000101', CAST(de.horaInicioNueva AS date)) % 7) + 1)
                  AND ISNULL(eh.activo,1) = 1  
                  AND CAST(de.horaInicioNueva AS time) >= CAST(eh.horaEntrada AS time)  
                  AND CAST(de.horaFinNueva AS time) <= CAST(eh.horaSalida AS time)  
            )  
)  
   BEGIN  
            RAISERROR('La nueva fecha/hora queda fuera del horario de uno o más empleados asignados.',16,1);  
        END  
  
        /* =========================================================  
           6) VALIDAR BLOQUEOS POR DETALLE/EMPLEADO/SUCURSAL  
           ========================================================= */  
        IF EXISTS  
        (  
            SELECT 1  
            FROM @DetalleEmpleado de  
            WHERE EXISTS  
            (  
                SELECT 1  
                FROM dbo.proc_empleadoBloqueoHorario ebh  
                WHERE ebh.folioEmpleado = de.folioEmpleado  
                  AND ebh.idEntidad = @idEntidad  
                  AND ebh.idSucursal = @idSucursal  
                  AND ISNULL(ebh.activo,1) = 1  
                  AND CONVERT(date, ebh.fecha) = CONVERT(date, de.horaInicioNueva)  
                  AND de.horaInicioNueva < ebh.horaFin  
                  AND de.horaFinNueva > ebh.horaInicio  
            )  
        )  
        BEGIN  
            RAISERROR('La nueva fecha/hora genera conflicto con bloqueos de uno o más empleados asignados.',16,1);  
        END  
  
        /* =========================================================  
           7) VALIDAR EMPALMES CONTRA OTRAS AGENDAS DEL EMPLEADO  
              (NO FILTRA POR SUCURSAL: EL EMPLEADO NO PUEDE  
               ESTAR EN DOS CITAS AL MISMO TIEMPO)  
           ========================================================= */  
        IF EXISTS  
        (  
            SELECT 1  
            FROM @DetalleEmpleado de  
            WHERE EXISTS  
            (  
                SELECT 1  
                FROM dbo.proc_agendaDetalleServicioEmpleado dse  
                INNER JOIN dbo.proc_agendaDetalleServicio ds  
                    ON ds.folioAgendaDetalleServicio = dse.folioAgendaDetalleServicio  
                   AND ds.idEntidad = dse.idEntidad  
                INNER JOIN dbo.proc_agenda a  
                    ON a.folioAgenda = ds.folioAgenda  
                   AND a.idEntidad = ds.idEntidad  
                INNER JOIN dbo.cat_estatusAgenda ea2  
                    ON ea2.id = a.idEstatusAgenda  
                   AND ea2.idEntidad = a.idEntidad  
                WHERE dse.folioEmpleado = de.folioEmpleado  
                  AND dse.idEntidad = @idEntidad  
                  AND ISNULL(dse.activo,1) = 1  
                  AND ISNULL(ds.activo,1) = 1  
                  AND ISNULL(ds.cancelado,0) = 0  
                  AND ISNULL(a.activo,1) = 1  
                  AND ea2.clave <> 'CANCELADA'  
                  AND ds.folioAgenda <> @folioAgenda  
                  AND de.horaInicioNueva < ISNULL(ds.horaFinProgramada, a.horaFinProgramada)  
                  AND de.horaFinNueva > ISNULL(ds.horaInicioProgramada, a.horaInicioProgramada)  
            )  
        )  
        BEGIN  
            RAISERROR('La nueva fecha/hora genera empalme con otra agenda para uno o más empleados asignados.',16,1);  
        END  
  
        /* =========================================================  
           8) INSERT REPROGRAMACION  
           ========================================================= */  
        INSERT INTO dbo.proc_agendaReprogramacion  
        (  
            folioAgenda,  
            fechaHoraAnteriorInicio,  
            fechaHoraAnteriorFin,  
            fechaHoraNuevaInicio,  
            fechaHoraNuevaFin,  
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
            @fechaHoraAnteriorInicio,  
            @fechaHoraAnteriorFin,  
            @fechaHoraNuevaInicio,  
            @fechaHoraNuevaFin,  
            @motivo,  
@comentarios,  
            1,  
            @idEntidad,  
            NULL,  
            NULL,  
            dbo.fn_GetDateMX(),  
            @idUsuarioAlta  
        );  
  
        SET @folioAgendaReprogramacion = SCOPE_IDENTITY();  
  
        /* =========================================================  
           9) UPDATE HEADER  
           ========================================================= */  
        UPDATE dbo.proc_agenda  
           SET fechaCita = CONVERT(date, @fechaHoraNuevaInicio),  
               horaInicioProgramada = @fechaHoraNuevaInicio,  
               horaFinProgramada = @fechaHoraNuevaFin,  
               fechaModificacion = dbo.fn_GetDateMX(),  
               idUsuarioModifica = @idUsuarioAlta  
         WHERE folioAgenda = @folioAgenda  
           AND idEntidad = @idEntidad;  
  
        /* =========================================================  
           10) UPDATE DETALLES PRESERVANDO OFFSETS  
           ========================================================= */  
        UPDATE ds  
           SET ds.horaInicioProgramada = d.horaInicioNueva,  
               ds.horaFinProgramada = d.horaFinNueva,  
               ds.fechaModificacion = dbo.fn_GetDateMX(),  
               ds.idUsuarioModifica = @idUsuarioAlta  
        FROM dbo.proc_agendaDetalleServicio ds  
        INNER JOIN @Detalles d  
            ON d.folioAgendaDetalleServicio = ds.folioAgendaDetalleServicio  
        WHERE ds.idEntidad = @idEntidad  
          AND ISNULL(ds.activo,1) = 1  
          AND ISNULL(ds.cancelado,0) = 0;  
  
        /* =========================================================  
           11) BITACORA  
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
            NULL,  
            @idTipoMovimientoAgenda,  
            NULL,  
            NULL,  
            'Reprogramación de agenda',  
            CONCAT  
            (  
                'Inicio=',  
                CONVERT(varchar(19), @fechaHoraAnteriorInicio, 120),  
                '; Fin=',  
                CONVERT(varchar(19), @fechaHoraAnteriorFin, 120)  
            ),  
            CONCAT  
            (  
                'Inicio=',  
                CONVERT(varchar(19), @fechaHoraNuevaInicio, 120),  
                '; Fin=',  
                CONVERT(varchar(19), @fechaHoraNuevaFin, 120)  
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
  
        EXEC [dbo].[sp_ui_notificaReprogramacionAgenda]
        @folioAgenda = @folioAgenda,
        @idEntidad = @idEntidad,
        @idSucursal = @idSucursal,
        @idUsuarioAlta = @idUsuarioAlta,
        @motivo = @motivo;
        COMMIT TRAN;  
  
        SELECT  
            @folioAgenda AS folioAgenda,  
            @folioAgendaReprogramacion AS folioAgendaReprogramacion;  
    END TRY  
    BEGIN CATCH  
        IF @@TRANCOUNT > 0  
            ROLLBACK TRAN;  
  
        DECLARE @ErrorMessage varchar(4000) = ERROR_MESSAGE();  
        DECLARE @ErrorLine int = ERROR_LINE();  
  
        RAISERROR('Error en reprogramación. Línea: %d. Mensaje: %s',16,1,@ErrorLine,@ErrorMessage);  
    END CATCH  
END 

  