SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   1) AJUSTE A TABLA EXISTENTE: cat_productosServicios
   ========================================================= */

IF COL_LENGTH('dbo.cat_productosServicios', 'esServicio') IS NULL
BEGIN
    ALTER TABLE dbo.cat_productosServicios
    ADD esServicio bit NOT NULL CONSTRAINT DF_cat_productosServicios_esServicio DEFAULT(0);
END
GO

IF COL_LENGTH('dbo.cat_productosServicios', 'duracionBaseMin') IS NULL
BEGIN
    ALTER TABLE dbo.cat_productosServicios
    ADD duracionBaseMin int NULL;
END
GO

IF COL_LENGTH('dbo.cat_productosServicios', 'colorCalendario') IS NULL
BEGIN
    ALTER TABLE dbo.cat_productosServicios
    ADD colorCalendario varchar(20) NULL;
END
GO

IF COL_LENGTH('dbo.cat_productosServicios', 'requiereEspecialidad') IS NULL
BEGIN
    ALTER TABLE dbo.cat_productosServicios
    ADD requiereEspecialidad bit NULL;
END
GO

IF COL_LENGTH('dbo.cat_productosServicios', 'permiteMultiplesEmpleados') IS NULL
BEGIN
    ALTER TABLE dbo.cat_productosServicios
    ADD permiteMultiplesEmpleados bit NULL;
END
GO

IF COL_LENGTH('dbo.cat_productosServicios', 'mostrarEnAgenda') IS NULL
BEGIN
    ALTER TABLE dbo.cat_productosServicios
    ADD mostrarEnAgenda bit NULL;
END
GO


/* =========================================================
   2) CATALOGOS
   ========================================================= */

IF OBJECT_ID('dbo.cat_estatusAgenda', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.cat_estatusAgenda
    (
        idEstatusAgenda int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        descripcion varchar(150) NOT NULL,
        clave varchar(50) NOT NULL,
        orden int NOT NULL,
        esFinal bit NOT NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL
    );
END
GO

IF OBJECT_ID('dbo.cat_estatusAgendaDetalleServicio', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.cat_estatusAgendaDetalleServicio
    (
        idEstatusAgendaDetalleServicio int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        descripcion varchar(150) NOT NULL,
        clave varchar(50) NOT NULL,
        orden int NOT NULL,
        esFinal bit NOT NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL
    );
END
GO

IF OBJECT_ID('dbo.cat_origenAgenda', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.cat_origenAgenda
    (
        idOrigenAgenda int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        descripcion varchar(100) NOT NULL,
        clave varchar(50) NOT NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL
    );
END
GO

IF OBJECT_ID('dbo.cat_tipoMovimientoAgenda', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.cat_tipoMovimientoAgenda
    (
        idTipoMovimientoAgenda int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        descripcion varchar(150) NOT NULL,
        clave varchar(50) NOT NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL
    );
END
GO

IF OBJECT_ID('dbo.cat_tipoMovimientoPagoAgenda', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.cat_tipoMovimientoPagoAgenda
    (
        idTipoMovimientoPagoAgenda int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        descripcion varchar(150) NOT NULL,
        clave varchar(50) NOT NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL
    );
END
GO

IF OBJECT_ID('dbo.cat_estatusPagoAgenda', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.cat_estatusPagoAgenda
    (
        idEstatusPagoAgenda int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        descripcion varchar(150) NOT NULL,
        clave varchar(50) NOT NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL
    );
END
GO

IF OBJECT_ID('dbo.cat_tipoBloqueoHorario', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.cat_tipoBloqueoHorario
    (
        idTipoBloqueoHorario int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        descripcion varchar(150) NOT NULL,
        clave varchar(50) NOT NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL
    );
END
GO

IF OBJECT_ID('dbo.cat_rolParticipacionServicio', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.cat_rolParticipacionServicio
    (
        idRolParticipacionServicio int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        descripcion varchar(100) NOT NULL,
        clave varchar(50) NOT NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL
    );
END
GO


/* =========================================================
   3) TABLAS OPERATIVAS
   ========================================================= */

IF OBJECT_ID('dbo.proc_empleadoHorario', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.proc_empleadoHorario
    (
        folioEmpleadoHorario int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        folioEmpleado int NOT NULL,
        diaSemana int NOT NULL,
        horaEntrada datetime NOT NULL,
        horaSalida datetime NOT NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL
    );
END
GO

IF OBJECT_ID('dbo.proc_empleadoBloqueoHorario', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.proc_empleadoBloqueoHorario
    (
        folioEmpleadoBloqueoHorario int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        folioEmpleado int NOT NULL,
        fecha datetime NOT NULL,
        horaInicio datetime NOT NULL,
        horaFin datetime NOT NULL,
        idTipoBloqueoHorario int NOT NULL,
        motivo varchar(450) NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL,
        CONSTRAINT FK_proc_empleadoBloqueoHorario_cat_tipoBloqueoHorario
            FOREIGN KEY (idTipoBloqueoHorario) REFERENCES dbo.cat_tipoBloqueoHorario(idTipoBloqueoHorario)
    );
END
GO

IF OBJECT_ID('dbo.proc_agenda', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.proc_agenda
    (
        folioAgenda int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        folioCliente int NOT NULL,
        idSucursal int NOT NULL,
        fechaCita datetime NOT NULL,
        horaInicioProgramada datetime NOT NULL,
        horaFinProgramada datetime NOT NULL,
        idEstatusAgenda int NOT NULL,
        idOrigenAgenda int NOT NULL,
        confirmada bit NOT NULL,
        fechaConfirmacion datetime NULL,
        folioVenta int NULL,
        totalCotizado decimal(16,4) NULL,
        totalPagado decimal(16,4) NULL,
        requiereConfirmacion bit NOT NULL,
        observacionesInternas varchar(450) NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL,
        CONSTRAINT FK_proc_agenda_cat_estatusAgenda
            FOREIGN KEY (idEstatusAgenda) REFERENCES dbo.cat_estatusAgenda(idEstatusAgenda),
        CONSTRAINT FK_proc_agenda_cat_origenAgenda
            FOREIGN KEY (idOrigenAgenda) REFERENCES dbo.cat_origenAgenda(idOrigenAgenda)
    );
END
GO

IF OBJECT_ID('dbo.proc_agendaDetalleServicio', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.proc_agendaDetalleServicio
    (
        folioAgendaDetalleServicio int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        folioAgenda int NOT NULL,
        idProductoServicio int NOT NULL,
        descripcionServicio varchar(250) NOT NULL,
        duracionEstimadaMin int NOT NULL,
        precioLista decimal(16,4) NOT NULL,
        precioFinal decimal(16,4) NOT NULL,
        descuento decimal(16,4) NULL,
        cantidad decimal(16,4) NULL,
        ordenServicio int NOT NULL,
        horaInicioProgramada datetime NULL,
        horaFinProgramada datetime NULL,
        horaInicioReal datetime NULL,
        horaFinReal datetime NULL,
        idEstatusAgendaDetalleServicio int NOT NULL,
        cancelado bit NOT NULL,
        motivoCancelacion varchar(450) NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL,
        CONSTRAINT FK_proc_agendaDetalleServicio_proc_agenda
            FOREIGN KEY (folioAgenda) REFERENCES dbo.proc_agenda(folioAgenda),
        CONSTRAINT FK_proc_agendaDetalleServicio_cat_productosServicios
            FOREIGN KEY (idProductoServicio) REFERENCES dbo.cat_productosServicios(id),
        CONSTRAINT FK_proc_agendaDetalleServicio_cat_estatusAgendaDetalleServicio
            FOREIGN KEY (idEstatusAgendaDetalleServicio) REFERENCES dbo.cat_estatusAgendaDetalleServicio(idEstatusAgendaDetalleServicio)
    );
END
GO

IF OBJECT_ID('dbo.proc_agendaDetalleServicioEmpleado', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.proc_agendaDetalleServicioEmpleado
    (
        folioAgendaDetalleServicioEmpleado int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        folioAgendaDetalleServicio int NOT NULL,
        folioEmpleado int NOT NULL,
        idRolParticipacionServicio int NOT NULL,
        porcentajeParticipacion decimal(16,4) NULL,
        comisionCalculada decimal(16,4) NULL,
        horaInicioReal datetime NULL,
        horaFinReal datetime NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL,
        CONSTRAINT FK_proc_agendaDetalleServicioEmpleado_proc_agendaDetalleServicio
            FOREIGN KEY (folioAgendaDetalleServicio) REFERENCES dbo.proc_agendaDetalleServicio(folioAgendaDetalleServicio),
        CONSTRAINT FK_proc_agendaDetalleServicioEmpleado_cat_rolParticipacionServicio
            FOREIGN KEY (idRolParticipacionServicio) REFERENCES dbo.cat_rolParticipacionServicio(idRolParticipacionServicio)
    );
END
GO

IF OBJECT_ID('dbo.proc_agendaPago', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.proc_agendaPago
    (
        folioAgendaPago int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        folioAgenda int NOT NULL,
        idTipoMovimientoPagoAgenda int NOT NULL,
        idEstatusPagoAgenda int NOT NULL,
        montoTotal decimal(16,4) NOT NULL,
        fechaPago datetime NOT NULL,
        referenciaExterna varchar(250) NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL,
        CONSTRAINT FK_proc_agendaPago_proc_agenda
            FOREIGN KEY (folioAgenda) REFERENCES dbo.proc_agenda(folioAgenda),
        CONSTRAINT FK_proc_agendaPago_cat_tipoMovimientoPagoAgenda
            FOREIGN KEY (idTipoMovimientoPagoAgenda) REFERENCES dbo.cat_tipoMovimientoPagoAgenda(idTipoMovimientoPagoAgenda),
        CONSTRAINT FK_proc_agendaPago_cat_estatusPagoAgenda
            FOREIGN KEY (idEstatusPagoAgenda) REFERENCES dbo.cat_estatusPagoAgenda(idEstatusPagoAgenda)
    );
END
GO

IF OBJECT_ID('dbo.proc_agendaPagoDetalle', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.proc_agendaPagoDetalle
    (
        folioAgendaPagoDetalle int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        folioAgendaPago int NOT NULL,
        idTipoPago int NOT NULL,
        montoPago decimal(16,4) NOT NULL,
        numeroAutorizacion varchar(250) NULL,
        referenciaOperacion varchar(250) NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL,
        CONSTRAINT FK_proc_agendaPagoDetalle_proc_agendaPago
            FOREIGN KEY (folioAgendaPago) REFERENCES dbo.proc_agendaPago(folioAgendaPago)
    );
END
GO

IF OBJECT_ID('dbo.proc_agendaBitacora', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.proc_agendaBitacora
    (
        folioAgendaBitacora int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        folioAgenda int NOT NULL,
        folioAgendaDetalleServicio int NULL,
        idTipoMovimientoAgenda int NOT NULL,
        idEstatusAnterior int NULL,
        idEstatusNuevo int NULL,
        descripcionMovimiento varchar(450) NULL,
        datosAntes varchar(max) NULL,
        datosDespues varchar(max) NULL,
        fechaMovimiento datetime NOT NULL,
        comentarios varchar(450) NULL,
        activo bit NULL,
        idEntidad int NOT NULL,
        fechaModificacion datetime NULL,
        idUsuarioModifica int NULL,
        fechaAlta datetime NOT NULL,
        idUsuarioAlta int NOT NULL,
        CONSTRAINT FK_proc_agendaBitacora_proc_agenda
            FOREIGN KEY (folioAgenda) REFERENCES dbo.proc_agenda(folioAgenda),
        CONSTRAINT FK_proc_agendaBitacora_proc_agendaDetalleServicio
            FOREIGN KEY (folioAgendaDetalleServicio) REFERENCES dbo.proc_agendaDetalleServicio(folioAgendaDetalleServicio),
        CONSTRAINT FK_proc_agendaBitacora_cat_tipoMovimientoAgenda
            FOREIGN KEY (idTipoMovimientoAgenda) REFERENCES dbo.cat_tipoMovimientoAgenda(idTipoMovimientoAgenda)
    );
END
GO


/* =========================================================
   4) INDICES MINIMOS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_agenda_1' AND object_id = OBJECT_ID('dbo.proc_agenda'))
    CREATE INDEX IX_proc_agenda_1 ON dbo.proc_agenda(idEntidad, fechaCita, activo);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_agenda_2' AND object_id = OBJECT_ID('dbo.proc_agenda'))
    CREATE INDEX IX_proc_agenda_2 ON dbo.proc_agenda(idEntidad, folioCliente, activo);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_agenda_3' AND object_id = OBJECT_ID('dbo.proc_agenda'))
    CREATE INDEX IX_proc_agenda_3 ON dbo.proc_agenda(idEntidad, idSucursal, fechaCita);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_agendaDetalleServicio_1' AND object_id = OBJECT_ID('dbo.proc_agendaDetalleServicio'))
    CREATE INDEX IX_proc_agendaDetalleServicio_1 ON dbo.proc_agendaDetalleServicio(idEntidad, folioAgenda);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_agendaDetalleServicio_2' AND object_id = OBJECT_ID('dbo.proc_agendaDetalleServicio'))
    CREATE INDEX IX_proc_agendaDetalleServicio_2 ON dbo.proc_agendaDetalleServicio(idEntidad, idProductoServicio);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_agendaDetalleServicio_3' AND object_id = OBJECT_ID('dbo.proc_agendaDetalleServicio'))
    CREATE INDEX IX_proc_agendaDetalleServicio_3 ON dbo.proc_agendaDetalleServicio(idEntidad, idEstatusAgendaDetalleServicio);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_agendaDetalleServicioEmpleado_1' AND object_id = OBJECT_ID('dbo.proc_agendaDetalleServicioEmpleado'))
    CREATE INDEX IX_proc_agendaDetalleServicioEmpleado_1 ON dbo.proc_agendaDetalleServicioEmpleado(idEntidad, folioAgendaDetalleServicio);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_agendaDetalleServicioEmpleado_2' AND object_id = OBJECT_ID('dbo.proc_agendaDetalleServicioEmpleado'))
    CREATE INDEX IX_proc_agendaDetalleServicioEmpleado_2 ON dbo.proc_agendaDetalleServicioEmpleado(idEntidad, folioEmpleado);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_agendaPago_1' AND object_id = OBJECT_ID('dbo.proc_agendaPago'))
    CREATE INDEX IX_proc_agendaPago_1 ON dbo.proc_agendaPago(idEntidad, folioAgenda);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_agendaPago_2' AND object_id = OBJECT_ID('dbo.proc_agendaPago'))
    CREATE INDEX IX_proc_agendaPago_2 ON dbo.proc_agendaPago(idEntidad, fechaPago);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_agendaPagoDetalle_1' AND object_id = OBJECT_ID('dbo.proc_agendaPagoDetalle'))
    CREATE INDEX IX_proc_agendaPagoDetalle_1 ON dbo.proc_agendaPagoDetalle(idEntidad, folioAgendaPago);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_agendaBitacora_1' AND object_id = OBJECT_ID('dbo.proc_agendaBitacora'))
    CREATE INDEX IX_proc_agendaBitacora_1 ON dbo.proc_agendaBitacora(idEntidad, folioAgenda);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_agendaBitacora_2' AND object_id = OBJECT_ID('dbo.proc_agendaBitacora'))
    CREATE INDEX IX_proc_agendaBitacora_2 ON dbo.proc_agendaBitacora(idEntidad, fechaMovimiento);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_empleadoHorario_1' AND object_id = OBJECT_ID('dbo.proc_empleadoHorario'))
    CREATE INDEX IX_proc_empleadoHorario_1 ON dbo.proc_empleadoHorario(idEntidad, folioEmpleado, diaSemana);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_proc_empleadoBloqueoHorario_1' AND object_id = OBJECT_ID('dbo.proc_empleadoBloqueoHorario'))
    CREATE INDEX IX_proc_empleadoBloqueoHorario_1 ON dbo.proc_empleadoBloqueoHorario(idEntidad, folioEmpleado, fecha);
GO

--------------------------------------------------------------------------------

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   1) CATALOGOS SEMILLA
   AJUSTA @idEntidad e @idUsuarioAlta
   ========================================================= */

DECLARE @idEntidad int = 1,
        @idUsuarioAlta int = 1;


/* cat_origenAgenda */
IF NOT EXISTS (SELECT 1 FROM dbo.cat_origenAgenda WHERE idEntidad = @idEntidad AND clave = 'POS')
BEGIN
    INSERT INTO dbo.cat_origenAgenda
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('POS', 'POS', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_origenAgenda WHERE idEntidad = @idEntidad AND clave = 'WHATSAPP')
BEGIN
    INSERT INTO dbo.cat_origenAgenda
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('WhatsApp', 'WHATSAPP', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_origenAgenda WHERE idEntidad = @idEntidad AND clave = 'WEB')
BEGIN
    INSERT INTO dbo.cat_origenAgenda
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Web', 'WEB', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_origenAgenda WHERE idEntidad = @idEntidad AND clave = 'MANUAL')
BEGIN
    INSERT INTO dbo.cat_origenAgenda
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Manual', 'MANUAL', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END


/* cat_estatusAgenda */
IF NOT EXISTS (SELECT 1 FROM dbo.cat_estatusAgenda WHERE idEntidad = @idEntidad AND clave = 'REGISTRADA')
BEGIN
    INSERT INTO dbo.cat_estatusAgenda
    (
        descripcion, clave, orden, esFinal, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Registrada', 'REGISTRADA', 1, 0, NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_estatusAgenda WHERE idEntidad = @idEntidad AND clave = 'CONFIRMADA')
BEGIN
    INSERT INTO dbo.cat_estatusAgenda
    (
        descripcion, clave, orden, esFinal, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Confirmada', 'CONFIRMADA', 2, 0, NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_estatusAgenda WHERE idEntidad = @idEntidad AND clave = 'ENPROCESO')
BEGIN
    INSERT INTO dbo.cat_estatusAgenda
    (
        descripcion, clave, orden, esFinal, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('En proceso', 'ENPROCESO', 3, 0, NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_estatusAgenda WHERE idEntidad = @idEntidad AND clave = 'CONCLUIDA')
BEGIN
    INSERT INTO dbo.cat_estatusAgenda
    (
        descripcion, clave, orden, esFinal, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Concluida', 'CONCLUIDA', 4, 1, NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_estatusAgenda WHERE idEntidad = @idEntidad AND clave = 'CANCELADA')
BEGIN
    INSERT INTO dbo.cat_estatusAgenda
    (
        descripcion, clave, orden, esFinal, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Cancelada', 'CANCELADA', 5, 1, NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_estatusAgenda WHERE idEntidad = @idEntidad AND clave = 'NOASISTIO')
BEGIN
    INSERT INTO dbo.cat_estatusAgenda
    (
        descripcion, clave, orden, esFinal, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('No asistió', 'NOASISTIO', 6, 1, NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END


/* cat_estatusAgendaDetalleServicio */
IF NOT EXISTS (SELECT 1 FROM dbo.cat_estatusAgendaDetalleServicio WHERE idEntidad = @idEntidad AND clave = 'PENDIENTE')
BEGIN
    INSERT INTO dbo.cat_estatusAgendaDetalleServicio
    (
        descripcion, clave, orden, esFinal, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Pendiente', 'PENDIENTE', 1, 0, NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_estatusAgendaDetalleServicio WHERE idEntidad = @idEntidad AND clave = 'ASIGNADO')
BEGIN
    INSERT INTO dbo.cat_estatusAgendaDetalleServicio
    (
        descripcion, clave, orden, esFinal, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Asignado', 'ASIGNADO', 2, 0, NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_estatusAgendaDetalleServicio WHERE idEntidad = @idEntidad AND clave = 'ENPROCESO')
BEGIN
    INSERT INTO dbo.cat_estatusAgendaDetalleServicio
    (
        descripcion, clave, orden, esFinal, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('En proceso', 'ENPROCESO', 3, 0, NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_estatusAgendaDetalleServicio WHERE idEntidad = @idEntidad AND clave = 'CONCLUIDO')
BEGIN
    INSERT INTO dbo.cat_estatusAgendaDetalleServicio
    (
        descripcion, clave, orden, esFinal, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Concluido', 'CONCLUIDO', 4, 1, NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_estatusAgendaDetalleServicio WHERE idEntidad = @idEntidad AND clave = 'CANCELADO')
BEGIN
    INSERT INTO dbo.cat_estatusAgendaDetalleServicio
    (
        descripcion, clave, orden, esFinal, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Cancelado', 'CANCELADO', 5, 1, NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END


/* cat_tipoMovimientoAgenda */
IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipoMovimientoAgenda WHERE idEntidad = @idEntidad AND clave = 'ALTA')
BEGIN
    INSERT INTO dbo.cat_tipoMovimientoAgenda
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Alta', 'ALTA', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipoMovimientoAgenda WHERE idEntidad = @idEntidad AND clave = 'EDICION')
BEGIN
    INSERT INTO dbo.cat_tipoMovimientoAgenda
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Edición', 'EDICION', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipoMovimientoAgenda WHERE idEntidad = @idEntidad AND clave = 'CAMBIOESTATUS')
BEGIN
    INSERT INTO dbo.cat_tipoMovimientoAgenda
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Cambio estatus', 'CAMBIOESTATUS', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipoMovimientoAgenda WHERE idEntidad = @idEntidad AND clave = 'PAGO')
BEGIN
    INSERT INTO dbo.cat_tipoMovimientoAgenda
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Pago', 'PAGO', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END


/* cat_tipoMovimientoPagoAgenda */
IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipoMovimientoPagoAgenda WHERE idEntidad = @idEntidad AND clave = 'ANTICIPO')
BEGIN
    INSERT INTO dbo.cat_tipoMovimientoPagoAgenda
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Anticipo', 'ANTICIPO', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipoMovimientoPagoAgenda WHERE idEntidad = @idEntidad AND clave = 'LIQUIDACION')
BEGIN
    INSERT INTO dbo.cat_tipoMovimientoPagoAgenda
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Liquidación', 'LIQUIDACION', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END


/* cat_estatusPagoAgenda */
IF NOT EXISTS (SELECT 1 FROM dbo.cat_estatusPagoAgenda WHERE idEntidad = @idEntidad AND clave = 'APLICADO')
BEGIN
    INSERT INTO dbo.cat_estatusPagoAgenda
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Aplicado', 'APLICADO', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END


/* cat_tipoBloqueoHorario */
IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipoBloqueoHorario WHERE idEntidad = @idEntidad AND clave = 'COMIDA')
BEGIN
    INSERT INTO dbo.cat_tipoBloqueoHorario
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Comida', 'COMIDA', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipoBloqueoHorario WHERE idEntidad = @idEntidad AND clave = 'DESCANSO')
BEGIN
    INSERT INTO dbo.cat_tipoBloqueoHorario
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Descanso', 'DESCANSO', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipoBloqueoHorario WHERE idEntidad = @idEntidad AND clave = 'VACACIONES')
BEGIN
    INSERT INTO dbo.cat_tipoBloqueoHorario
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Vacaciones', 'VACACIONES', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipoBloqueoHorario WHERE idEntidad = @idEntidad AND clave = 'MANUAL')
BEGIN
    INSERT INTO dbo.cat_tipoBloqueoHorario
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Manual', 'MANUAL', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END


/* cat_rolParticipacionServicio */
IF NOT EXISTS (SELECT 1 FROM dbo.cat_rolParticipacionServicio WHERE idEntidad = @idEntidad AND clave = 'PRINCIPAL')
BEGIN
    INSERT INTO dbo.cat_rolParticipacionServicio
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Principal', 'PRINCIPAL', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END

IF NOT EXISTS (SELECT 1 FROM dbo.cat_rolParticipacionServicio WHERE idEntidad = @idEntidad AND clave = 'APOYO')
BEGIN
    INSERT INTO dbo.cat_rolParticipacionServicio
    (
        descripcion, clave, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    ('Apoyo', 'APOYO', NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta);
END
GO


/* =========================================================
   2) SP: ALTA DE AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agenda
(
    @folioAgenda int = 0,
    @folioCliente int,
    @idSucursal int,
    @fechaCita datetime,
    @horaInicioProgramada datetime,
    @horaFinProgramada datetime,
    @idOrigenAgenda int,
    @requiereConfirmacion bit = 0,
    @observacionesInternas varchar(450) = NULL,
    @comentarios varchar(450) = NULL,
    @activo bit = 1,
    @idEntidad int,
    @idUsuarioModifica int = NULL,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAgenda int;

    SELECT @idEstatusAgenda = idEstatusAgenda
    FROM dbo.cat_estatusAgenda
    WHERE idEntidad = @idEntidad
      AND clave = 'REGISTRADA'
      AND ISNULL(activo,1) = 1;

    IF ISNULL(@idEstatusAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el estatus REGISTRADA para la agenda.',16,1);
        RETURN;
    END

    IF @folioAgenda = 0
    BEGIN
        INSERT INTO dbo.proc_agenda
        (
            folioCliente, idSucursal, fechaCita, horaInicioProgramada, horaFinProgramada,
            idEstatusAgenda, idOrigenAgenda, confirmada, fechaConfirmacion, folioVenta,
            totalCotizado, totalPagado, requiereConfirmacion, observacionesInternas,
            comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
        )
        VALUES
        (
            @folioCliente, @idSucursal, @fechaCita, @horaInicioProgramada, @horaFinProgramada,
            @idEstatusAgenda, @idOrigenAgenda, 0, NULL, NULL,
            0, 0, @requiereConfirmacion, @observacionesInternas,
            @comentarios, @activo, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
        );

        SET @folioAgenda = SCOPE_IDENTITY();

        INSERT INTO dbo.proc_agendaBitacora
        (
            folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda, idEstatusAnterior, idEstatusNuevo,
            descripcionMovimiento, datosAntes, datosDespues, fechaMovimiento,
            comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
        )
        SELECT
            @folioAgenda, NULL, tma.idTipoMovimientoAgenda, NULL, @idEstatusAgenda,
            'Alta de agenda', NULL, NULL, GETDATE(),
            NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
        FROM dbo.cat_tipoMovimientoAgenda tma
        WHERE tma.idEntidad = @idEntidad
          AND tma.clave = 'ALTA';
    END
    ELSE
    BEGIN
        UPDATE dbo.proc_agenda
           SET folioCliente = @folioCliente,
               idSucursal = @idSucursal,
               fechaCita = @fechaCita,
               horaInicioProgramada = @horaInicioProgramada,
               horaFinProgramada = @horaFinProgramada,
               idOrigenAgenda = @idOrigenAgenda,
               requiereConfirmacion = @requiereConfirmacion,
               observacionesInternas = @observacionesInternas,
               comentarios = @comentarios,
               activo = @activo,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioModifica
         WHERE folioAgenda = @folioAgenda
           AND idEntidad = @idEntidad;

        INSERT INTO dbo.proc_agendaBitacora
        (
            folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda, idEstatusAnterior, idEstatusNuevo,
            descripcionMovimiento, datosAntes, datosDespues, fechaMovimiento,
            comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
        )
        SELECT
            @folioAgenda, NULL, tma.idTipoMovimientoAgenda, NULL, NULL,
            'Edición de agenda', NULL, NULL, GETDATE(),
            NULL, 1, @idEntidad, NULL, NULL, GETDATE(), ISNULL(@idUsuarioModifica,@idUsuarioAlta)
        FROM dbo.cat_tipoMovimientoAgenda tma
        WHERE tma.idEntidad = @idEntidad
          AND tma.clave = 'EDICION';
    END

    SELECT @folioAgenda AS folioAgenda;
END
GO


/* =========================================================
   3) SP: ALTA / EDICION DETALLE SERVICIO
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaDetalleServicio
(
    @folioAgendaDetalleServicio int = 0,
    @folioAgenda int,
    @idProductoServicio int,
    @precioFinal decimal(16,4),
    @descuento decimal(16,4) = NULL,
    @cantidad decimal(16,4) = 1,
    @ordenServicio int = 1,
    @horaInicioProgramada datetime = NULL,
    @horaFinProgramada datetime = NULL,
    @comentarios varchar(450) = NULL,
    @activo bit = 1,
    @idEntidad int,
    @idUsuarioModifica int = NULL,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @descripcionServicio varchar(250),
            @duracionEstimadaMin int,
            @precioLista decimal(16,4),
            @idEstatusAgendaDetalleServicio int;

    SELECT
        @descripcionServicio = ps.descripcion,
        @duracionEstimadaMin = ISNULL(ps.duracionBaseMin,0),
        @precioLista = ISNULL(precio.precioPrimera,0)
    FROM dbo.cat_productosServicios ps
		JOIN dbo.cat_precios precio
			On precio.idProductoServicio = ps.id
			And ps.idEntidad = precio.idEntidad 
			WHERE ps.id = @idProductoServicio
      AND ps.idEntidad = @idEntidad
      AND ISNULL(ps.activo,1) = 1
      AND ISNULL(ps.esServicio,0) = 1;

    IF @descripcionServicio IS NULL
    BEGIN
        RAISERROR('El producto/servicio indicado no existe o no está marcado como servicio.',16,1);
        RETURN;
    END

    SELECT @idEstatusAgendaDetalleServicio = idEstatusAgendaDetalleServicio
    FROM dbo.cat_estatusAgendaDetalleServicio
    WHERE idEntidad = @idEntidad
      AND clave = 'PENDIENTE'
      AND ISNULL(activo,1) = 1;

    IF ISNULL(@idEstatusAgendaDetalleServicio,0) = 0
    BEGIN
        RAISERROR('No se encontró el estatus PENDIENTE para detalle de servicio.',16,1);
        RETURN;
    END

    IF @folioAgendaDetalleServicio = 0
    BEGIN
        INSERT INTO dbo.proc_agendaDetalleServicio
        (
            folioAgenda, idProductoServicio, descripcionServicio, duracionEstimadaMin,
            precioLista, precioFinal, descuento, cantidad, ordenServicio,
            horaInicioProgramada, horaFinProgramada, horaInicioReal, horaFinReal,
            idEstatusAgendaDetalleServicio, cancelado, motivoCancelacion,
            comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
        )
        VALUES
        (
            @folioAgenda, @idProductoServicio, @descripcionServicio, @duracionEstimadaMin,
            @precioLista, @precioFinal, @descuento, @cantidad, @ordenServicio,
            @horaInicioProgramada, @horaFinProgramada, NULL, NULL,
            @idEstatusAgendaDetalleServicio, 0, NULL,
            @comentarios, @activo, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
        );

        SET @folioAgendaDetalleServicio = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.proc_agendaDetalleServicio
           SET precioFinal = @precioFinal,
               descuento = @descuento,
               cantidad = @cantidad,
               ordenServicio = @ordenServicio,
               horaInicioProgramada = @horaInicioProgramada,
               horaFinProgramada = @horaFinProgramada,
               comentarios = @comentarios,
               activo = @activo,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioModifica
         WHERE folioAgendaDetalleServicio = @folioAgendaDetalleServicio
           AND idEntidad = @idEntidad;
    END

    UPDATE a
       SET totalCotizado = ISNULL((
            SELECT SUM(ISNULL(ds.precioFinal,0) * ISNULL(ds.cantidad,1))
            FROM dbo.proc_agendaDetalleServicio ds
            WHERE ds.folioAgenda = a.folioAgenda
              AND ds.idEntidad = a.idEntidad
              AND ISNULL(ds.activo,1) = 1
        ),0),
           fechaModificacion = GETDATE(),
           idUsuarioModifica = ISNULL(@idUsuarioModifica,@idUsuarioAlta)
    FROM dbo.proc_agenda a
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad;

    SELECT @folioAgendaDetalleServicio AS folioAgendaDetalleServicio;
END
GO


/* =========================================================
   4) SP: REGISTRAR PAGO DE AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaPago
(
    @folioAgenda int,
    @idTipoMovimientoPagoAgenda int,
    @idTipoPago int,
    @montoPago decimal(16,4),
    @numeroAutorizacion varchar(250) = NULL,
    @referenciaOperacion varchar(250) = NULL,
    @referenciaExterna varchar(250) = NULL,
    @comentarios varchar(450) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @folioAgendaPago int,
            @idEstatusPagoAgenda int,
            @idTipoMovimientoAgenda int;

    SELECT @idEstatusPagoAgenda = idEstatusPagoAgenda
    FROM dbo.cat_estatusPagoAgenda
    WHERE idEntidad = @idEntidad
      AND clave = 'APLICADO'
      AND ISNULL(activo,1) = 1;

    IF ISNULL(@idEstatusPagoAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el estatus de pago APLICADO.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda
    WHERE idEntidad = @idEntidad
      AND clave = 'PAGO'
      AND ISNULL(activo,1) = 1;

    IF ISNULL(@idTipoMovimientoAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el tipo de movimiento PAGO.',16,1);
        RETURN;
    END

    INSERT INTO dbo.proc_agendaPago
    (
        folioAgenda, idTipoMovimientoPagoAgenda, idEstatusPagoAgenda, montoTotal,
        fechaPago, referenciaExterna, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, @idTipoMovimientoPagoAgenda, @idEstatusPagoAgenda, @montoPago,
        GETDATE(), @referenciaExterna, @comentarios, 1, @idEntidad,
        NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SET @folioAgendaPago = SCOPE_IDENTITY();

    INSERT INTO dbo.proc_agendaPagoDetalle
    (
        folioAgendaPago, idTipoPago, montoPago, numeroAutorizacion, referenciaOperacion,
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgendaPago, @idTipoPago, @montoPago, @numeroAutorizacion, @referenciaOperacion,
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    UPDATE a
       SET totalPagado = ISNULL((
            SELECT SUM(ISNULL(ap.montoTotal,0))
            FROM dbo.proc_agendaPago ap
            WHERE ap.folioAgenda = a.folioAgenda
              AND ap.idEntidad = a.idEntidad
              AND ISNULL(ap.activo,1) = 1
        ),0),
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
    FROM dbo.proc_agenda a
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda, idEstatusAnterior, idEstatusNuevo,
        descripcionMovimiento, datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, NULL, @idTipoMovimientoAgenda, NULL, NULL,
        'Registro de pago de agenda', NULL, NULL, GETDATE(),
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgendaPago AS folioAgendaPago;
END
GO


/* =========================================================
   5) SP: CAMBIO DE ESTATUS DE AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaCambioEstatus
(
    @folioAgenda int,
    @idEstatusAgendaNuevo int,
    @descripcionMovimiento varchar(450) = NULL,
    @comentarios varchar(450) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAnterior int,
            @idTipoMovimientoAgenda int;

    SELECT @idEstatusAnterior = idEstatusAgenda
    FROM dbo.proc_agenda
    WHERE folioAgenda = @folioAgenda
      AND idEntidad = @idEntidad;

    IF ISNULL(@idEstatusAnterior,0) = 0
    BEGIN
        RAISERROR('No se encontró la agenda indicada.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda
    WHERE idEntidad = @idEntidad
      AND clave = 'CAMBIOESTATUS'
      AND ISNULL(activo,1) = 1;

    IF ISNULL(@idTipoMovimientoAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el tipo de movimiento CAMBIOESTATUS.',16,1);
        RETURN;
    END

    UPDATE dbo.proc_agenda
       SET idEstatusAgenda = @idEstatusAgendaNuevo,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgenda = @folioAgenda
       AND idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda, idEstatusAnterior, idEstatusNuevo,
        descripcionMovimiento, datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, NULL, @idTipoMovimientoAgenda, @idEstatusAnterior, @idEstatusAgendaNuevo,
        ISNULL(@descripcionMovimiento,'Cambio de estatus de agenda'), NULL, NULL, GETDATE(),
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgenda AS folioAgenda;
END
GO

-------------------------------------------

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   1) ALTA / EDICION EMPLEADO POR SERVICIO
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaDetalleServicioEmpleado
(
    @folioAgendaDetalleServicioEmpleado int = 0,
    @folioAgendaDetalleServicio int,
    @folioEmpleado int,
    @idRolParticipacionServicio int,
    @porcentajeParticipacion decimal(16,4) = NULL,
    @comisionCalculada decimal(16,4) = NULL,
    @horaInicioReal datetime = NULL,
    @horaFinReal datetime = NULL,
    @comentarios varchar(450) = NULL,
    @activo bit = 1,
    @idEntidad int,
    @idUsuarioModifica int = NULL,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.proc_agendaDetalleServicio
        WHERE folioAgendaDetalleServicio = @folioAgendaDetalleServicio
          AND idEntidad = @idEntidad
          AND ISNULL(activo,1) = 1
    )
    BEGIN
        RAISERROR('No existe el detalle de servicio indicado.',16,1);
        RETURN;
    END

    IF @folioAgendaDetalleServicioEmpleado = 0
    BEGIN
        INSERT INTO dbo.proc_agendaDetalleServicioEmpleado
        (
            folioAgendaDetalleServicio, folioEmpleado, idRolParticipacionServicio,
            porcentajeParticipacion, comisionCalculada, horaInicioReal, horaFinReal,
            comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
        )
        VALUES
        (
            @folioAgendaDetalleServicio, @folioEmpleado, @idRolParticipacionServicio,
            @porcentajeParticipacion, @comisionCalculada, @horaInicioReal, @horaFinReal,
            @comentarios, @activo, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
        );

        SET @folioAgendaDetalleServicioEmpleado = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.proc_agendaDetalleServicioEmpleado
           SET folioEmpleado = @folioEmpleado,
               idRolParticipacionServicio = @idRolParticipacionServicio,
               porcentajeParticipacion = @porcentajeParticipacion,
               comisionCalculada = @comisionCalculada,
               horaInicioReal = @horaInicioReal,
               horaFinReal = @horaFinReal,
               comentarios = @comentarios,
               activo = @activo,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioModifica
         WHERE folioAgendaDetalleServicioEmpleado = @folioAgendaDetalleServicioEmpleado
           AND idEntidad = @idEntidad;
    END

    SELECT @folioAgendaDetalleServicioEmpleado AS folioAgendaDetalleServicioEmpleado;
END
GO


/* =========================================================
   2) ALTA / EDICION HORARIO EMPLEADO
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_empleadoHorario
(
    @folioEmpleadoHorario int = 0,
    @folioEmpleado int,
    @diaSemana int,
    @horaEntrada datetime,
    @horaSalida datetime,
    @comentarios varchar(450) = NULL,
    @activo bit = 1,
    @idEntidad int,
    @idUsuarioModifica int = NULL,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @horaSalida <= @horaEntrada
    BEGIN
        RAISERROR('La hora de salida debe ser mayor a la hora de entrada.',16,1);
        RETURN;
    END

    IF @folioEmpleadoHorario = 0
    BEGIN
        INSERT INTO dbo.proc_empleadoHorario
        (
            folioEmpleado, diaSemana, horaEntrada, horaSalida,
            comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
        )
        VALUES
        (
            @folioEmpleado, @diaSemana, @horaEntrada, @horaSalida,
            @comentarios, @activo, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
        );

        SET @folioEmpleadoHorario = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.proc_empleadoHorario
           SET folioEmpleado = @folioEmpleado,
               diaSemana = @diaSemana,
               horaEntrada = @horaEntrada,
               horaSalida = @horaSalida,
               comentarios = @comentarios,
               activo = @activo,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioModifica
         WHERE folioEmpleadoHorario = @folioEmpleadoHorario
           AND idEntidad = @idEntidad;
    END

    SELECT @folioEmpleadoHorario AS folioEmpleadoHorario;
END
GO


/* =========================================================
   3) ALTA / EDICION BLOQUEO HORARIO EMPLEADO
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_empleadoBloqueoHorario
(
    @folioEmpleadoBloqueoHorario int = 0,
    @folioEmpleado int,
    @fecha datetime,
    @horaInicio datetime,
    @horaFin datetime,
    @idTipoBloqueoHorario int,
    @motivo varchar(450) = NULL,
    @comentarios varchar(450) = NULL,
    @activo bit = 1,
    @idEntidad int,
    @idUsuarioModifica int = NULL,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @horaFin <= @horaInicio
    BEGIN
        RAISERROR('La hora fin del bloqueo debe ser mayor a la hora inicio.',16,1);
        RETURN;
    END

    IF @folioEmpleadoBloqueoHorario = 0
    BEGIN
        INSERT INTO dbo.proc_empleadoBloqueoHorario
        (
            folioEmpleado, fecha, horaInicio, horaFin, idTipoBloqueoHorario, motivo,
            comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
        )
        VALUES
        (
            @folioEmpleado, @fecha, @horaInicio, @horaFin, @idTipoBloqueoHorario, @motivo,
            @comentarios, @activo, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
        );

        SET @folioEmpleadoBloqueoHorario = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.proc_empleadoBloqueoHorario
           SET folioEmpleado = @folioEmpleado,
               fecha = @fecha,
               horaInicio = @horaInicio,
               horaFin = @horaFin,
               idTipoBloqueoHorario = @idTipoBloqueoHorario,
               motivo = @motivo,
               comentarios = @comentarios,
               activo = @activo,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioModifica
         WHERE folioEmpleadoBloqueoHorario = @folioEmpleadoBloqueoHorario
           AND idEntidad = @idEntidad;
    END

    SELECT @folioEmpleadoBloqueoHorario AS folioEmpleadoBloqueoHorario;
END
GO


/* =========================================================
   4) CONSULTA CALENDARIO DE AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_se_agendaCalendario
(
    @fechaInicio datetime,
    @fechaFin datetime,
    @idSucursal int = NULL,
    @folioEmpleado int = NULL,
    @idEntidad int
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.folioAgenda,
        a.folioCliente,
        a.idSucursal,
        a.fechaCita,
        a.horaInicioProgramada,
        a.horaFinProgramada,
        a.idEstatusAgenda,
        ea.descripcion AS estatusAgenda,
        a.confirmada,
        a.totalCotizado,
        a.totalPagado,

        ds.folioAgendaDetalleServicio,
        ds.idProductoServicio,
        ds.descripcionServicio,
        ds.duracionEstimadaMin,
        ds.precioLista,
        ds.precioFinal,
        ds.descuento,
        ds.cantidad,
        ds.ordenServicio,
        ds.horaInicioProgramada AS horaInicioServicio,
        ds.horaFinProgramada AS horaFinServicio,
        ds.horaInicioReal,
        ds.horaFinReal,
        ds.idEstatusAgendaDetalleServicio,
        eds.descripcion AS estatusDetalleServicio,
        ds.cancelado,

        dse.folioAgendaDetalleServicioEmpleado,
        dse.folioEmpleado,
        dse.idRolParticipacionServicio,
        rps.descripcion AS rolParticipacion,
        dse.porcentajeParticipacion,
        dse.comisionCalculada,

        ps.id AS idProductoServicioCatalogo,
        ps.descripcion AS descripcionCatalogo,
        ps.colorCalendario

    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    INNER JOIN dbo.proc_agendaDetalleServicio ds
        ON ds.folioAgenda = a.folioAgenda
       AND ds.idEntidad = a.idEntidad
       AND ISNULL(ds.activo,1) = 1
    INNER JOIN dbo.cat_estatusAgendaDetalleServicio eds
        ON eds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
       AND eds.idEntidad = ds.idEntidad
    LEFT JOIN dbo.proc_agendaDetalleServicioEmpleado dse
        ON dse.folioAgendaDetalleServicio = ds.folioAgendaDetalleServicio
       AND dse.idEntidad = ds.idEntidad
       AND ISNULL(dse.activo,1) = 1
    LEFT JOIN dbo.cat_rolParticipacionServicio rps
        ON rps.idRolParticipacionServicio = dse.idRolParticipacionServicio
       AND rps.idEntidad = dse.idEntidad
    INNER JOIN dbo.cat_productosServicios ps
        ON ps.id = ds.idProductoServicio
       AND ps.idEntidad = ds.idEntidad
    WHERE a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1
      AND a.fechaCita >= @fechaInicio
      AND a.fechaCita < DATEADD(DAY,1,@fechaFin)
      AND (@idSucursal IS NULL OR a.idSucursal = @idSucursal)
      AND (@folioEmpleado IS NULL OR dse.folioEmpleado = @folioEmpleado)
    ORDER BY a.fechaCita, a.horaInicioProgramada, ds.ordenServicio, ds.folioAgendaDetalleServicio;
END
GO


/* =========================================================
   5) DISPONIBILIDAD DE EMPLEADO
   VALIDA HORARIO + BLOQUEOS + EMPALMES
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_se_disponibilidadEmpleado
(
    @folioEmpleado int,
    @fecha datetime,
    @horaInicio datetime,
    @horaFin datetime,
    @idEntidad int,
    @folioAgendaDetalleServicioExcluir int = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @diaSemana int,
            @disponible bit = 1,
            @mensaje varchar(450) = 'Disponible';

    SET @diaSemana = DATEPART(WEEKDAY, @fecha);

    IF @horaFin <= @horaInicio
    BEGIN
        SELECT
            CAST(0 AS bit) AS disponible,
            'La hora fin debe ser mayor a la hora inicio.' AS mensaje;
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoHorario eh
        WHERE eh.folioEmpleado = @folioEmpleado
          AND eh.idEntidad = @idEntidad
          AND eh.diaSemana = @diaSemana
          AND ISNULL(eh.activo,1) = 1
          AND CAST(@horaInicio AS time) >= CAST(eh.horaEntrada AS time)
          AND CAST(@horaFin AS time) <= CAST(eh.horaSalida AS time)
    )
    BEGIN
        SELECT
            CAST(0 AS bit) AS disponible,
            'El horario solicitado está fuera del horario laboral del empleado.' AS mensaje;
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoBloqueoHorario ebh
        WHERE ebh.folioEmpleado = @folioEmpleado
          AND ebh.idEntidad = @idEntidad
          AND ISNULL(ebh.activo,1) = 1
          AND CONVERT(date, ebh.fecha) = CONVERT(date, @fecha)
          AND @horaInicio < ebh.horaFin
          AND @horaFin > ebh.horaInicio
    )
    BEGIN
        SELECT
            CAST(0 AS bit) AS disponible,
            'El empleado tiene un bloqueo de horario en ese rango.' AS mensaje;
        RETURN;
    END

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
        WHERE dse.folioEmpleado = @folioEmpleado
          AND dse.idEntidad = @idEntidad
          AND ISNULL(dse.activo,1) = 1
          AND ISNULL(ds.activo,1) = 1
          AND ISNULL(a.activo,1) = 1
          AND ISNULL(ds.cancelado,0) = 0
          AND CONVERT(date, a.fechaCita) = CONVERT(date, @fecha)
          AND (@folioAgendaDetalleServicioExcluir IS NULL OR ds.folioAgendaDetalleServicio <> @folioAgendaDetalleServicioExcluir)
          AND @horaInicio < ISNULL(ds.horaFinProgramada, a.horaFinProgramada)
          AND @horaFin > ISNULL(ds.horaInicioProgramada, a.horaInicioProgramada)
    )
    BEGIN
        SELECT
            CAST(0 AS bit) AS disponible,
            'El empleado ya tiene un servicio asignado en ese horario.' AS mensaje;
        RETURN;
    END

    SELECT
        CAST(1 AS bit) AS disponible,
        'Disponible' AS mensaje;
END
GO

------------------------

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   1) REPROGRAMACION DE AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaReprogramacion
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

    DECLARE @fechaHoraAnteriorInicio datetime,
            @fechaHoraAnteriorFin datetime,
            @idTipoMovimientoAgenda int;

    SELECT
        @fechaHoraAnteriorInicio = horaInicioProgramada,
        @fechaHoraAnteriorFin = horaFinProgramada
    FROM dbo.proc_agenda
    WHERE folioAgenda = @folioAgenda
      AND idEntidad = @idEntidad
      AND ISNULL(activo,1) = 1;

    IF @fechaHoraAnteriorInicio IS NULL
    BEGIN
        RAISERROR('No existe la agenda indicada.',16,1);
        RETURN;
    END

    IF @fechaHoraNuevaFin <= @fechaHoraNuevaInicio
    BEGIN
        RAISERROR('La nueva hora fin debe ser mayor a la hora inicio.',16,1);
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

    SELECT @idTipoMovimientoAgenda = idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda
    WHERE idEntidad = @idEntidad
      AND clave = 'EDICION'
      AND ISNULL(activo,1) = 1;

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
       AND ISNULL(activo,1) = 1;

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
GO


/* =========================================================
   2) CAMBIO DE ESTATUS DETALLE SERVICIO
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaCambioEstatusDetalleServicio
(
    @folioAgendaDetalleServicio int,
    @idEstatusAgendaDetalleServicioNuevo int,
    @descripcionMovimiento varchar(450) = NULL,
    @comentarios varchar(450) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAnterior int,
            @folioAgenda int,
            @idTipoMovimientoAgenda int,
            @claveNuevo varchar(50);

    SELECT
        @idEstatusAnterior = ds.idEstatusAgendaDetalleServicio,
        @folioAgenda = ds.folioAgenda
    FROM dbo.proc_agendaDetalleServicio ds
    WHERE ds.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
      AND ds.idEntidad = @idEntidad
      AND ISNULL(ds.activo,1) = 1;

    IF @folioAgenda IS NULL
    BEGIN
        RAISERROR('No existe el detalle de servicio indicado.',16,1);
        RETURN;
    END

    SELECT @claveNuevo = clave
    FROM dbo.cat_estatusAgendaDetalleServicio
    WHERE idEstatusAgendaDetalleServicio = @idEstatusAgendaDetalleServicioNuevo
      AND idEntidad = @idEntidad
      AND ISNULL(activo,1) = 1;

    IF @claveNuevo IS NULL
    BEGIN
        RAISERROR('No existe el nuevo estatus del detalle de servicio.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda
    WHERE idEntidad = @idEntidad
      AND clave = 'CAMBIOESTATUS'
      AND ISNULL(activo,1) = 1;

    UPDATE dbo.proc_agendaDetalleServicio
       SET idEstatusAgendaDetalleServicio = @idEstatusAgendaDetalleServicioNuevo,
           cancelado = CASE WHEN @claveNuevo = 'CANCELADO' THEN 1 ELSE cancelado END,
           motivoCancelacion = CASE WHEN @claveNuevo = 'CANCELADO' THEN ISNULL(@descripcionMovimiento,@comentarios) ELSE motivoCancelacion END,
           horaInicioReal = CASE WHEN @claveNuevo = 'ENPROCESO' AND horaInicioReal IS NULL THEN GETDATE() ELSE horaInicioReal END,
           horaFinReal = CASE WHEN @claveNuevo = 'CONCLUIDO' THEN GETDATE() ELSE horaFinReal END,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgendaDetalleServicio = @folioAgendaDetalleServicio
       AND idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda,
        idEstatusAnterior, idEstatusNuevo, descripcionMovimiento,
        datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, @folioAgendaDetalleServicio, @idTipoMovimientoAgenda,
        @idEstatusAnterior, @idEstatusAgendaDetalleServicioNuevo,
        ISNULL(@descripcionMovimiento,'Cambio de estatus de detalle de servicio'),
        NULL, NULL, GETDATE(),
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgendaDetalleServicio AS folioAgendaDetalleServicio;
END
GO


/* =========================================================
   3) HORARIOS DISPONIBLES DE EMPLEADO
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_se_horariosDisponiblesEmpleado
(
    @folioEmpleado int,
    @fecha datetime,
    @duracionMin int,
    @intervaloMin int = 15,
    @idEntidad int,
    @folioAgendaDetalleServicioExcluir int = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @diaSemana int,
            @baseFecha date,
            @horaEntrada time,
            @horaSalida time;

    SET @baseFecha = CONVERT(date, @fecha);
    SET @diaSemana = DATEPART(WEEKDAY, @fecha);

    IF ISNULL(@duracionMin, 0) <= 0
    BEGIN
        RAISERROR('La duración debe ser mayor a 0.',16,1);
        RETURN;
    END

    IF ISNULL(@intervaloMin, 0) <= 0
    BEGIN
        RAISERROR('El intervalo debe ser mayor a 0.',16,1);
        RETURN;
    END

    SELECT TOP 1
        @horaEntrada = CAST(eh.horaEntrada AS time),
        @horaSalida = CAST(eh.horaSalida AS time)
    FROM dbo.proc_empleadoHorario eh
    WHERE eh.folioEmpleado = @folioEmpleado
      AND eh.idEntidad = @idEntidad
      AND eh.diaSemana = @diaSemana
      AND ISNULL(eh.activo,1) = 1
    ORDER BY eh.folioEmpleadoHorario;

    IF @horaEntrada IS NULL OR @horaSalida IS NULL
    BEGIN
        SELECT
            CAST(NULL AS datetime) AS horaInicio,
            CAST(NULL AS datetime) AS horaFin,
            CAST(0 AS bit) AS disponible,
            'El empleado no tiene horario configurado para ese día.' AS mensaje
        WHERE 1 = 0;
        RETURN;
    END

    ;WITH Numeros AS
    (
        SELECT TOP (1440)
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
        FROM sys.all_objects a
        CROSS JOIN sys.all_objects b
    ),
    SlotsBase AS
    (
        SELECT
            @folioEmpleado AS folioEmpleado,
            DATEADD
            (
                MINUTE,
                n.n * @intervaloMin,
                DATEADD(DAY, DATEDIFF(DAY, 0, @baseFecha), CAST(@horaEntrada AS datetime))
            ) AS horaInicio,
            DATEADD
            (
                MINUTE,
                n.n * @intervaloMin + @duracionMin,
                DATEADD(DAY, DATEDIFF(DAY, 0, @baseFecha), CAST(@horaEntrada AS datetime))
            ) AS horaFin,
            DATEADD(DAY, DATEDIFF(DAY, 0, @baseFecha), CAST(@horaSalida AS datetime)) AS limiteFin
        FROM Numeros n
        WHERE DATEADD
              (
                  MINUTE,
                  n.n * @intervaloMin + @duracionMin,
                  DATEADD(DAY, DATEDIFF(DAY, 0, @baseFecha), CAST(@horaEntrada AS datetime))
              ) <= DATEADD(DAY, DATEDIFF(DAY, 0, @baseFecha), CAST(@horaSalida AS datetime))
    ),
    SlotsSinBloqueo AS
    (
        SELECT
            sb.folioEmpleado,
            sb.horaInicio,
            sb.horaFin
        FROM SlotsBase sb
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.proc_empleadoBloqueoHorario ebh
            WHERE ebh.folioEmpleado = sb.folioEmpleado
              AND ebh.idEntidad = @idEntidad
              AND ISNULL(ebh.activo,1) = 1
              AND CONVERT(date, ebh.fecha) = @baseFecha
              AND sb.horaInicio < ebh.horaFin
              AND sb.horaFin > ebh.horaInicio
        )
    ),
    SlotsDisponibles AS
    (
        SELECT
            ssb.folioEmpleado,
            ssb.horaInicio,
            ssb.horaFin
        FROM SlotsSinBloqueo ssb
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.proc_agendaDetalleServicioEmpleado dse
            INNER JOIN dbo.proc_agendaDetalleServicio ds
                ON ds.folioAgendaDetalleServicio = dse.folioAgendaDetalleServicio
               AND ds.idEntidad = dse.idEntidad
            INNER JOIN dbo.proc_agenda a
                ON a.folioAgenda = ds.folioAgenda
               AND a.idEntidad = ds.idEntidad
            WHERE dse.folioEmpleado = ssb.folioEmpleado
              AND dse.idEntidad = @idEntidad
              AND ISNULL(dse.activo,1) = 1
              AND ISNULL(ds.activo,1) = 1
              AND ISNULL(a.activo,1) = 1
              AND ISNULL(ds.cancelado,0) = 0
              AND CONVERT(date, a.fechaCita) = @baseFecha
              AND (@folioAgendaDetalleServicioExcluir IS NULL OR ds.folioAgendaDetalleServicio <> @folioAgendaDetalleServicioExcluir)
              AND ssb.horaInicio < ISNULL(ds.horaFinProgramada, a.horaFinProgramada)
              AND ssb.horaFin > ISNULL(ds.horaInicioProgramada, a.horaInicioProgramada)
        )
    )
    SELECT
        folioEmpleado,
        horaInicio,
        horaFin,
        CAST(1 AS bit) AS disponible,
        'Disponible' AS mensaje
    FROM SlotsDisponibles
    ORDER BY horaInicio;
END
GO


/* =========================================================
   -- HERE! 4) HORARIOS DISPONIBLES PARA UN SERVICIO HERE!
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_se_horariosDisponiblesServicio
(
    @idProductoServicio int,
    @fecha datetime,
    @idEntidad int,
    @folioEmpleado int = NULL,
    @intervaloMin int = 15
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @duracionMin int,
            @diaSemana int,
            @baseFecha date;

    SET @baseFecha = CONVERT(date, @fecha);
    SET @diaSemana = DATEPART(WEEKDAY, @fecha);

    SELECT @duracionMin = ISNULL(ps.duracionBaseMin, 0)
    FROM dbo.cat_productosServicios ps
    WHERE ps.id = @idProductoServicio
      AND ps.idEntidad = @idEntidad
      AND ISNULL(ps.activo, 1) = 1
      AND ISNULL(ps.esServicio, 0) = 1;

    IF ISNULL(@duracionMin, 0) <= 0
    BEGIN
        RAISERROR('El servicio no tiene duración configurada.',16,1);
        RETURN;
    END

    IF ISNULL(@intervaloMin, 0) <= 0
    BEGIN
        RAISERROR('El intervalo debe ser mayor a 0.',16,1);
        RETURN;
    END

    ;WITH EmpleadosConHorario AS
    (
        SELECT
            eh.folioEmpleado,
            CAST(eh.horaEntrada AS time) AS horaEntrada,
            CAST(eh.horaSalida AS time) AS horaSalida
        FROM dbo.proc_empleadoHorario eh
        WHERE eh.idEntidad = @idEntidad
          AND ISNULL(eh.activo,1) = 1
          AND eh.diaSemana = @diaSemana
          AND (@folioEmpleado IS NULL OR eh.folioEmpleado = @folioEmpleado)
    ),
    Numeros AS
    (
        SELECT TOP (1440)
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
        FROM sys.all_objects a
        CROSS JOIN sys.all_objects b
    ),
    SlotsBase AS
    (
        SELECT
            e.folioEmpleado,
            DATEADD
            (
                MINUTE,
                n.n * @intervaloMin,
                DATEADD(DAY, DATEDIFF(DAY, 0, @baseFecha), CAST(e.horaEntrada AS datetime))
            ) AS horaInicio,
            DATEADD
            (
                MINUTE,
                n.n * @intervaloMin + @duracionMin,
                DATEADD(DAY, DATEDIFF(DAY, 0, @baseFecha), CAST(e.horaEntrada AS datetime))
            ) AS horaFin,
            DATEADD(DAY, DATEDIFF(DAY, 0, @baseFecha), CAST(e.horaSalida AS datetime)) AS limiteFin
        FROM EmpleadosConHorario e
        INNER JOIN Numeros n
            ON DATEADD
               (
                   MINUTE,
                   n.n * @intervaloMin + @duracionMin,
                   DATEADD(DAY, DATEDIFF(DAY, 0, @baseFecha), CAST(e.horaEntrada AS datetime))
               ) <= DATEADD(DAY, DATEDIFF(DAY, 0, @baseFecha), CAST(e.horaSalida AS datetime))
    ),
    SlotsSinBloqueo AS
    (
        SELECT
            sb.folioEmpleado,
            sb.horaInicio,
            sb.horaFin
        FROM SlotsBase sb
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.proc_empleadoBloqueoHorario ebh
            WHERE ebh.folioEmpleado = sb.folioEmpleado
              AND ebh.idEntidad = @idEntidad
              AND ISNULL(ebh.activo,1) = 1
              AND CONVERT(date, ebh.fecha) = @baseFecha
              AND sb.horaInicio < ebh.horaFin
              AND sb.horaFin > ebh.horaInicio
        )
    ),
    SlotsDisponibles AS
    (
        SELECT
            ssb.folioEmpleado,
            ssb.horaInicio,
            ssb.horaFin
        FROM SlotsSinBloqueo ssb
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.proc_agendaDetalleServicioEmpleado dse
            INNER JOIN dbo.proc_agendaDetalleServicio ds
                ON ds.folioAgendaDetalleServicio = dse.folioAgendaDetalleServicio
               AND ds.idEntidad = dse.idEntidad
            INNER JOIN dbo.proc_agenda a
                ON a.folioAgenda = ds.folioAgenda
               AND a.idEntidad = ds.idEntidad
            WHERE dse.folioEmpleado = ssb.folioEmpleado
              AND dse.idEntidad = @idEntidad
              AND ISNULL(dse.activo,1) = 1
              AND ISNULL(ds.activo,1) = 1
              AND ISNULL(a.activo,1) = 1
              AND ISNULL(ds.cancelado,0) = 0
              AND CONVERT(date, a.fechaCita) = @baseFecha
              AND ssb.horaInicio < ISNULL(ds.horaFinProgramada, a.horaFinProgramada)
              AND ssb.horaFin > ISNULL(ds.horaInicioProgramada, a.horaInicioProgramada)
        )
    )
    SELECT
        folioEmpleado,
        horaInicio,
        horaFin,
        CAST(1 AS bit) AS disponible,
        'Disponible' AS mensaje
    FROM SlotsDisponibles
    ORDER BY horaInicio, folioEmpleado;
END
GO

-- -------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   1) CONFIRMAR AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_confirmarAgenda
(
    @folioAgenda int,
    @comentarios varchar(450) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAnterior int,
            @idEstatusNuevo int,
            @idTipoMovimientoAgenda int;

    SELECT @idEstatusAnterior = a.idEstatusAgenda
    FROM dbo.proc_agenda a
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF ISNULL(@idEstatusAnterior,0) = 0
    BEGIN
        RAISERROR('No existe la agenda indicada.',16,1);
        RETURN;
    END

    SELECT @idEstatusNuevo = cea.idEstatusAgenda
    FROM dbo.cat_estatusAgenda cea
    WHERE cea.idEntidad = @idEntidad
      AND cea.clave = 'CONFIRMADA'
      AND ISNULL(cea.activo,1) = 1;

    IF ISNULL(@idEstatusNuevo,0) = 0
    BEGIN
        RAISERROR('No existe el estatus CONFIRMADA.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = ctm.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda ctm
    WHERE ctm.idEntidad = @idEntidad
      AND ctm.clave = 'CAMBIOESTATUS'
      AND ISNULL(ctm.activo,1) = 1;

    UPDATE dbo.proc_agenda
       SET confirmada = 1,
           fechaConfirmacion = GETDATE(),
           idEstatusAgenda = @idEstatusNuevo,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgenda = @folioAgenda
       AND idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda,
        idEstatusAnterior, idEstatusNuevo, descripcionMovimiento,
        datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion,
        idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, NULL, @idTipoMovimientoAgenda,
        @idEstatusAnterior, @idEstatusNuevo, 'Confirmación de agenda',
        NULL, NULL, GETDATE(),
        @comentarios, 1, @idEntidad, NULL,
        NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgenda AS folioAgenda;
END
GO


/* =========================================================
   2) CANCELAR AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_cancelarAgenda
(
    @folioAgenda int,
    @motivoCancelacion varchar(450),
    @cancelarDetalles bit = 1,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAnterior int,
            @idEstatusNuevo int,
            @idTipoMovimientoAgenda int,
            @idEstatusDetalleCancelado int;

    SELECT @idEstatusAnterior = a.idEstatusAgenda
    FROM dbo.proc_agenda a
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF ISNULL(@idEstatusAnterior,0) = 0
    BEGIN
        RAISERROR('No existe la agenda indicada.',16,1);
        RETURN;
    END

    SELECT @idEstatusNuevo = cea.idEstatusAgenda
    FROM dbo.cat_estatusAgenda cea
    WHERE cea.idEntidad = @idEntidad
      AND cea.clave = 'CANCELADA'
      AND ISNULL(cea.activo,1) = 1;

    IF ISNULL(@idEstatusNuevo,0) = 0
    BEGIN
        RAISERROR('No existe el estatus CANCELADA.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = ctm.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda ctm
    WHERE ctm.idEntidad = @idEntidad
      AND ctm.clave = 'CAMBIOESTATUS'
      AND ISNULL(ctm.activo,1) = 1;

    SELECT @idEstatusDetalleCancelado = ceds.idEstatusAgendaDetalleServicio
    FROM dbo.cat_estatusAgendaDetalleServicio ceds
    WHERE ceds.idEntidad = @idEntidad
      AND ceds.clave = 'CANCELADO'
      AND ISNULL(ceds.activo,1) = 1;

    UPDATE dbo.proc_agenda
       SET idEstatusAgenda = @idEstatusNuevo,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgenda = @folioAgenda
       AND idEntidad = @idEntidad;

    IF @cancelarDetalles = 1 AND ISNULL(@idEstatusDetalleCancelado,0) > 0
    BEGIN
        UPDATE dbo.proc_agendaDetalleServicio
           SET idEstatusAgendaDetalleServicio = @idEstatusDetalleCancelado,
               cancelado = 1,
               motivoCancelacion = @motivoCancelacion,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioAlta
         WHERE folioAgenda = @folioAgenda
           AND idEntidad = @idEntidad
           AND ISNULL(activo,1) = 1
           AND ISNULL(cancelado,0) = 0;
    END

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda,
        idEstatusAnterior, idEstatusNuevo, descripcionMovimiento,
        datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion,
        idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, NULL, @idTipoMovimientoAgenda,
        @idEstatusAnterior, @idEstatusNuevo, 'Cancelación de agenda',
        NULL, NULL, GETDATE(),
        @motivoCancelacion, 1, @idEntidad, NULL,
        NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgenda AS folioAgenda;
END
GO


/* =========================================================
   3) CANCELAR DETALLE DE SERVICIO
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_cancelarDetalleServicio
(
    @folioAgendaDetalleServicio int,
    @motivoCancelacion varchar(450),
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @folioAgenda int,
            @idEstatusAnterior int,
            @idEstatusNuevo int,
            @idTipoMovimientoAgenda int;

    SELECT
        @folioAgenda = ds.folioAgenda,
        @idEstatusAnterior = ds.idEstatusAgendaDetalleServicio
    FROM dbo.proc_agendaDetalleServicio ds
    WHERE ds.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
      AND ds.idEntidad = @idEntidad
      AND ISNULL(ds.activo,1) = 1;

    IF ISNULL(@folioAgenda,0) = 0
    BEGIN
        RAISERROR('No existe el detalle de servicio indicado.',16,1);
        RETURN;
    END

    SELECT @idEstatusNuevo = ceds.idEstatusAgendaDetalleServicio
    FROM dbo.cat_estatusAgendaDetalleServicio ceds
    WHERE ceds.idEntidad = @idEntidad
      AND ceds.clave = 'CANCELADO'
      AND ISNULL(ceds.activo,1) = 1;

    IF ISNULL(@idEstatusNuevo,0) = 0
    BEGIN
        RAISERROR('No existe el estatus CANCELADO para detalle.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = ctm.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda ctm
    WHERE ctm.idEntidad = @idEntidad
      AND ctm.clave = 'CAMBIOESTATUS'
      AND ISNULL(ctm.activo,1) = 1;

    UPDATE dbo.proc_agendaDetalleServicio
       SET idEstatusAgendaDetalleServicio = @idEstatusNuevo,
           cancelado = 1,
           motivoCancelacion = @motivoCancelacion,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgendaDetalleServicio = @folioAgendaDetalleServicio
       AND idEntidad = @idEntidad;

    UPDATE a
       SET totalCotizado = ISNULL((
            SELECT SUM(ISNULL(ds.precioFinal,0) * ISNULL(ds.cantidad,1))
            FROM dbo.proc_agendaDetalleServicio ds
            WHERE ds.folioAgenda = a.folioAgenda
              AND ds.idEntidad = a.idEntidad
              AND ISNULL(ds.activo,1) = 1
              AND ISNULL(ds.cancelado,0) = 0
        ),0),
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
    FROM dbo.proc_agenda a
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda,
        idEstatusAnterior, idEstatusNuevo, descripcionMovimiento,
        datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion,
        idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, @folioAgendaDetalleServicio, @idTipoMovimientoAgenda,
        @idEstatusAnterior, @idEstatusNuevo, 'Cancelación de detalle de servicio',
        NULL, NULL, GETDATE(),
        @motivoCancelacion, 1, @idEntidad, NULL,
        NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgendaDetalleServicio AS folioAgendaDetalleServicio;
END
GO


/* =========================================================
   4) DETALLE COMPLETO DE AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_se_agendaDetalleCompleto
(
    @folioAgenda int,
    @idEntidad int
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.folioAgenda,
        a.folioCliente,
        a.idSucursal,
        a.fechaCita,
        a.horaInicioProgramada,
        a.horaFinProgramada,
        a.idEstatusAgenda,
        ea.descripcion AS estatusAgenda,
        a.idOrigenAgenda,
        oa.descripcion AS origenAgenda,
        a.confirmada,
        a.fechaConfirmacion,
        a.folioVenta,
        a.totalCotizado,
        a.totalPagado,
        a.requiereConfirmacion,
        a.observacionesInternas,
        a.comentarios
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    INNER JOIN dbo.cat_origenAgenda oa
        ON oa.idOrigenAgenda = a.idOrigenAgenda
       AND oa.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    SELECT
        ds.folioAgendaDetalleServicio,
        ds.folioAgenda,
        ds.idProductoServicio,
        ds.descripcionServicio,
        ds.duracionEstimadaMin,
        ds.precioLista,
        ds.precioFinal,
        ds.descuento,
        ds.cantidad,
        ds.ordenServicio,
        ds.horaInicioProgramada,
        ds.horaFinProgramada,
        ds.horaInicioReal,
        ds.horaFinReal,
        ds.idEstatusAgendaDetalleServicio,
        ceds.descripcion AS estatusDetalleServicio,
        ds.cancelado,
        ds.motivoCancelacion,
        ps.colorCalendario
    FROM dbo.proc_agendaDetalleServicio ds
    INNER JOIN dbo.cat_estatusAgendaDetalleServicio ceds
        ON ceds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
       AND ceds.idEntidad = ds.idEntidad
    LEFT JOIN dbo.cat_productosServicios ps
        ON ps.id = ds.idProductoServicio
       AND ps.idEntidad = ds.idEntidad
    WHERE ds.folioAgenda = @folioAgenda
      AND ds.idEntidad = @idEntidad
      AND ISNULL(ds.activo,1) = 1
    ORDER BY ds.ordenServicio, ds.folioAgendaDetalleServicio;

    SELECT
        dse.folioAgendaDetalleServicioEmpleado,
        dse.folioAgendaDetalleServicio,
        dse.folioEmpleado,
        dse.idRolParticipacionServicio,
        crps.descripcion AS rolParticipacion,
        dse.porcentajeParticipacion,
        dse.comisionCalculada,
        dse.horaInicioReal,
        dse.horaFinReal,
        dse.comentarios
    FROM dbo.proc_agendaDetalleServicioEmpleado dse
    INNER JOIN dbo.proc_agendaDetalleServicio ds
        ON ds.folioAgendaDetalleServicio = dse.folioAgendaDetalleServicio
       AND ds.idEntidad = dse.idEntidad
    INNER JOIN dbo.cat_rolParticipacionServicio crps
        ON crps.idRolParticipacionServicio = dse.idRolParticipacionServicio
       AND crps.idEntidad = dse.idEntidad
    WHERE ds.folioAgenda = @folioAgenda
      AND dse.idEntidad = @idEntidad
      AND ISNULL(dse.activo,1) = 1
    ORDER BY dse.folioAgendaDetalleServicio, dse.folioAgendaDetalleServicioEmpleado;

    SELECT
        ap.folioAgendaPago,
        ap.folioAgenda,
        ap.idTipoMovimientoPagoAgenda,
        ctpa.descripcion AS tipoMovimientoPago,
        ap.idEstatusPagoAgenda,
        cepa.descripcion AS estatusPago,
        ap.montoTotal,
        ap.fechaPago,
        ap.referenciaExterna,
        ap.comentarios
    FROM dbo.proc_agendaPago ap
    INNER JOIN dbo.cat_tipoMovimientoPagoAgenda ctpa
        ON ctpa.idTipoMovimientoPagoAgenda = ap.idTipoMovimientoPagoAgenda
       AND ctpa.idEntidad = ap.idEntidad
    INNER JOIN dbo.cat_estatusPagoAgenda cepa
        ON cepa.idEstatusPagoAgenda = ap.idEstatusPagoAgenda
       AND cepa.idEntidad = ap.idEntidad
    WHERE ap.folioAgenda = @folioAgenda
      AND ap.idEntidad = @idEntidad
      AND ISNULL(ap.activo,1) = 1
    ORDER BY ap.fechaPago, ap.folioAgendaPago;

    SELECT
        apd.folioAgendaPagoDetalle,
        apd.folioAgendaPago,
        apd.idTipoPago,
        apd.montoPago,
        apd.numeroAutorizacion,
        apd.referenciaOperacion,
        apd.comentarios
    FROM dbo.proc_agendaPagoDetalle apd
    INNER JOIN dbo.proc_agendaPago ap
        ON ap.folioAgendaPago = apd.folioAgendaPago
       AND ap.idEntidad = apd.idEntidad
    WHERE ap.folioAgenda = @folioAgenda
      AND apd.idEntidad = @idEntidad
      AND ISNULL(apd.activo,1) = 1
    ORDER BY apd.folioAgendaPago, apd.folioAgendaPagoDetalle;

    SELECT
        ab.folioAgendaBitacora,
        ab.folioAgenda,
        ab.folioAgendaDetalleServicio,
        ab.idTipoMovimientoAgenda,
        ctma.descripcion AS tipoMovimiento,
        ab.idEstatusAnterior,
        ab.idEstatusNuevo,
        ab.descripcionMovimiento,
        ab.datosAntes,
        ab.datosDespues,
        ab.fechaMovimiento,
        ab.comentarios,
        ab.idUsuarioAlta
    FROM dbo.proc_agendaBitacora ab
    INNER JOIN dbo.cat_tipoMovimientoAgenda ctma
        ON ctma.idTipoMovimientoAgenda = ab.idTipoMovimientoAgenda
       AND ctma.idEntidad = ab.idEntidad
    WHERE ab.folioAgenda = @folioAgenda
      AND ab.idEntidad = @idEntidad
      AND ISNULL(ab.activo,1) = 1
    ORDER BY ab.fechaMovimiento, ab.folioAgendaBitacora;
END
GO

--- ----------------------
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaReprogramacion
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

    DECLARE @fechaHoraAnteriorInicio datetime,
            @fechaHoraAnteriorFin datetime,
            @idTipoMovimientoAgenda int;

    SELECT
        @fechaHoraAnteriorInicio = horaInicioProgramada,
        @fechaHoraAnteriorFin = horaFinProgramada
    FROM dbo.proc_agenda
    WHERE folioAgenda = @folioAgenda
      AND idEntidad = @idEntidad
      AND ISNULL(activo,1) = 1;

    IF @fechaHoraAnteriorInicio IS NULL
    BEGIN
        RAISERROR('No existe la agenda indicada.',16,1);
        RETURN;
    END

    IF @fechaHoraNuevaFin <= @fechaHoraNuevaInicio
    BEGIN
        RAISERROR('La nueva hora fin debe ser mayor a la hora inicio.',16,1);
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

    /* Validar empalmes de empleados asignados */
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
          AND ISNULL(dseActual.activo,1) = 1
          AND EXISTS
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
                AND ds.folioAgenda <> @folioAgenda
                AND ISNULL(ds.cancelado,0) = 0
                AND @fechaHoraNuevaInicio < ISNULL(ds.horaFinProgramada, a.horaFinProgramada)
                AND @fechaHoraNuevaFin > ISNULL(ds.horaInicioProgramada, a.horaInicioProgramada)
          )
    )
    BEGIN
        RAISERROR('La nueva fecha/hora genera empalme para uno o más empleados asignados.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = ctm.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda ctm
    WHERE ctm.idEntidad = @idEntidad
      AND ctm.clave = 'EDICION'
      AND ISNULL(ctm.activo,1) = 1;

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
       AND ISNULL(activo,1) = 1;

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
GO

-- ========================================================================================================================================================================================================
-- ======================================================================================================================================================================================================== 
-- ========================================================================================================================================================================================================
-- MEJORAS A SP EXISTENES. VALIDACIONES ETC
-- ========================================================================================================================================================================================================
-- ========================================================================================================================================================================================================
-- ========================================================================================================================================================================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   1) AGENDA - ALTA / EDICION CON VALIDACIONES
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agenda
(
    @folioAgenda int = 0,
    @folioCliente int,
    @idSucursal int,
    @fechaCita datetime,
    @horaInicioProgramada datetime,
    @horaFinProgramada datetime,
    @idOrigenAgenda int,
    @requiereConfirmacion bit = 0,
    @observacionesInternas varchar(450) = NULL,
    @comentarios varchar(450) = NULL,
    @activo bit = 1,
    @idEntidad int,
    @idUsuarioModifica int = NULL,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAgenda int,
            @idTipoMovimientoAlta int,
            @idTipoMovimientoEdicion int,
            @idTipoPersonaCliente int,
            @idEstatusActual int,
            @claveEstatusActual varchar(50);

    IF ISNULL(@folioCliente,0) <= 0
    BEGIN
        RAISERROR('El cliente es obligatorio.',16,1);
        RETURN;
    END

    IF ISNULL(@idSucursal,0) <= 0
    BEGIN
        RAISERROR('La sucursal es obligatoria.',16,1);
        RETURN;
    END

    IF ISNULL(@idOrigenAgenda,0) <= 0
    BEGIN
        RAISERROR('El origen de la agenda es obligatorio.',16,1);
        RETURN;
    END

    IF @horaFinProgramada <= @horaInicioProgramada
    BEGIN
        RAISERROR('La hora fin programada debe ser mayor a la hora inicio programada.',16,1);
        RETURN;
    END

    SELECT @idTipoPersonaCliente = tp.id
    FROM dbo.cat_tiposPersonas tp
    WHERE tp.idEntidad = @idEntidad
      AND tp.descripcion = 'Cliente'
      AND ISNULL(tp.activo,1) = 1;

    IF ISNULL(@idTipoPersonaCliente,0) = 0
    BEGIN
        RAISERROR('No existe el tipo de persona Cliente.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_personas p
        WHERE p.id = @folioCliente
          AND p.idEntidad = @idEntidad
          AND p.idTipoPersona = @idTipoPersonaCliente
          AND ISNULL(p.activo,1) = 1
    )
    BEGIN
        RAISERROR('El cliente no existe, no pertenece a la entidad o no está activo.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_sucursales s
        WHERE s.idSucursal = @idSucursal
          AND s.idEntidad = @idEntidad
          AND ISNULL(s.activo,1) = 1
    )
    BEGIN
        RAISERROR('La sucursal no existe o no está activa.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_origenAgenda oa
        WHERE oa.idOrigenAgenda = @idOrigenAgenda
          AND oa.idEntidad = @idEntidad
          AND ISNULL(oa.activo,1) = 1
    )
    BEGIN
        RAISERROR('El origen de agenda no existe o no está activo.',16,1);
        RETURN;
    END

    SELECT @idEstatusAgenda = ea.idEstatusAgenda
    FROM dbo.cat_estatusAgenda ea
    WHERE ea.idEntidad = @idEntidad
      AND ea.clave = 'REGISTRADA'
      AND ISNULL(ea.activo,1) = 1;

    IF ISNULL(@idEstatusAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el estatus REGISTRADA para la agenda.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAlta = tma.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda tma
    WHERE tma.idEntidad = @idEntidad
      AND tma.clave = 'ALTA'
      AND ISNULL(tma.activo,1) = 1;

    SELECT @idTipoMovimientoEdicion = tma.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda tma
    WHERE tma.idEntidad = @idEntidad
      AND tma.clave = 'EDICION'
      AND ISNULL(tma.activo,1) = 1;

    IF @folioAgenda = 0
    BEGIN
        INSERT INTO dbo.proc_agenda
        (
            folioCliente, idSucursal, fechaCita, horaInicioProgramada, horaFinProgramada,
            idEstatusAgenda, idOrigenAgenda, confirmada, fechaConfirmacion, folioVenta,
            totalCotizado, totalPagado, requiereConfirmacion, observacionesInternas,
            comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
        )
        VALUES
        (
            @folioCliente, @idSucursal, @fechaCita, @horaInicioProgramada, @horaFinProgramada,
            @idEstatusAgenda, @idOrigenAgenda, 0, NULL, NULL,
            0, 0, @requiereConfirmacion, @observacionesInternas,
            @comentarios, @activo, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
        );

        SET @folioAgenda = SCOPE_IDENTITY();

        IF ISNULL(@idTipoMovimientoAlta,0) > 0
        BEGIN
            INSERT INTO dbo.proc_agendaBitacora
            (
                folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda, idEstatusAnterior, idEstatusNuevo,
                descripcionMovimiento, datosAntes, datosDespues, fechaMovimiento,
                comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
            )
            VALUES
            (
                @folioAgenda, NULL, @idTipoMovimientoAlta, NULL, @idEstatusAgenda,
                'Alta de agenda', NULL, NULL, GETDATE(),
                NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
            );
        END
    END
    ELSE
    BEGIN
        SELECT
            @idEstatusActual = a.idEstatusAgenda,
            @claveEstatusActual = ea.clave
        FROM dbo.proc_agenda a
        INNER JOIN dbo.cat_estatusAgenda ea
            ON ea.idEstatusAgenda = a.idEstatusAgenda
           AND ea.idEntidad = a.idEntidad
        WHERE a.folioAgenda = @folioAgenda
          AND a.idEntidad = @idEntidad
          AND ISNULL(a.activo,1) = 1;

        IF ISNULL(@idEstatusActual,0) = 0
        BEGIN
            RAISERROR('La agenda no existe o no está activa.',16,1);
            RETURN;
        END

        IF @claveEstatusActual IN ('CANCELADA','CONCLUIDA')
        BEGIN
            RAISERROR('No se puede editar una agenda cancelada o concluida.',16,1);
            RETURN;
        END

        UPDATE dbo.proc_agenda
           SET folioCliente = @folioCliente,
               idSucursal = @idSucursal,
               fechaCita = @fechaCita,
               horaInicioProgramada = @horaInicioProgramada,
               horaFinProgramada = @horaFinProgramada,
               idOrigenAgenda = @idOrigenAgenda,
               requiereConfirmacion = @requiereConfirmacion,
               observacionesInternas = @observacionesInternas,
               comentarios = @comentarios,
               activo = @activo,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioModifica
         WHERE folioAgenda = @folioAgenda
           AND idEntidad = @idEntidad;

        IF ISNULL(@idTipoMovimientoEdicion,0) > 0
        BEGIN
            INSERT INTO dbo.proc_agendaBitacora
            (
                folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda, idEstatusAnterior, idEstatusNuevo,
                descripcionMovimiento, datosAntes, datosDespues, fechaMovimiento,
                comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
            )
            VALUES
            (
                @folioAgenda, NULL, @idTipoMovimientoEdicion, NULL, NULL,
                'Edición de agenda', NULL, NULL, GETDATE(),
                NULL, 1, @idEntidad, NULL, NULL, GETDATE(), ISNULL(@idUsuarioModifica,@idUsuarioAlta)
            );
        END
    END

    SELECT @folioAgenda AS folioAgenda;
END
GO


/* =========================================================
   2) DETALLE SERVICIO - ALTA / EDICION CON VALIDACIONES
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaDetalleServicio
(
    @folioAgendaDetalleServicio int = 0,
    @folioAgenda int,
    @idProductoServicio int,
    @precioFinal decimal(16,4),
    @descuento decimal(16,4) = NULL,
    @cantidad decimal(16,4) = 1,
    @ordenServicio int = 1,
    @horaInicioProgramada datetime = NULL,
    @horaFinProgramada datetime = NULL,
    @comentarios varchar(450) = NULL,
    @activo bit = 1,
    @idEntidad int,
    @idUsuarioModifica int = NULL,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @descripcionServicio varchar(250),
            @duracionEstimadaMin int,
            @precioLista decimal(16,4),
            @idEstatusAgendaDetalleServicio int,
            @idEstatusAgenda int,
            @claveEstatusAgenda varchar(50);

    IF ISNULL(@folioAgenda,0) <= 0
    BEGIN
        RAISERROR('La agenda es obligatoria.',16,1);
        RETURN;
    END

    IF ISNULL(@idProductoServicio,0) <= 0
    BEGIN
        RAISERROR('El producto/servicio es obligatorio.',16,1);
        RETURN;
    END

    IF ISNULL(@cantidad,0) <= 0
    BEGIN
        RAISERROR('La cantidad debe ser mayor a 0.',16,1);
        RETURN;
    END

    IF ISNULL(@precioFinal,0) < 0
    BEGIN
        RAISERROR('El precio final no puede ser menor a 0.',16,1);
        RETURN;
    END

    IF @horaInicioProgramada IS NOT NULL
       AND @horaFinProgramada IS NOT NULL
       AND @horaFinProgramada <= @horaInicioProgramada
    BEGIN
        RAISERROR('La hora fin programada debe ser mayor a la hora inicio programada.',16,1);
        RETURN;
    END

    SELECT
        @idEstatusAgenda = a.idEstatusAgenda,
        @claveEstatusAgenda = ea.clave
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF ISNULL(@idEstatusAgenda,0) = 0
    BEGIN
        RAISERROR('La agenda no existe o no está activa.',16,1);
        RETURN;
    END

    IF @claveEstatusAgenda IN ('CANCELADA','CONCLUIDA')
    BEGIN
        RAISERROR('No se pueden agregar o editar servicios en una agenda cancelada o concluida.',16,1);
        RETURN;
    END

    SELECT
        @descripcionServicio = ps.descripcion,
        @duracionEstimadaMin = ISNULL(ps.duracionBaseMin,0),
        @precioLista = ISNULL(precio.precioPrimera,0)
    FROM dbo.cat_productosServicios ps
    INNER JOIN dbo.cat_precios precio
        ON precio.idProductoServicio = ps.id
       AND precio.idEntidad = ps.idEntidad
    WHERE ps.id = @idProductoServicio
      AND ps.idEntidad = @idEntidad
      AND ISNULL(ps.activo,1) = 1
      AND ISNULL(ps.esServicio,0) = 1;

    IF @descripcionServicio IS NULL
    BEGIN
        RAISERROR('El producto/servicio indicado no existe o no está marcado como servicio.',16,1);
        RETURN;
    END

    IF ISNULL(@duracionEstimadaMin,0) <= 0
    BEGIN
        RAISERROR('El servicio no tiene duración válida.',16,1);
        RETURN;
    END

    SELECT @idEstatusAgendaDetalleServicio = idEstatusAgendaDetalleServicio
    FROM dbo.cat_estatusAgendaDetalleServicio
    WHERE idEntidad = @idEntidad
      AND clave = 'PENDIENTE'
      AND ISNULL(activo,1) = 1;

    IF ISNULL(@idEstatusAgendaDetalleServicio,0) = 0
    BEGIN
        RAISERROR('No se encontró el estatus PENDIENTE para detalle de servicio.',16,1);
        RETURN;
    END

    IF @folioAgendaDetalleServicio = 0
    BEGIN
        INSERT INTO dbo.proc_agendaDetalleServicio
        (
            folioAgenda, idProductoServicio, descripcionServicio, duracionEstimadaMin,
            precioLista, precioFinal, descuento, cantidad, ordenServicio,
            horaInicioProgramada, horaFinProgramada, horaInicioReal, horaFinReal,
            idEstatusAgendaDetalleServicio, cancelado, motivoCancelacion,
            comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
        )
        VALUES
        (
            @folioAgenda, @idProductoServicio, @descripcionServicio, @duracionEstimadaMin,
            @precioLista, @precioFinal, @descuento, @cantidad, @ordenServicio,
            @horaInicioProgramada, @horaFinProgramada, NULL, NULL,
            @idEstatusAgendaDetalleServicio, 0, NULL,
            @comentarios, @activo, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
        );

        SET @folioAgendaDetalleServicio = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        DECLARE @claveEstatusDetalleActual varchar(50);

        SELECT @claveEstatusDetalleActual = ceds.clave
        FROM dbo.proc_agendaDetalleServicio ds
        INNER JOIN dbo.cat_estatusAgendaDetalleServicio ceds
            ON ceds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
           AND ceds.idEntidad = ds.idEntidad
        WHERE ds.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
          AND ds.idEntidad = @idEntidad
          AND ISNULL(ds.activo,1) = 1;

        IF @claveEstatusDetalleActual IS NULL
        BEGIN
            RAISERROR('El detalle de servicio no existe o no está activo.',16,1);
            RETURN;
        END

        IF @claveEstatusDetalleActual IN ('CANCELADO','CONCLUIDO')
        BEGIN
            RAISERROR('No se puede editar un detalle de servicio cancelado o concluido.',16,1);
            RETURN;
        END

        UPDATE dbo.proc_agendaDetalleServicio
           SET precioFinal = @precioFinal,
               descuento = @descuento,
               cantidad = @cantidad,
               ordenServicio = @ordenServicio,
               horaInicioProgramada = @horaInicioProgramada,
               horaFinProgramada = @horaFinProgramada,
               comentarios = @comentarios,
               activo = @activo,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioModifica
         WHERE folioAgendaDetalleServicio = @folioAgendaDetalleServicio
           AND idEntidad = @idEntidad;
    END

    UPDATE a
       SET totalCotizado = ISNULL((
            SELECT SUM(ISNULL(ds.precioFinal,0) * ISNULL(ds.cantidad,1))
            FROM dbo.proc_agendaDetalleServicio ds
            WHERE ds.folioAgenda = a.folioAgenda
              AND ds.idEntidad = a.idEntidad
              AND ISNULL(ds.activo,1) = 1
              AND ISNULL(ds.cancelado,0) = 0
        ),0),
           fechaModificacion = GETDATE(),
           idUsuarioModifica = ISNULL(@idUsuarioModifica,@idUsuarioAlta)
    FROM dbo.proc_agenda a
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad;

    SELECT @folioAgendaDetalleServicio AS folioAgendaDetalleServicio;
END
GO


/* =========================================================
   3) ASIGNACION EMPLEADO A DETALLE - CON VALIDACIONES
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaDetalleServicioEmpleado
(
    @folioAgendaDetalleServicioEmpleado int = 0,
    @folioAgendaDetalleServicio int,
    @folioEmpleado int,
    @idRolParticipacionServicio int,
    @porcentajeParticipacion decimal(16,4) = NULL,
    @comisionCalculada decimal(16,4) = NULL,
    @horaInicioReal datetime = NULL,
    @horaFinReal datetime = NULL,
    @comentarios varchar(450) = NULL,
    @activo bit = 1,
    @idEntidad int,
    @idUsuarioModifica int = NULL,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @folioAgenda int,
            @horaInicioProgramada datetime,
            @horaFinProgramada datetime,
            @fechaCita datetime,
            @horaInicioAgenda datetime,
            @horaFinAgenda datetime,
            @idEstatusAgenda int,
            @claveEstatusAgenda varchar(50),
            @idEstatusDetalle int,
            @claveEstatusDetalle varchar(50),
            @idTipoPersonaEmpleado int,
            @sumaPorcentajeActual decimal(16,4);

    IF ISNULL(@folioAgendaDetalleServicio,0) <= 0
    BEGIN
        RAISERROR('El detalle de servicio es obligatorio.',16,1);
        RETURN;
    END

    IF ISNULL(@folioEmpleado,0) <= 0
    BEGIN
        RAISERROR('El empleado es obligatorio.',16,1);
        RETURN;
    END

    IF ISNULL(@idRolParticipacionServicio,0) <= 0
    BEGIN
        RAISERROR('El rol de participación es obligatorio.',16,1);
        RETURN;
    END

    IF @porcentajeParticipacion IS NOT NULL
       AND (@porcentajeParticipacion < 0 OR @porcentajeParticipacion > 100)
    BEGIN
        RAISERROR('El porcentaje de participación debe estar entre 0 y 100.',16,1);
        RETURN;
    END

    IF @horaInicioReal IS NOT NULL
       AND @horaFinReal IS NOT NULL
       AND @horaFinReal <= @horaInicioReal
    BEGIN
        RAISERROR('La hora fin real debe ser mayor a la hora inicio real.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_rolParticipacionServicio rps
        WHERE rps.idRolParticipacionServicio = @idRolParticipacionServicio
          AND rps.idEntidad = @idEntidad
          AND ISNULL(rps.activo,1) = 1
    )
    BEGIN
        RAISERROR('El rol de participación no existe o no está activo.',16,1);
        RETURN;
    END

    SELECT @idTipoPersonaEmpleado = tp.id
    FROM dbo.cat_tiposPersonas tp
    WHERE tp.idEntidad = @idEntidad
      AND tp.descripcion = 'Empleado'
      AND ISNULL(tp.activo,1) = 1;

    IF ISNULL(@idTipoPersonaEmpleado,0) = 0
    BEGIN
        RAISERROR('No existe el tipo de persona Empleado.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_personas p
        WHERE p.id = @folioEmpleado
          AND p.idEntidad = @idEntidad
          AND p.idTipoPersona = @idTipoPersonaEmpleado
          AND ISNULL(p.activo,1) = 1
    )
    BEGIN
        RAISERROR('El empleado no existe, no pertenece a la entidad o no está activo.',16,1);
        RETURN;
    END

    SELECT
        @folioAgenda = ds.folioAgenda,
        @horaInicioProgramada = ds.horaInicioProgramada,
        @horaFinProgramada = ds.horaFinProgramada,
        @idEstatusDetalle = ds.idEstatusAgendaDetalleServicio,
        @claveEstatusDetalle = ceds.clave
    FROM dbo.proc_agendaDetalleServicio ds
    INNER JOIN dbo.cat_estatusAgendaDetalleServicio ceds
        ON ceds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
       AND ceds.idEntidad = ds.idEntidad
    WHERE ds.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
      AND ds.idEntidad = @idEntidad
      AND ISNULL(ds.activo,1) = 1;

    IF ISNULL(@folioAgenda,0) = 0
    BEGIN
        RAISERROR('No existe el detalle de servicio indicado.',16,1);
        RETURN;
    END

    IF @claveEstatusDetalle IN ('CANCELADO','CONCLUIDO')
    BEGIN
        RAISERROR('No se puede asignar o editar empleado en un detalle cancelado o concluido.',16,1);
        RETURN;
    END

    SELECT
        @idEstatusAgenda = a.idEstatusAgenda,
        @claveEstatusAgenda = ea.clave,
        @fechaCita = a.fechaCita,
        @horaInicioAgenda = a.horaInicioProgramada,
        @horaFinAgenda = a.horaFinProgramada
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF ISNULL(@idEstatusAgenda,0) = 0
    BEGIN
        RAISERROR('La agenda asociada no existe o no está activa.',16,1);
        RETURN;
    END

    IF @claveEstatusAgenda IN ('CANCELADA','CONCLUIDA')
    BEGIN
        RAISERROR('No se puede asignar o editar empleado en una agenda cancelada o concluida.',16,1);
        RETURN;
    END

    SET @horaInicioProgramada = ISNULL(@horaInicioProgramada, @horaInicioAgenda);
    SET @horaFinProgramada = ISNULL(@horaFinProgramada, @horaFinAgenda);

    IF @horaInicioProgramada IS NULL OR @horaFinProgramada IS NULL OR @horaFinProgramada <= @horaInicioProgramada
    BEGIN
        RAISERROR('El detalle o la agenda no tienen un rango horario válido.',16,1);
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.proc_agendaDetalleServicioEmpleado dse
        WHERE dse.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
          AND dse.folioEmpleado = @folioEmpleado
          AND dse.idEntidad = @idEntidad
          AND ISNULL(dse.activo,1) = 1
          AND (@folioAgendaDetalleServicioEmpleado = 0 OR dse.folioAgendaDetalleServicioEmpleado <> @folioAgendaDetalleServicioEmpleado)
    )
    BEGIN
        RAISERROR('El empleado ya está asignado a este detalle de servicio.',16,1);
        RETURN;
    END

    SELECT @sumaPorcentajeActual = ISNULL(SUM(ISNULL(dse.porcentajeParticipacion,0)),0)
    FROM dbo.proc_agendaDetalleServicioEmpleado dse
    WHERE dse.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
      AND dse.idEntidad = @idEntidad
      AND ISNULL(dse.activo,1) = 1
      AND (@folioAgendaDetalleServicioEmpleado = 0 OR dse.folioAgendaDetalleServicioEmpleado <> @folioAgendaDetalleServicioEmpleado);

    IF @porcentajeParticipacion IS NOT NULL
       AND (@sumaPorcentajeActual + @porcentajeParticipacion) > 100
    BEGIN
        RAISERROR('La suma del porcentaje de participación no puede exceder 100.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoHorario eh
        WHERE eh.folioEmpleado = @folioEmpleado
          AND eh.idEntidad = @idEntidad
          AND eh.diaSemana = DATEPART(WEEKDAY, @fechaCita)
          AND ISNULL(eh.activo,1) = 1
          AND CAST(@horaInicioProgramada AS time) >= CAST(eh.horaEntrada AS time)
          AND CAST(@horaFinProgramada AS time) <= CAST(eh.horaSalida AS time)
    )
    BEGIN
        RAISERROR('El empleado no tiene horario laboral disponible para ese rango.',16,1);
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoBloqueoHorario ebh
        WHERE ebh.folioEmpleado = @folioEmpleado
          AND ebh.idEntidad = @idEntidad
          AND ISNULL(ebh.activo,1) = 1
          AND CONVERT(date, ebh.fecha) = CONVERT(date, @fechaCita)
          AND @horaInicioProgramada < ebh.horaFin
          AND @horaFinProgramada > ebh.horaInicio
    )
    BEGIN
        RAISERROR('El empleado tiene un bloqueo de horario en ese rango.',16,1);
        RETURN;
    END

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
        WHERE dse.folioEmpleado = @folioEmpleado
          AND dse.idEntidad = @idEntidad
          AND ISNULL(dse.activo,1) = 1
          AND ISNULL(ds.activo,1) = 1
          AND ISNULL(a.activo,1) = 1
          AND ISNULL(ds.cancelado,0) = 0
          AND dse.folioAgendaDetalleServicioEmpleado <> ISNULL(@folioAgendaDetalleServicioEmpleado,-1)
          AND CONVERT(date, a.fechaCita) = CONVERT(date, @fechaCita)
          AND @horaInicioProgramada < ISNULL(ds.horaFinProgramada, a.horaFinProgramada)
          AND @horaFinProgramada > ISNULL(ds.horaInicioProgramada, a.horaInicioProgramada)
    )
    BEGIN
        RAISERROR('El empleado ya tiene otro servicio asignado en ese horario.',16,1);
        RETURN;
    END

    IF @folioAgendaDetalleServicioEmpleado = 0
    BEGIN
        INSERT INTO dbo.proc_agendaDetalleServicioEmpleado
        (
            folioAgendaDetalleServicio, folioEmpleado, idRolParticipacionServicio,
            porcentajeParticipacion, comisionCalculada, horaInicioReal, horaFinReal,
            comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
        )
        VALUES
        (
            @folioAgendaDetalleServicio, @folioEmpleado, @idRolParticipacionServicio,
            @porcentajeParticipacion, @comisionCalculada, @horaInicioReal, @horaFinReal,
            @comentarios, @activo, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
        );

        SET @folioAgendaDetalleServicioEmpleado = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.proc_agendaDetalleServicioEmpleado
           SET folioEmpleado = @folioEmpleado,
               idRolParticipacionServicio = @idRolParticipacionServicio,
               porcentajeParticipacion = @porcentajeParticipacion,
               comisionCalculada = @comisionCalculada,
               horaInicioReal = @horaInicioReal,
               horaFinReal = @horaFinReal,
               comentarios = @comentarios,
               activo = @activo,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioModifica
         WHERE folioAgendaDetalleServicioEmpleado = @folioAgendaDetalleServicioEmpleado
           AND idEntidad = @idEntidad;
    END

    SELECT @folioAgendaDetalleServicioEmpleado AS folioAgendaDetalleServicioEmpleado;
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   1) CAMBIO DE ESTATUS DE AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaCambioEstatus
(
    @folioAgenda int,
    @idEstatusAgendaNuevo int,
    @descripcionMovimiento varchar(450) = NULL,
    @comentarios varchar(450) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAnterior int,
            @claveEstatusAnterior varchar(50),
            @claveEstatusNuevo varchar(50),
            @idTipoMovimientoAgenda int;

    SELECT
        @idEstatusAnterior = a.idEstatusAgenda,
        @claveEstatusAnterior = ea.clave
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF ISNULL(@idEstatusAnterior,0) = 0
    BEGIN
        RAISERROR('No se encontró la agenda indicada.',16,1);
        RETURN;
    END

    SELECT @claveEstatusNuevo = ea.clave
    FROM dbo.cat_estatusAgenda ea
    WHERE ea.idEstatusAgenda = @idEstatusAgendaNuevo
      AND ea.idEntidad = @idEntidad
      AND ISNULL(ea.activo,1) = 1;

    IF @claveEstatusNuevo IS NULL
    BEGIN
        RAISERROR('No se encontró el nuevo estatus de agenda.',16,1);
        RETURN;
    END

    IF @idEstatusAnterior = @idEstatusAgendaNuevo
    BEGIN
        RAISERROR('La agenda ya se encuentra en el estatus indicado.',16,1);
        RETURN;
    END

    IF @claveEstatusAnterior IN ('CANCELADA','CONCLUIDA')
    BEGIN
        RAISERROR('No se puede cambiar el estatus de una agenda cancelada o concluida.',16,1);
        RETURN;
    END

    IF @claveEstatusNuevo = 'REGISTRADA'
    BEGIN
        RAISERROR('No se permite regresar una agenda a REGISTRADA.',16,1);
        RETURN;
    END

    IF @claveEstatusNuevo = 'CONFIRMADA'
    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.proc_agendaDetalleServicio ds
            WHERE ds.folioAgenda = @folioAgenda
              AND ds.idEntidad = @idEntidad
              AND ISNULL(ds.activo,1) = 1
        ) 
        BEGIN
            RAISERROR('No se puede confirmar una agenda sin servicios.',16,1);
            RETURN;
        END
    END

    IF @claveEstatusNuevo = 'ENPROCESO'
    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.proc_agendaDetalleServicio ds
            WHERE ds.folioAgenda = @folioAgenda
              AND ds.idEntidad = @idEntidad
              AND ISNULL(ds.activo,1) = 1
        )
        BEGIN
            RAISERROR('No se puede poner en proceso una agenda sin servicios.',16,1);
            RETURN;
        END
    END

    IF @claveEstatusNuevo = 'CONCLUIDA'
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM dbo.proc_agendaDetalleServicio ds
            INNER JOIN dbo.cat_estatusAgendaDetalleServicio eds
                ON eds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
               AND eds.idEntidad = ds.idEntidad
            WHERE ds.folioAgenda = @folioAgenda
              AND ds.idEntidad = @idEntidad
              AND ISNULL(ds.activo,1) = 1
              AND eds.clave NOT IN ('CONCLUIDO','CANCELADO')
        )
        BEGIN
            RAISERROR('No se puede concluir la agenda mientras existan servicios pendientes, asignados o en proceso.',16,1);
            RETURN;
        END
    END

    SELECT @idTipoMovimientoAgenda = idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda
    WHERE idEntidad = @idEntidad
      AND clave = 'CAMBIOESTATUS'
      AND ISNULL(activo,1) = 1;

    IF ISNULL(@idTipoMovimientoAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el tipo de movimiento CAMBIOESTATUS.',16,1);
        RETURN;
    END

    UPDATE dbo.proc_agenda
       SET idEstatusAgenda = @idEstatusAgendaNuevo,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgenda = @folioAgenda
       AND idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda, idEstatusAnterior, idEstatusNuevo,
        descripcionMovimiento, datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, NULL, @idTipoMovimientoAgenda, @idEstatusAnterior, @idEstatusAgendaNuevo,
        ISNULL(@descripcionMovimiento,'Cambio de estatus de agenda'), NULL, NULL, GETDATE(),
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgenda AS folioAgenda;
END
GO


/* =========================================================
   2) CAMBIO DE ESTATUS DETALLE SERVICIO
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaCambioEstatusDetalleServicio
(
    @folioAgendaDetalleServicio int,
    @idEstatusAgendaDetalleServicioNuevo int,
    @descripcionMovimiento varchar(450) = NULL,
    @comentarios varchar(450) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAnterior int,
            @folioAgenda int,
            @idTipoMovimientoAgenda int,
            @claveNuevo varchar(50),
            @claveAnterior varchar(50),
            @claveAgenda varchar(50);

    SELECT
        @idEstatusAnterior = ds.idEstatusAgendaDetalleServicio,
        @folioAgenda = ds.folioAgenda,
        @claveAnterior = eds.clave
    FROM dbo.proc_agendaDetalleServicio ds
    INNER JOIN dbo.cat_estatusAgendaDetalleServicio eds
        ON eds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
       AND eds.idEntidad = ds.idEntidad
    WHERE ds.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
      AND ds.idEntidad = @idEntidad
      AND ISNULL(ds.activo,1) = 1;

    IF @folioAgenda IS NULL
    BEGIN
        RAISERROR('No existe el detalle de servicio indicado.',16,1);
        RETURN;
    END

    SELECT @claveAgenda = ea.clave
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF @claveAgenda IN ('CANCELADA','CONCLUIDA')
    BEGIN
        RAISERROR('No se puede cambiar el estatus de un detalle cuando la agenda está cancelada o concluida.',16,1);
        RETURN;
    END

    SELECT @claveNuevo = clave
    FROM dbo.cat_estatusAgendaDetalleServicio
    WHERE idEstatusAgendaDetalleServicio = @idEstatusAgendaDetalleServicioNuevo
      AND idEntidad = @idEntidad
      AND ISNULL(activo,1) = 1;

    IF @claveNuevo IS NULL
    BEGIN
        RAISERROR('No existe el nuevo estatus del detalle de servicio.',16,1);
        RETURN;
    END

    IF @idEstatusAnterior = @idEstatusAgendaDetalleServicioNuevo
    BEGIN
        RAISERROR('El detalle ya se encuentra en el estatus indicado.',16,1);
        RETURN;
    END

    IF @claveAnterior IN ('CANCELADO','CONCLUIDO')
    BEGIN
        RAISERROR('No se puede cambiar el estatus de un detalle cancelado o concluido.',16,1);
        RETURN;
    END

    IF @claveNuevo = 'PENDIENTE'
    BEGIN
        RAISERROR('No se permite regresar un detalle a PENDIENTE.',16,1);
        RETURN;
    END

    IF @claveNuevo = 'ENPROCESO'
    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.proc_agendaDetalleServicioEmpleado dse
            WHERE dse.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
              AND dse.idEntidad = @idEntidad
              AND ISNULL(dse.activo,1) = 1
        )
        BEGIN
            RAISERROR('No se puede iniciar un servicio sin empleado asignado.',16,1);
            RETURN;
        END
    END

    IF @claveNuevo = 'CONCLUIDO'
    BEGIN
        IF @claveAnterior NOT IN ('ASIGNADO','ENPROCESO')
        BEGIN
            RAISERROR('Solo se puede concluir un detalle asignado o en proceso.',16,1);
            RETURN;
        END
    END

    IF @claveNuevo = 'CANCELADO'
    BEGIN
        IF @claveAnterior = 'CONCLUIDO'
        BEGIN
            RAISERROR('No se puede cancelar un detalle concluido.',16,1);
            RETURN;
        END
    END

    SELECT @idTipoMovimientoAgenda = idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda
    WHERE idEntidad = @idEntidad
      AND clave = 'CAMBIOESTATUS'
      AND ISNULL(activo,1) = 1;

    IF ISNULL(@idTipoMovimientoAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el tipo de movimiento CAMBIOESTATUS.',16,1);
        RETURN;
    END

    UPDATE dbo.proc_agendaDetalleServicio
       SET idEstatusAgendaDetalleServicio = @idEstatusAgendaDetalleServicioNuevo,
           cancelado = CASE WHEN @claveNuevo = 'CANCELADO' THEN 1 ELSE cancelado END,
           motivoCancelacion = CASE WHEN @claveNuevo = 'CANCELADO' THEN ISNULL(@descripcionMovimiento,@comentarios) ELSE motivoCancelacion END,
           horaInicioReal = CASE WHEN @claveNuevo = 'ENPROCESO' AND horaInicioReal IS NULL THEN GETDATE() ELSE horaInicioReal END,
           horaFinReal = CASE WHEN @claveNuevo = 'CONCLUIDO' THEN GETDATE() ELSE horaFinReal END,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgendaDetalleServicio = @folioAgendaDetalleServicio
       AND idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda,
        idEstatusAnterior, idEstatusNuevo, descripcionMovimiento,
        datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, @folioAgendaDetalleServicio, @idTipoMovimientoAgenda,
        @idEstatusAnterior, @idEstatusAgendaDetalleServicioNuevo,
        ISNULL(@descripcionMovimiento,'Cambio de estatus de detalle de servicio'),
        NULL, NULL, GETDATE(),
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgendaDetalleServicio AS folioAgendaDetalleServicio;
END
GO


/* =========================================================
   3) CANCELAR AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_cancelarAgenda
(
    @folioAgenda int,
    @motivoCancelacion varchar(450),
    @cancelarDetalles bit = 1,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAnterior int,
            @idEstatusNuevo int,
            @idTipoMovimientoAgenda int,
            @idEstatusDetalleCancelado int,
            @claveEstatusAnterior varchar(50);

    IF ISNULL(LTRIM(RTRIM(ISNULL(@motivoCancelacion,''))),'') = ''
    BEGIN
        RAISERROR('El motivo de cancelación es obligatorio.',16,1);
        RETURN;
    END

    SELECT
        @idEstatusAnterior = a.idEstatusAgenda,
        @claveEstatusAnterior = ea.clave
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF ISNULL(@idEstatusAnterior,0) = 0
    BEGIN
        RAISERROR('No existe la agenda indicada.',16,1);
        RETURN;
    END

    IF @claveEstatusAnterior = 'CANCELADA'
    BEGIN
        RAISERROR('La agenda ya está cancelada.',16,1);
        RETURN;
    END

    IF @claveEstatusAnterior = 'CONCLUIDA'
    BEGIN
        RAISERROR('No se puede cancelar una agenda concluida.',16,1);
        RETURN;
    END

    SELECT @idEstatusNuevo = cea.idEstatusAgenda
    FROM dbo.cat_estatusAgenda cea
    WHERE cea.idEntidad = @idEntidad
      AND cea.clave = 'CANCELADA'
      AND ISNULL(cea.activo,1) = 1;

    IF ISNULL(@idEstatusNuevo,0) = 0
    BEGIN
        RAISERROR('No existe el estatus CANCELADA.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = ctm.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda ctm
    WHERE ctm.idEntidad = @idEntidad
      AND ctm.clave = 'CAMBIOESTATUS'
      AND ISNULL(ctm.activo,1) = 1;

    IF ISNULL(@idTipoMovimientoAgenda,0) = 0
    BEGIN
        RAISERROR('No existe el tipo de movimiento CAMBIOESTATUS.',16,1);
        RETURN;
    END

    SELECT @idEstatusDetalleCancelado = ceds.idEstatusAgendaDetalleServicio
    FROM dbo.cat_estatusAgendaDetalleServicio ceds
    WHERE ceds.idEntidad = @idEntidad
      AND ceds.clave = 'CANCELADO'
      AND ISNULL(ceds.activo,1) = 1;

    UPDATE dbo.proc_agenda
       SET idEstatusAgenda = @idEstatusNuevo,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgenda = @folioAgenda
       AND idEntidad = @idEntidad;

    IF @cancelarDetalles = 1 AND ISNULL(@idEstatusDetalleCancelado,0) > 0
    BEGIN
        UPDATE dbo.proc_agendaDetalleServicio
           SET idEstatusAgendaDetalleServicio = CASE 
                                                    WHEN EXISTS
                                                    (
                                                        SELECT 1
                                                        FROM dbo.cat_estatusAgendaDetalleServicio eds
                                                        WHERE eds.idEstatusAgendaDetalleServicio = @idEstatusDetalleCancelado
                                                          AND eds.idEntidad = @idEntidad
                                                    ) THEN @idEstatusDetalleCancelado
                                                    ELSE idEstatusAgendaDetalleServicio
                                                END,
               cancelado = CASE WHEN ISNULL(cancelado,0) = 0 THEN 1 ELSE cancelado END,
               motivoCancelacion = CASE 
                                      WHEN ISNULL(cancelado,0) = 0 THEN @motivoCancelacion
                                      ELSE motivoCancelacion
                                   END,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioAlta
         WHERE folioAgenda = @folioAgenda
           AND idEntidad = @idEntidad
           AND ISNULL(activo,1) = 1
           AND ISNULL(cancelado,0) = 0
           AND idEstatusAgendaDetalleServicio NOT IN
               (
                   SELECT idEstatusAgendaDetalleServicio
                   FROM dbo.cat_estatusAgendaDetalleServicio
                   WHERE idEntidad = @idEntidad
                     AND clave = 'CONCLUIDO'
               );
    END

	UPDATE a
	SET totalCotizado = ISNULL((
		SELECT SUM(ISNULL(ds.precioFinal,0) * ISNULL(ds.cantidad,1))
		FROM dbo.proc_agendaDetalleServicio ds
		WHERE ds.folioAgenda = a.folioAgenda
			AND ds.idEntidad = a.idEntidad
			AND ISNULL(ds.activo,1) = 1
			AND ISNULL(ds.cancelado,0) = 0
	),0),
		fechaModificacion = GETDATE(),
		idUsuarioModifica = @idUsuarioAlta
	FROM dbo.proc_agenda a
	WHERE a.folioAgenda = @folioAgenda
		AND a.idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda,
        idEstatusAnterior, idEstatusNuevo, descripcionMovimiento,
        datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion,
        idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, NULL, @idTipoMovimientoAgenda,
        @idEstatusAnterior, @idEstatusNuevo, 'Cancelación de agenda',
        NULL, NULL, GETDATE(),
        @motivoCancelacion, 1, @idEntidad, NULL,
        NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgenda AS folioAgenda;
END
GO


/* =========================================================
   4) CANCELAR DETALLE DE SERVICIO
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_cancelarDetalleServicio
(
    @folioAgendaDetalleServicio int,
    @motivoCancelacion varchar(450),
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @folioAgenda int,
            @idEstatusAnterior int,
            @idEstatusNuevo int,
            @idTipoMovimientoAgenda int,
            @claveEstatusAnterior varchar(50),
            @claveAgenda varchar(50);

    IF ISNULL(LTRIM(RTRIM(ISNULL(@motivoCancelacion,''))),'') = ''
    BEGIN
        RAISERROR('El motivo de cancelación es obligatorio.',16,1);
        RETURN;
    END

    SELECT
        @folioAgenda = ds.folioAgenda,
        @idEstatusAnterior = ds.idEstatusAgendaDetalleServicio,
        @claveEstatusAnterior = eds.clave
    FROM dbo.proc_agendaDetalleServicio ds
    INNER JOIN dbo.cat_estatusAgendaDetalleServicio eds
        ON eds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
       AND eds.idEntidad = ds.idEntidad
    WHERE ds.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
      AND ds.idEntidad = @idEntidad
      AND ISNULL(ds.activo,1) = 1;

    IF ISNULL(@folioAgenda,0) = 0
    BEGIN
        RAISERROR('No existe el detalle de servicio indicado.',16,1);
        RETURN;
    END

    IF @claveEstatusAnterior = 'CANCELADO'
    BEGIN
        RAISERROR('El detalle de servicio ya está cancelado.',16,1);
        RETURN;
    END

    IF @claveEstatusAnterior = 'CONCLUIDO'
    BEGIN
        RAISERROR('No se puede cancelar un detalle concluido.',16,1);
        RETURN;
    END

    SELECT @claveAgenda = ea.clave
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF @claveAgenda IN ('CANCELADA','CONCLUIDA')
    BEGIN
        RAISERROR('No se puede cancelar un detalle cuando la agenda está cancelada o concluida.',16,1);
        RETURN;
    END

    SELECT @idEstatusNuevo = ceds.idEstatusAgendaDetalleServicio
    FROM dbo.cat_estatusAgendaDetalleServicio ceds
    WHERE ceds.idEntidad = @idEntidad
      AND ceds.clave = 'CANCELADO'
      AND ISNULL(ceds.activo,1) = 1;

    IF ISNULL(@idEstatusNuevo,0) = 0
    BEGIN
        RAISERROR('No existe el estatus CANCELADO para detalle.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = ctm.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda ctm
    WHERE ctm.idEntidad = @idEntidad
      AND ctm.clave = 'CAMBIOESTATUS'
      AND ISNULL(ctm.activo,1) = 1;

    IF ISNULL(@idTipoMovimientoAgenda,0) = 0
    BEGIN
        RAISERROR('No existe el tipo de movimiento CAMBIOESTATUS.',16,1);
        RETURN;
    END

    UPDATE dbo.proc_agendaDetalleServicio
       SET idEstatusAgendaDetalleServicio = @idEstatusNuevo,
           cancelado = 1,
           motivoCancelacion = @motivoCancelacion,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgendaDetalleServicio = @folioAgendaDetalleServicio
       AND idEntidad = @idEntidad;

    UPDATE a
       SET totalCotizado = ISNULL((
            SELECT SUM(ISNULL(ds.precioFinal,0) * ISNULL(ds.cantidad,1))
            FROM dbo.proc_agendaDetalleServicio ds
            WHERE ds.folioAgenda = a.folioAgenda
              AND ds.idEntidad = a.idEntidad
              AND ISNULL(ds.activo,1) = 1
              AND ISNULL(ds.cancelado,0) = 0
        ),0),
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
    FROM dbo.proc_agenda a
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda,
        idEstatusAnterior, idEstatusNuevo, descripcionMovimiento,
        datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion,
        idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, @folioAgendaDetalleServicio, @idTipoMovimientoAgenda,
        @idEstatusAnterior, @idEstatusNuevo, 'Cancelación de detalle de servicio',
        NULL, NULL, GETDATE(),
        @motivoCancelacion, 1, @idEntidad, NULL,
        NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgendaDetalleServicio AS folioAgendaDetalleServicio;
END
GO


/* =========================================================
   5) REPROGRAMACION DE AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaReprogramacion
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

    DECLARE @fechaHoraAnteriorInicio datetime,
            @fechaHoraAnteriorFin datetime,
            @idTipoMovimientoAgenda int,
            @claveAgenda varchar(50);

    SELECT
        @fechaHoraAnteriorInicio = horaInicioProgramada,
        @fechaHoraAnteriorFin = horaFinProgramada,
        @claveAgenda = ea.clave
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
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

    /* Validar empalmes + horario + bloqueos de empleados asignados */
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
                    AND ds.folioAgenda <> @folioAgenda
                    AND ISNULL(ds.cancelado,0) = 0
                    AND @fechaHoraNuevaInicio < ISNULL(ds.horaFinProgramada, a.horaFinProgramada)
                    AND @fechaHoraNuevaFin > ISNULL(ds.horaInicioProgramada, a.horaInicioProgramada)
              )
          )
    )
    BEGIN
        RAISERROR('La nueva fecha/hora genera conflicto de horario, bloqueo o empalme para uno o más empleados asignados.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = ctm.idTipoMovimientoAgenda
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
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   1) PAGO DE AGENDA - ALTA CON VALIDACIONES
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaPago
(
    @folioAgenda int,
    @idTipoMovimientoPagoAgenda int,
    @idTipoPago int,
    @montoPago decimal(16,4),
    @numeroAutorizacion varchar(250) = NULL,
    @referenciaOperacion varchar(250) = NULL,
    @referenciaExterna varchar(250) = NULL,
    @comentarios varchar(450) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @folioAgendaPago int,
            @idEstatusPagoAgenda int,
            @idTipoMovimientoAgenda int,
            @idEstatusAgenda int,
            @claveEstatusAgenda varchar(50),
            @totalCotizado decimal(16,4),
            @totalPagadoActual decimal(16,4),
            @saldoPendiente decimal(16,4),
            @claveTipoMovimientoPago varchar(50);

    IF ISNULL(@folioAgenda,0) <= 0
    BEGIN
        RAISERROR('La agenda es obligatoria.',16,1);
        RETURN;
    END

    IF ISNULL(@idTipoMovimientoPagoAgenda,0) <= 0
    BEGIN
        RAISERROR('El tipo de movimiento de pago es obligatorio.',16,1);
        RETURN;
    END

    IF ISNULL(@idTipoPago,0) <= 0
    BEGIN
        RAISERROR('El tipo de pago es obligatorio.',16,1);
        RETURN;
    END

    IF ISNULL(@montoPago,0) <= 0
    BEGIN
        RAISERROR('El monto de pago debe ser mayor a 0.',16,1);
        RETURN;
    END

    SELECT
        @idEstatusAgenda = a.idEstatusAgenda,
        @claveEstatusAgenda = ea.clave,
        @totalCotizado = ISNULL(a.totalCotizado,0),
        @totalPagadoActual = ISNULL(a.totalPagado,0)
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF ISNULL(@idEstatusAgenda,0) = 0
    BEGIN
        RAISERROR('La agenda no existe o no está activa.',16,1);
        RETURN;
    END

    IF @claveEstatusAgenda = 'CANCELADA'
    BEGIN
        RAISERROR('No se pueden registrar pagos en una agenda cancelada.',16,1);
        RETURN;
    END

    IF @claveEstatusAgenda = 'CONCLUIDA'
    BEGIN
        RAISERROR('No se pueden registrar pagos en una agenda concluida.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_tipoMovimientoPagoAgenda tmpa
        WHERE tmpa.idTipoMovimientoPagoAgenda = @idTipoMovimientoPagoAgenda
          AND tmpa.idEntidad = @idEntidad
          AND ISNULL(tmpa.activo,1) = 1
    )
    BEGIN
        RAISERROR('El tipo de movimiento de pago no existe o no está activo.',16,1);
        RETURN;
    END

    SELECT @claveTipoMovimientoPago = tmpa.clave
    FROM dbo.cat_tipoMovimientoPagoAgenda tmpa
    WHERE tmpa.idTipoMovimientoPagoAgenda = @idTipoMovimientoPagoAgenda
      AND tmpa.idEntidad = @idEntidad
      AND ISNULL(tmpa.activo,1) = 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_tiposPago tp
        WHERE tp.id = @idTipoPago
          AND ISNULL(tp.activo,1) = 1
    )
    BEGIN
        RAISERROR('El tipo de pago no existe o no está activo.',16,1);
        RETURN;
    END

    SELECT @idEstatusPagoAgenda = epa.idEstatusPagoAgenda
    FROM dbo.cat_estatusPagoAgenda epa
    WHERE epa.idEntidad = @idEntidad
      AND epa.clave = 'APLICADO'
      AND ISNULL(epa.activo,1) = 1;

    IF ISNULL(@idEstatusPagoAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el estatus de pago APLICADO.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = tma.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda tma
    WHERE tma.idEntidad = @idEntidad
      AND tma.clave = 'PAGO'
      AND ISNULL(tma.activo,1) = 1;

    IF ISNULL(@idTipoMovimientoAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el tipo de movimiento PAGO.',16,1);
        RETURN;
    END

    IF ISNULL(@totalCotizado,0) <= 0
    BEGIN
        RAISERROR('La agenda no tiene total cotizado válido para registrar pago.',16,1);
        RETURN;
    END

    SET @saldoPendiente = ISNULL(@totalCotizado,0) - ISNULL(@totalPagadoActual,0);

    IF @claveTipoMovimientoPago IN ('ANTICIPO','LIQUIDACION')
    BEGIN
        IF @saldoPendiente <= 0
        BEGIN
            RAISERROR('La agenda ya no tiene saldo pendiente.',16,1);
            RETURN;
        END

        IF @montoPago > @saldoPendiente
        BEGIN
            RAISERROR('El monto de pago excede el saldo pendiente de la agenda.',16,1);
            RETURN;
        END
    END

    INSERT INTO dbo.proc_agendaPago
    (
        folioAgenda, idTipoMovimientoPagoAgenda, idEstatusPagoAgenda, montoTotal,
        fechaPago, referenciaExterna, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, @idTipoMovimientoPagoAgenda, @idEstatusPagoAgenda, @montoPago,
        GETDATE(), @referenciaExterna, @comentarios, 1, @idEntidad,
        NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SET @folioAgendaPago = SCOPE_IDENTITY();

    INSERT INTO dbo.proc_agendaPagoDetalle
    (
        folioAgendaPago, idTipoPago, montoPago, numeroAutorizacion, referenciaOperacion,
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgendaPago, @idTipoPago, @montoPago, @numeroAutorizacion, @referenciaOperacion,
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    UPDATE a
       SET totalPagado = ISNULL((
            SELECT SUM(ISNULL(ap.montoTotal,0))
            FROM dbo.proc_agendaPago ap
            WHERE ap.folioAgenda = a.folioAgenda
              AND ap.idEntidad = a.idEntidad
              AND ISNULL(ap.activo,1) = 1
        ),0),
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
    FROM dbo.proc_agenda a
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda, idEstatusAnterior, idEstatusNuevo,
        descripcionMovimiento, datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, NULL, @idTipoMovimientoAgenda, NULL, NULL,
        'Registro de pago de agenda', NULL, NULL, GETDATE(),
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgendaPago AS folioAgendaPago;
END
GO
--
--
--	BLINDAJE CONSTRAINTS PARA TABLAS 
--
--

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   1) UNIQUE EN CATALOGOS POR idEntidad + clave
   ========================================================= */

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_cat_estatusAgenda_idEntidad_clave'
      AND object_id = OBJECT_ID('dbo.cat_estatusAgenda')
)
BEGIN
    CREATE UNIQUE INDEX UX_cat_estatusAgenda_idEntidad_clave
        ON dbo.cat_estatusAgenda(idEntidad, clave);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_cat_estatusAgendaDetalleServicio_idEntidad_clave'
      AND object_id = OBJECT_ID('dbo.cat_estatusAgendaDetalleServicio')
)
BEGIN
    CREATE UNIQUE INDEX UX_cat_estatusAgendaDetalleServicio_idEntidad_clave
        ON dbo.cat_estatusAgendaDetalleServicio(idEntidad, clave);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_cat_origenAgenda_idEntidad_clave'
      AND object_id = OBJECT_ID('dbo.cat_origenAgenda')
)
BEGIN
    CREATE UNIQUE INDEX UX_cat_origenAgenda_idEntidad_clave
        ON dbo.cat_origenAgenda(idEntidad, clave);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_cat_tipoMovimientoAgenda_idEntidad_clave'
      AND object_id = OBJECT_ID('dbo.cat_tipoMovimientoAgenda')
)
BEGIN
    CREATE UNIQUE INDEX UX_cat_tipoMovimientoAgenda_idEntidad_clave
        ON dbo.cat_tipoMovimientoAgenda(idEntidad, clave);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_cat_tipoMovimientoPagoAgenda_idEntidad_clave'
      AND object_id = OBJECT_ID('dbo.cat_tipoMovimientoPagoAgenda')
)
BEGIN
    CREATE UNIQUE INDEX UX_cat_tipoMovimientoPagoAgenda_idEntidad_clave
        ON dbo.cat_tipoMovimientoPagoAgenda(idEntidad, clave);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_cat_estatusPagoAgenda_idEntidad_clave'
      AND object_id = OBJECT_ID('dbo.cat_estatusPagoAgenda')
)
BEGIN
    CREATE UNIQUE INDEX UX_cat_estatusPagoAgenda_idEntidad_clave
        ON dbo.cat_estatusPagoAgenda(idEntidad, clave);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_cat_tipoBloqueoHorario_idEntidad_clave'
      AND object_id = OBJECT_ID('dbo.cat_tipoBloqueoHorario')
)
BEGIN
    CREATE UNIQUE INDEX UX_cat_tipoBloqueoHorario_idEntidad_clave
        ON dbo.cat_tipoBloqueoHorario(idEntidad, clave);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_cat_rolParticipacionServicio_idEntidad_clave'
      AND object_id = OBJECT_ID('dbo.cat_rolParticipacionServicio')
)
BEGIN
    CREATE UNIQUE INDEX UX_cat_rolParticipacionServicio_idEntidad_clave
        ON dbo.cat_rolParticipacionServicio(idEntidad, clave);
END
GO


/* =========================================================
   2) CHECK CONSTRAINTS BASICOS
   ========================================================= */

/* cat_productosServicios */
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_cat_productosServicios_duracionBaseMin'
)
BEGIN
    ALTER TABLE dbo.cat_productosServicios
    ADD CONSTRAINT CK_cat_productosServicios_duracionBaseMin
        CHECK (duracionBaseMin IS NULL OR duracionBaseMin > 0);
END
GO

/* proc_empleadoHorario */
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_proc_empleadoHorario_diaSemana'
)
BEGIN
    ALTER TABLE dbo.proc_empleadoHorario
    ADD CONSTRAINT CK_proc_empleadoHorario_diaSemana
        CHECK (diaSemana BETWEEN 1 AND 7);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_proc_empleadoHorario_horas'
)
BEGIN
    ALTER TABLE dbo.proc_empleadoHorario
    ADD CONSTRAINT CK_proc_empleadoHorario_horas
        CHECK (horaSalida > horaEntrada);
END
GO

/* proc_empleadoBloqueoHorario */
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_proc_empleadoBloqueoHorario_horas'
)
BEGIN
    ALTER TABLE dbo.proc_empleadoBloqueoHorario
    ADD CONSTRAINT CK_proc_empleadoBloqueoHorario_horas
        CHECK (horaFin > horaInicio);
END
GO

/* proc_agenda */
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_proc_agenda_horas'
)
BEGIN
    ALTER TABLE dbo.proc_agenda
    ADD CONSTRAINT CK_proc_agenda_horas
        CHECK (horaFinProgramada > horaInicioProgramada);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_proc_agenda_totales'
)
BEGIN
    ALTER TABLE dbo.proc_agenda
    ADD CONSTRAINT CK_proc_agenda_totales
        CHECK (
            ISNULL(totalCotizado,0) >= 0
            AND ISNULL(totalPagado,0) >= 0
        );
END
GO

/* proc_agendaDetalleServicio */
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_proc_agendaDetalleServicio_importes'
)
BEGIN
    ALTER TABLE dbo.proc_agendaDetalleServicio
    ADD CONSTRAINT CK_proc_agendaDetalleServicio_importes
        CHECK (
            duracionEstimadaMin > 0
            AND precioLista >= 0
            AND precioFinal >= 0
            AND ISNULL(descuento,0) >= 0
            AND ISNULL(cantidad,0) > 0
            AND ordenServicio > 0
        );
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_proc_agendaDetalleServicio_horas'
)
BEGIN
    ALTER TABLE dbo.proc_agendaDetalleServicio
    ADD CONSTRAINT CK_proc_agendaDetalleServicio_horas
        CHECK (
            (horaInicioProgramada IS NULL AND horaFinProgramada IS NULL)
            OR (horaInicioProgramada IS NOT NULL AND horaFinProgramada IS NOT NULL AND horaFinProgramada > horaInicioProgramada)
        );
END
GO

/* proc_agendaDetalleServicioEmpleado */
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_proc_agendaDetalleServicioEmpleado_porcentaje'
)
BEGIN
    ALTER TABLE dbo.proc_agendaDetalleServicioEmpleado
    ADD CONSTRAINT CK_proc_agendaDetalleServicioEmpleado_porcentaje
        CHECK (
            porcentajeParticipacion IS NULL
            OR (porcentajeParticipacion >= 0 AND porcentajeParticipacion <= 100)
        );
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_proc_agendaDetalleServicioEmpleado_comision'
)
BEGIN
    ALTER TABLE dbo.proc_agendaDetalleServicioEmpleado
    ADD CONSTRAINT CK_proc_agendaDetalleServicioEmpleado_comision
        CHECK (
            comisionCalculada IS NULL
            OR comisionCalculada >= 0
        );
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_proc_agendaDetalleServicioEmpleado_horas'
)
BEGIN
    ALTER TABLE dbo.proc_agendaDetalleServicioEmpleado
    ADD CONSTRAINT CK_proc_agendaDetalleServicioEmpleado_horas
        CHECK (
            (horaInicioReal IS NULL AND horaFinReal IS NULL)
            OR (horaInicioReal IS NOT NULL AND horaFinReal IS NOT NULL AND horaFinReal > horaInicioReal)
            OR (horaInicioReal IS NOT NULL AND horaFinReal IS NULL)
        );
END
GO

/* proc_agendaPago */
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_proc_agendaPago_montoTotal'
)
BEGIN
    ALTER TABLE dbo.proc_agendaPago
    ADD CONSTRAINT CK_proc_agendaPago_montoTotal
        CHECK (montoTotal > 0);
END
GO

/* proc_agendaPagoDetalle */
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_proc_agendaPagoDetalle_montoPago'
)
BEGIN
    ALTER TABLE dbo.proc_agendaPagoDetalle
    ADD CONSTRAINT CK_proc_agendaPagoDetalle_montoPago
        CHECK (montoPago > 0);
END
GO

/* proc_agendaReprogramacion */
IF OBJECT_ID('dbo.proc_agendaReprogramacion','U') IS NOT NULL
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM sys.check_constraints
        WHERE name = 'CK_proc_agendaReprogramacion_horas'
    )
    BEGIN
        ALTER TABLE dbo.proc_agendaReprogramacion
        ADD CONSTRAINT CK_proc_agendaReprogramacion_horas
            CHECK (
                fechaHoraAnteriorFin > fechaHoraAnteriorInicio
                AND fechaHoraNuevaFin > fechaHoraNuevaInicio
            );
    END
END
GO


/* =========================================================
   3) UNIQUE OPERATIVOS
   ========================================================= */

/* Evitar empleado duplicado en el mismo detalle */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_proc_agendaDetalleServicioEmpleado_detalle_empleado'
      AND object_id = OBJECT_ID('dbo.proc_agendaDetalleServicioEmpleado')
)
BEGIN
    CREATE UNIQUE INDEX UX_proc_agendaDetalleServicioEmpleado_detalle_empleado
    ON dbo.proc_agendaDetalleServicioEmpleado(idEntidad, folioAgendaDetalleServicio, folioEmpleado)
    WHERE activo = 1;
END
GO

/* Evitar duplicado exacto de horario por empleado */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_proc_empleadoHorario_empleado_dia_horas'
      AND object_id = OBJECT_ID('dbo.proc_empleadoHorario')
)
BEGIN
    CREATE UNIQUE INDEX UX_proc_empleadoHorario_empleado_dia_horas
        ON dbo.proc_empleadoHorario(idEntidad, folioEmpleado, diaSemana, horaEntrada, horaSalida);
END
GO

/* Evitar duplicado exacto de bloqueo por empleado */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_proc_empleadoBloqueoHorario_empleado_fecha_horas_tipo'
      AND object_id = OBJECT_ID('dbo.proc_empleadoBloqueoHorario')
)
BEGIN
    CREATE UNIQUE INDEX UX_proc_empleadoBloqueoHorario_empleado_fecha_horas_tipo
        ON dbo.proc_empleadoBloqueoHorario(idEntidad, folioEmpleado, fecha, horaInicio, horaFin, idTipoBloqueoHorario);
END
GO


/* =========================================================
   4) INDICES ADICIONALES DE NEGOCIO
   ========================================================= */

/* proc_agenda */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_proc_agenda_4'
      AND object_id = OBJECT_ID('dbo.proc_agenda')
)
BEGIN
    CREATE INDEX IX_proc_agenda_4
        ON dbo.proc_agenda(idEntidad, idEstatusAgenda, fechaCita);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_proc_agenda_5'
      AND object_id = OBJECT_ID('dbo.proc_agenda')
)
BEGIN
    CREATE INDEX IX_proc_agenda_5
        ON dbo.proc_agenda(idEntidad, idOrigenAgenda, fechaCita);
END
GO

/* proc_agendaDetalleServicio */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_proc_agendaDetalleServicio_4'
      AND object_id = OBJECT_ID('dbo.proc_agendaDetalleServicio')
)
BEGIN
    CREATE INDEX IX_proc_agendaDetalleServicio_4
        ON dbo.proc_agendaDetalleServicio(idEntidad, folioAgenda, cancelado, activo);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_proc_agendaDetalleServicio_5'
      AND object_id = OBJECT_ID('dbo.proc_agendaDetalleServicio')
)
BEGIN
    CREATE INDEX IX_proc_agendaDetalleServicio_5
        ON dbo.proc_agendaDetalleServicio(idEntidad, folioAgenda, ordenServicio);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_proc_agendaDetalleServicio_6'
      AND object_id = OBJECT_ID('dbo.proc_agendaDetalleServicio')
)
BEGIN
    CREATE INDEX IX_proc_agendaDetalleServicio_6
        ON dbo.proc_agendaDetalleServicio(idEntidad, horaInicioProgramada, horaFinProgramada);
END
GO

/* proc_agendaDetalleServicioEmpleado */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_proc_agendaDetalleServicioEmpleado_3'
      AND object_id = OBJECT_ID('dbo.proc_agendaDetalleServicioEmpleado')
)
BEGIN
    CREATE INDEX IX_proc_agendaDetalleServicioEmpleado_3
        ON dbo.proc_agendaDetalleServicioEmpleado(idEntidad, folioEmpleado, activo, folioAgendaDetalleServicio);
END
GO

/* proc_agendaPago */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_proc_agendaPago_3'
      AND object_id = OBJECT_ID('dbo.proc_agendaPago')
)
BEGIN
    CREATE INDEX IX_proc_agendaPago_3
        ON dbo.proc_agendaPago(idEntidad, idEstatusPagoAgenda, fechaPago);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_proc_agendaPago_4'
      AND object_id = OBJECT_ID('dbo.proc_agendaPago')
)
BEGIN
    CREATE INDEX IX_proc_agendaPago_4
        ON dbo.proc_agendaPago(idEntidad, idTipoMovimientoPagoAgenda, fechaPago);
END
GO

/* proc_agendaPagoDetalle */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_proc_agendaPagoDetalle_2'
      AND object_id = OBJECT_ID('dbo.proc_agendaPagoDetalle')
)
BEGIN
    CREATE INDEX IX_proc_agendaPagoDetalle_2
        ON dbo.proc_agendaPagoDetalle(idEntidad, idTipoPago, fechaAlta);
END
GO

/* proc_agendaBitacora */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_proc_agendaBitacora_3'
      AND object_id = OBJECT_ID('dbo.proc_agendaBitacora')
)
BEGIN
    CREATE INDEX IX_proc_agendaBitacora_3
        ON dbo.proc_agendaBitacora(idEntidad, folioAgendaDetalleServicio, fechaMovimiento);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_proc_agendaBitacora_4'
      AND object_id = OBJECT_ID('dbo.proc_agendaBitacora')
)
BEGIN
    CREATE INDEX IX_proc_agendaBitacora_4
        ON dbo.proc_agendaBitacora(idEntidad, idTipoMovimientoAgenda, fechaMovimiento);
END
GO

/* proc_empleadoHorario */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_proc_empleadoHorario_2'
      AND object_id = OBJECT_ID('dbo.proc_empleadoHorario')
)
BEGIN
    CREATE INDEX IX_proc_empleadoHorario_2
        ON dbo.proc_empleadoHorario(idEntidad, diaSemana, activo, folioEmpleado);
END
GO

/* proc_empleadoBloqueoHorario */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_proc_empleadoBloqueoHorario_2'
      AND object_id = OBJECT_ID('dbo.proc_empleadoBloqueoHorario')
)
BEGIN
    CREATE INDEX IX_proc_empleadoBloqueoHorario_2
        ON dbo.proc_empleadoBloqueoHorario(idEntidad, fecha, folioEmpleado, activo);
END
GO

/* proc_agendaReprogramacion */
IF OBJECT_ID('dbo.proc_agendaReprogramacion','U') IS NOT NULL
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE name = 'IX_proc_agendaReprogramacion_1'
          AND object_id = OBJECT_ID('dbo.proc_agendaReprogramacion')
    )
    BEGIN
        CREATE INDEX IX_proc_agendaReprogramacion_1
            ON dbo.proc_agendaReprogramacion(idEntidad, folioAgenda, fechaAlta);
    END
END
GO


--
--
--	CORRECIONAS A BUGS EXISTENTES, MEJORA DE LAS MEJORAS XD, ESTE ES EL ULTIMO EJECUTADO
--
---

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   1) AGENDA - ALTA / EDICION CON VALIDACIONES
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agenda
(
    @folioAgenda int = 0,
    @folioCliente int,
    @idSucursal int,
    @fechaCita datetime,
    @horaInicioProgramada datetime,
    @horaFinProgramada datetime,
    @idOrigenAgenda int,
    @requiereConfirmacion bit = 0,
    @observacionesInternas varchar(450) = NULL,
    @comentarios varchar(450) = NULL,
    @activo bit = 1,
    @idEntidad int,
    @idUsuarioModifica int = NULL,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAgenda int,
            @idTipoMovimientoAlta int,
            @idTipoMovimientoEdicion int,
            @idTipoPersonaCliente int,
            @idEstatusActual int,
            @claveEstatusActual varchar(50);

    IF ISNULL(@folioCliente,0) <= 0
    BEGIN
        RAISERROR('El cliente es obligatorio.',16,1);
        RETURN;
    END

    IF ISNULL(@idSucursal,0) <= 0
    BEGIN
        RAISERROR('La sucursal es obligatoria.',16,1);
        RETURN;
    END

    IF ISNULL(@idOrigenAgenda,0) <= 0
    BEGIN
        RAISERROR('El origen de la agenda es obligatorio.',16,1);
        RETURN;
    END

    IF @horaFinProgramada <= @horaInicioProgramada
    BEGIN
        RAISERROR('La hora fin programada debe ser mayor a la hora inicio programada.',16,1);
        RETURN;
    END

    IF CONVERT(date, @horaInicioProgramada) <> CONVERT(date, @horaFinProgramada)
    BEGIN
        RAISERROR('La agenda debe quedar dentro del mismo día.',16,1);
        RETURN;
    END

    IF CONVERT(date, @fechaCita) <> CONVERT(date, @horaInicioProgramada)
    BEGIN
        RAISERROR('La fecha de cita debe coincidir con la fecha de inicio programada.',16,1);
        RETURN;
    END

    SELECT @idTipoPersonaCliente = tp.id
    FROM dbo.cat_tiposPersonas tp
    WHERE tp.idEntidad = @idEntidad
      AND tp.descripcion = 'Cliente'
      AND ISNULL(tp.activo,1) = 1;

    IF ISNULL(@idTipoPersonaCliente,0) = 0
    BEGIN
        RAISERROR('No existe el tipo de persona Cliente.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_personas p
        WHERE p.id = @folioCliente
          AND p.idEntidad = @idEntidad
          AND p.idTipoPersona = @idTipoPersonaCliente
          AND ISNULL(p.activo,1) = 1
    )
    BEGIN
        RAISERROR('El cliente no existe, no pertenece a la entidad o no está activo.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_sucursales s
        WHERE s.idSucursal = @idSucursal
          AND s.idEntidad = @idEntidad
          AND ISNULL(s.activo,1) = 1
    )
    BEGIN
        RAISERROR('La sucursal no existe o no está activa.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_origenAgenda oa
        WHERE oa.idOrigenAgenda = @idOrigenAgenda
          AND oa.idEntidad = @idEntidad
          AND ISNULL(oa.activo,1) = 1
    )
    BEGIN
        RAISERROR('El origen de agenda no existe o no está activo.',16,1);
        RETURN;
    END

    SELECT @idEstatusAgenda = ea.idEstatusAgenda
    FROM dbo.cat_estatusAgenda ea
    WHERE ea.idEntidad = @idEntidad
      AND ea.clave = 'REGISTRADA'
      AND ISNULL(ea.activo,1) = 1;

    IF ISNULL(@idEstatusAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el estatus REGISTRADA para la agenda.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAlta = tma.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda tma
    WHERE tma.idEntidad = @idEntidad
      AND tma.clave = 'ALTA'
      AND ISNULL(tma.activo,1) = 1;

    SELECT @idTipoMovimientoEdicion = tma.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda tma
    WHERE tma.idEntidad = @idEntidad
      AND tma.clave = 'EDICION'
      AND ISNULL(tma.activo,1) = 1;

    IF @folioAgenda = 0
    BEGIN
        INSERT INTO dbo.proc_agenda
        (
            folioCliente, idSucursal, fechaCita, horaInicioProgramada, horaFinProgramada,
            idEstatusAgenda, idOrigenAgenda, confirmada, fechaConfirmacion, folioVenta,
            totalCotizado, totalPagado, requiereConfirmacion, observacionesInternas,
            comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
        )
        VALUES
        (
            @folioCliente, @idSucursal, @fechaCita, @horaInicioProgramada, @horaFinProgramada,
            @idEstatusAgenda, @idOrigenAgenda, 0, NULL, NULL,
            0, 0, @requiereConfirmacion, @observacionesInternas,
            @comentarios, @activo, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
        );

        SET @folioAgenda = SCOPE_IDENTITY();

        IF ISNULL(@idTipoMovimientoAlta,0) > 0
        BEGIN
            INSERT INTO dbo.proc_agendaBitacora
            (
                folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda, idEstatusAnterior, idEstatusNuevo,
                descripcionMovimiento, datosAntes, datosDespues, fechaMovimiento,
                comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
            )
            VALUES
            (
                @folioAgenda, NULL, @idTipoMovimientoAlta, NULL, @idEstatusAgenda,
                'Alta de agenda', NULL, NULL, GETDATE(),
                NULL, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
            );
        END
    END
    ELSE
    BEGIN
        SELECT
            @idEstatusActual = a.idEstatusAgenda,
            @claveEstatusActual = ea.clave
        FROM dbo.proc_agenda a
        INNER JOIN dbo.cat_estatusAgenda ea
            ON ea.idEstatusAgenda = a.idEstatusAgenda
           AND ea.idEntidad = a.idEntidad
        WHERE a.folioAgenda = @folioAgenda
          AND a.idEntidad = @idEntidad
          AND ISNULL(a.activo,1) = 1;

        IF ISNULL(@idEstatusActual,0) = 0
        BEGIN
            RAISERROR('La agenda no existe o no está activa.',16,1);
            RETURN;
        END

        IF @claveEstatusActual IN ('CANCELADA','CONCLUIDA')
        BEGIN
            RAISERROR('No se puede editar una agenda cancelada o concluida.',16,1);
            RETURN;
        END

        UPDATE dbo.proc_agenda
           SET folioCliente = @folioCliente,
               idSucursal = @idSucursal,
               fechaCita = @fechaCita,
               horaInicioProgramada = @horaInicioProgramada,
               horaFinProgramada = @horaFinProgramada,
               idOrigenAgenda = @idOrigenAgenda,
               requiereConfirmacion = @requiereConfirmacion,
               observacionesInternas = @observacionesInternas,
               comentarios = @comentarios,
               activo = @activo,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioModifica
         WHERE folioAgenda = @folioAgenda
           AND idEntidad = @idEntidad;

        IF ISNULL(@idTipoMovimientoEdicion,0) > 0
        BEGIN
            INSERT INTO dbo.proc_agendaBitacora
            (
                folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda, idEstatusAnterior, idEstatusNuevo,
                descripcionMovimiento, datosAntes, datosDespues, fechaMovimiento,
                comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
            )
            VALUES
            (
                @folioAgenda, NULL, @idTipoMovimientoEdicion, NULL, NULL,
                'Edición de agenda', NULL, NULL, GETDATE(),
                NULL, 1, @idEntidad, NULL, NULL, GETDATE(), ISNULL(@idUsuarioModifica,@idUsuarioAlta)
            );
        END
    END

    SELECT @folioAgenda AS folioAgenda;
END
GO

/* =========================================================
   2) DETALLE SERVICIO - ALTA / EDICION CON VALIDACIONES
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaDetalleServicio
(
    @folioAgendaDetalleServicio int = 0,
    @folioAgenda int,
    @idProductoServicio int,
    @precioFinal decimal(16,4),
    @descuento decimal(16,4) = NULL,
    @cantidad decimal(16,4) = 1,
    @ordenServicio int = 1,
    @horaInicioProgramada datetime = NULL,
    @horaFinProgramada datetime = NULL,
    @comentarios varchar(450) = NULL,
    @activo bit = 1,
    @idEntidad int,
    @idUsuarioModifica int = NULL,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @descripcionServicio varchar(250),
            @duracionEstimadaMin int,
            @precioLista decimal(16,4),
            @idEstatusAgendaDetalleServicio int,
            @idEstatusAgenda int,
            @claveEstatusAgenda varchar(50),
            @horaInicioAgenda datetime,
            @horaFinAgenda datetime;

    IF ISNULL(@folioAgenda,0) <= 0
    BEGIN
        RAISERROR('La agenda es obligatoria.',16,1);
        RETURN;
    END

    IF ISNULL(@idProductoServicio,0) <= 0
    BEGIN
        RAISERROR('El producto/servicio es obligatorio.',16,1);
        RETURN;
    END

    IF ISNULL(@cantidad,0) <= 0
    BEGIN
        RAISERROR('La cantidad debe ser mayor a 0.',16,1);
        RETURN;
    END

    IF ISNULL(@precioFinal,0) < 0
    BEGIN
        RAISERROR('El precio final no puede ser menor a 0.',16,1);
        RETURN;
    END

    SELECT
        @idEstatusAgenda = a.idEstatusAgenda,
        @claveEstatusAgenda = ea.clave,
        @horaInicioAgenda = a.horaInicioProgramada,
        @horaFinAgenda = a.horaFinProgramada
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF ISNULL(@idEstatusAgenda,0) = 0
    BEGIN
        RAISERROR('La agenda no existe o no está activa.',16,1);
        RETURN;
    END

    IF @claveEstatusAgenda IN ('CANCELADA','CONCLUIDA')
    BEGIN
        RAISERROR('No se pueden agregar o editar servicios en una agenda cancelada o concluida.',16,1);
        RETURN;
    END

    SELECT
        @descripcionServicio = ps.descripcion,
        @duracionEstimadaMin = ISNULL(ps.duracionBaseMin,0),
        @precioLista = ISNULL(precio.precioPrimera,0)
    FROM dbo.cat_productosServicios ps
    INNER JOIN dbo.cat_precios precio
        ON precio.idProductoServicio = ps.id
       AND precio.idEntidad = ps.idEntidad
    WHERE ps.id = @idProductoServicio
      AND ps.idEntidad = @idEntidad
      AND ISNULL(ps.activo,1) = 1
      AND ISNULL(ps.esServicio,0) = 1;

    IF @descripcionServicio IS NULL
    BEGIN
        RAISERROR('El producto/servicio indicado no existe o no está marcado como servicio.',16,1);
        RETURN;
    END

    IF ISNULL(@duracionEstimadaMin,0) <= 0
    BEGIN
        RAISERROR('El servicio no tiene duración válida.',16,1);
        RETURN;
    END

    IF @horaInicioProgramada IS NULL SET @horaInicioProgramada = @horaInicioAgenda;
    IF @horaFinProgramada IS NULL SET @horaFinProgramada = @horaFinAgenda;

    IF @horaFinProgramada <= @horaInicioProgramada
    BEGIN
        RAISERROR('La hora fin programada debe ser mayor a la hora inicio programada.',16,1);
        RETURN;
    END

    IF CONVERT(date, @horaInicioProgramada) <> CONVERT(date, @horaFinProgramada)
    BEGIN
        RAISERROR('El detalle del servicio debe quedar dentro del mismo día.',16,1);
        RETURN;
    END

    IF CONVERT(date, @horaInicioProgramada) <> CONVERT(date, @horaInicioAgenda)
    BEGIN
        RAISERROR('El detalle del servicio debe corresponder al mismo día de la agenda.',16,1);
        RETURN;
    END

    IF @horaInicioProgramada < @horaInicioAgenda OR @horaFinProgramada > @horaFinAgenda
    BEGIN
        RAISERROR('El horario del detalle debe estar dentro del rango horario de la agenda.',16,1);
        RETURN;
    END

    SELECT @idEstatusAgendaDetalleServicio = idEstatusAgendaDetalleServicio
    FROM dbo.cat_estatusAgendaDetalleServicio
    WHERE idEntidad = @idEntidad
      AND clave = 'PENDIENTE'
      AND ISNULL(activo,1) = 1;

    IF ISNULL(@idEstatusAgendaDetalleServicio,0) = 0
    BEGIN
        RAISERROR('No se encontró el estatus PENDIENTE para detalle de servicio.',16,1);
        RETURN;
    END

    IF @folioAgendaDetalleServicio = 0
    BEGIN
        INSERT INTO dbo.proc_agendaDetalleServicio
        (
            folioAgenda, idProductoServicio, descripcionServicio, duracionEstimadaMin,
            precioLista, precioFinal, descuento, cantidad, ordenServicio,
            horaInicioProgramada, horaFinProgramada, horaInicioReal, horaFinReal,
            idEstatusAgendaDetalleServicio, cancelado, motivoCancelacion,
            comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
        )
        VALUES
        (
            @folioAgenda, @idProductoServicio, @descripcionServicio, @duracionEstimadaMin,
            @precioLista, @precioFinal, @descuento, @cantidad, @ordenServicio,
            @horaInicioProgramada, @horaFinProgramada, NULL, NULL,
            @idEstatusAgendaDetalleServicio, 0, NULL,
            @comentarios, @activo, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
        );

        SET @folioAgendaDetalleServicio = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        DECLARE @claveEstatusDetalleActual varchar(50);

        SELECT @claveEstatusDetalleActual = ceds.clave
        FROM dbo.proc_agendaDetalleServicio ds
        INNER JOIN dbo.cat_estatusAgendaDetalleServicio ceds
            ON ceds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
           AND ceds.idEntidad = ds.idEntidad
        WHERE ds.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
          AND ds.idEntidad = @idEntidad
          AND ISNULL(ds.activo,1) = 1;

        IF @claveEstatusDetalleActual IS NULL
        BEGIN
            RAISERROR('El detalle de servicio no existe o no está activo.',16,1);
            RETURN;
        END

        IF @claveEstatusDetalleActual IN ('CANCELADO','CONCLUIDO')
        BEGIN
            RAISERROR('No se puede editar un detalle de servicio cancelado o concluido.',16,1);
            RETURN;
        END

        UPDATE dbo.proc_agendaDetalleServicio
           SET precioFinal = @precioFinal,
               descuento = @descuento,
               cantidad = @cantidad,
               ordenServicio = @ordenServicio,
               horaInicioProgramada = @horaInicioProgramada,
               horaFinProgramada = @horaFinProgramada,
               comentarios = @comentarios,
               activo = @activo,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioModifica
         WHERE folioAgendaDetalleServicio = @folioAgendaDetalleServicio
           AND idEntidad = @idEntidad;
    END

    UPDATE a
       SET totalCotizado = ISNULL((
            SELECT SUM(ISNULL(ds.precioFinal,0) * ISNULL(ds.cantidad,1))
            FROM dbo.proc_agendaDetalleServicio ds
            WHERE ds.folioAgenda = a.folioAgenda
              AND ds.idEntidad = a.idEntidad
              AND ISNULL(ds.activo,1) = 1
              AND ISNULL(ds.cancelado,0) = 0
        ),0),
           fechaModificacion = GETDATE(),
           idUsuarioModifica = ISNULL(@idUsuarioModifica,@idUsuarioAlta)
    FROM dbo.proc_agenda a
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad;

    SELECT @folioAgendaDetalleServicio AS folioAgendaDetalleServicio;
END
GO

/* =========================================================
   3) ASIGNACION EMPLEADO A DETALLE - CON VALIDACIONES
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaDetalleServicioEmpleado
(
    @folioAgendaDetalleServicioEmpleado int = 0,
    @folioAgendaDetalleServicio int,
    @folioEmpleado int,
    @idRolParticipacionServicio int,
    @porcentajeParticipacion decimal(16,4) = NULL,
    @comisionCalculada decimal(16,4) = NULL,
    @horaInicioReal datetime = NULL,
    @horaFinReal datetime = NULL,
    @comentarios varchar(450) = NULL,
    @activo bit = 1,
    @idEntidad int,
    @idUsuarioModifica int = NULL,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @folioAgenda int,
            @horaInicioProgramada datetime,
            @horaFinProgramada datetime,
            @fechaCita datetime,
            @horaInicioAgenda datetime,
            @horaFinAgenda datetime,
            @idEstatusAgenda int,
            @claveEstatusAgenda varchar(50),
            @claveEstatusDetalle varchar(50),
            @idTipoPersonaEmpleado int,
            @sumaPorcentajeActual decimal(16,4);

    IF ISNULL(@folioAgendaDetalleServicio,0) <= 0
    BEGIN
        RAISERROR('El detalle de servicio es obligatorio.',16,1);
        RETURN;
    END

    IF ISNULL(@folioEmpleado,0) <= 0
    BEGIN
        RAISERROR('El empleado es obligatorio.',16,1);
        RETURN;
    END

    IF ISNULL(@idRolParticipacionServicio,0) <= 0
    BEGIN
        RAISERROR('El rol de participación es obligatorio.',16,1);
        RETURN;
    END

    IF @porcentajeParticipacion IS NOT NULL
       AND (@porcentajeParticipacion < 0 OR @porcentajeParticipacion > 100)
    BEGIN
        RAISERROR('El porcentaje de participación debe estar entre 0 y 100.',16,1);
        RETURN;
    END

    IF @horaInicioReal IS NOT NULL
       AND @horaFinReal IS NOT NULL
       AND @horaFinReal <= @horaInicioReal
    BEGIN
        RAISERROR('La hora fin real debe ser mayor a la hora inicio real.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_rolParticipacionServicio rps
        WHERE rps.idRolParticipacionServicio = @idRolParticipacionServicio
          AND rps.idEntidad = @idEntidad
          AND ISNULL(rps.activo,1) = 1
    )
    BEGIN
        RAISERROR('El rol de participación no existe o no está activo.',16,1);
        RETURN;
    END

    SELECT @idTipoPersonaEmpleado = tp.id
    FROM dbo.cat_tiposPersonas tp
    WHERE tp.idEntidad = @idEntidad
      AND tp.descripcion = 'Empleado'
      AND ISNULL(tp.activo,1) = 1;

    IF ISNULL(@idTipoPersonaEmpleado,0) = 0
    BEGIN
        RAISERROR('No existe el tipo de persona Empleado.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_personas p
        WHERE p.id = @folioEmpleado
          AND p.idEntidad = @idEntidad
          AND p.idTipoPersona = @idTipoPersonaEmpleado
          AND ISNULL(p.activo,1) = 1
    )
    BEGIN
        RAISERROR('El empleado no existe, no pertenece a la entidad o no está activo.',16,1);
        RETURN;
    END

    SELECT
        @folioAgenda = ds.folioAgenda,
        @horaInicioProgramada = ds.horaInicioProgramada,
        @horaFinProgramada = ds.horaFinProgramada,
        @claveEstatusDetalle = ceds.clave
    FROM dbo.proc_agendaDetalleServicio ds
    INNER JOIN dbo.cat_estatusAgendaDetalleServicio ceds
        ON ceds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
       AND ceds.idEntidad = ds.idEntidad
    WHERE ds.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
      AND ds.idEntidad = @idEntidad
      AND ISNULL(ds.activo,1) = 1;

    IF ISNULL(@folioAgenda,0) = 0
    BEGIN
        RAISERROR('No existe el detalle de servicio indicado.',16,1);
        RETURN;
    END

    IF @claveEstatusDetalle IN ('CANCELADO','CONCLUIDO')
    BEGIN
        RAISERROR('No se puede asignar o editar empleado en un detalle cancelado o concluido.',16,1);
        RETURN;
    END

    SELECT
        @idEstatusAgenda = a.idEstatusAgenda,
        @claveEstatusAgenda = ea.clave,
        @fechaCita = a.fechaCita,
        @horaInicioAgenda = a.horaInicioProgramada,
        @horaFinAgenda = a.horaFinProgramada
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF ISNULL(@idEstatusAgenda,0) = 0
    BEGIN
        RAISERROR('La agenda asociada no existe o no está activa.',16,1);
        RETURN;
    END

    IF @claveEstatusAgenda IN ('CANCELADA','CONCLUIDA')
    BEGIN
        RAISERROR('No se puede asignar o editar empleado en una agenda cancelada o concluida.',16,1);
        RETURN;
    END

    SET @horaInicioProgramada = ISNULL(@horaInicioProgramada, @horaInicioAgenda);
    SET @horaFinProgramada = ISNULL(@horaFinProgramada, @horaFinAgenda);

    IF @horaInicioProgramada IS NULL OR @horaFinProgramada IS NULL OR @horaFinProgramada <= @horaInicioProgramada
    BEGIN
        RAISERROR('El detalle o la agenda no tienen un rango horario válido.',16,1);
        RETURN;
    END

    IF @horaInicioProgramada < @horaInicioAgenda OR @horaFinProgramada > @horaFinAgenda
    BEGIN
        RAISERROR('El horario del detalle está fuera del rango horario de la agenda.',16,1);
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.proc_agendaDetalleServicioEmpleado dse
        WHERE dse.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
          AND dse.folioEmpleado = @folioEmpleado
          AND dse.idEntidad = @idEntidad
          AND ISNULL(dse.activo,1) = 1
          AND (@folioAgendaDetalleServicioEmpleado = 0 OR dse.folioAgendaDetalleServicioEmpleado <> @folioAgendaDetalleServicioEmpleado)
    )
    BEGIN
        RAISERROR('El empleado ya está asignado a este detalle de servicio.',16,1);
        RETURN;
    END

    SELECT @sumaPorcentajeActual = ISNULL(SUM(ISNULL(dse.porcentajeParticipacion,0)),0)
    FROM dbo.proc_agendaDetalleServicioEmpleado dse
    WHERE dse.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
      AND dse.idEntidad = @idEntidad
      AND ISNULL(dse.activo,1) = 1
      AND (@folioAgendaDetalleServicioEmpleado = 0 OR dse.folioAgendaDetalleServicioEmpleado <> @folioAgendaDetalleServicioEmpleado);

    IF @porcentajeParticipacion IS NOT NULL
       AND (@sumaPorcentajeActual + @porcentajeParticipacion) > 100
    BEGIN
        RAISERROR('La suma del porcentaje de participación no puede exceder 100.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoHorario eh
        WHERE eh.folioEmpleado = @folioEmpleado
          AND eh.idEntidad = @idEntidad
          AND eh.diaSemana = DATEPART(WEEKDAY, @fechaCita)
          AND ISNULL(eh.activo,1) = 1
          AND CAST(@horaInicioProgramada AS time) >= CAST(eh.horaEntrada AS time)
          AND CAST(@horaFinProgramada AS time) <= CAST(eh.horaSalida AS time)
    )
    BEGIN
        RAISERROR('El empleado no tiene horario laboral disponible para ese rango.',16,1);
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.proc_empleadoBloqueoHorario ebh
        WHERE ebh.folioEmpleado = @folioEmpleado
          AND ebh.idEntidad = @idEntidad
          AND ISNULL(ebh.activo,1) = 1
          AND CONVERT(date, ebh.fecha) = CONVERT(date, @fechaCita)
          AND @horaInicioProgramada < ebh.horaFin
          AND @horaFinProgramada > ebh.horaInicio
    )
    BEGIN
        RAISERROR('El empleado tiene un bloqueo de horario en ese rango.',16,1);
        RETURN;
    END

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
        WHERE dse.folioEmpleado = @folioEmpleado
          AND dse.idEntidad = @idEntidad
          AND ISNULL(dse.activo,1) = 1
          AND ISNULL(ds.activo,1) = 1
          AND ISNULL(a.activo,1) = 1
          AND ISNULL(ds.cancelado,0) = 0
          AND dse.folioAgendaDetalleServicioEmpleado <> ISNULL(@folioAgendaDetalleServicioEmpleado,-1)
          AND CONVERT(date, a.fechaCita) = CONVERT(date, @fechaCita)
          AND @horaInicioProgramada < ISNULL(ds.horaFinProgramada, a.horaFinProgramada)
          AND @horaFinProgramada > ISNULL(ds.horaInicioProgramada, a.horaInicioProgramada)
    )
    BEGIN
        RAISERROR('El empleado ya tiene otro servicio asignado en ese horario.',16,1);
        RETURN;
    END

    IF @folioAgendaDetalleServicioEmpleado = 0
    BEGIN
        INSERT INTO dbo.proc_agendaDetalleServicioEmpleado
        (
            folioAgendaDetalleServicio, folioEmpleado, idRolParticipacionServicio,
            porcentajeParticipacion, comisionCalculada, horaInicioReal, horaFinReal,
            comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
        )
        VALUES
        (
            @folioAgendaDetalleServicio, @folioEmpleado, @idRolParticipacionServicio,
            @porcentajeParticipacion, @comisionCalculada, @horaInicioReal, @horaFinReal,
            @comentarios, @activo, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
        );

        SET @folioAgendaDetalleServicioEmpleado = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.proc_agendaDetalleServicioEmpleado
           SET folioEmpleado = @folioEmpleado,
               idRolParticipacionServicio = @idRolParticipacionServicio,
               porcentajeParticipacion = @porcentajeParticipacion,
               comisionCalculada = @comisionCalculada,
               horaInicioReal = @horaInicioReal,
               horaFinReal = @horaFinReal,
               comentarios = @comentarios,
               activo = @activo,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioModifica
         WHERE folioAgendaDetalleServicioEmpleado = @folioAgendaDetalleServicioEmpleado
           AND idEntidad = @idEntidad;
    END

    SELECT @folioAgendaDetalleServicioEmpleado AS folioAgendaDetalleServicioEmpleado;
END
GO

/* =========================================================
   4) CONFIRMAR AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_confirmarAgenda
(
    @folioAgenda int,
    @comentarios varchar(450) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAnterior int,
            @idEstatusNuevo int,
            @idTipoMovimientoAgenda int,
            @claveAnterior varchar(50);

    SELECT
        @idEstatusAnterior = a.idEstatusAgenda,
        @claveAnterior = ea.clave
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF ISNULL(@idEstatusAnterior,0) = 0
    BEGIN
        RAISERROR('No existe la agenda indicada.',16,1);
        RETURN;
    END

    IF @claveAnterior IN ('CANCELADA','CONCLUIDA')
    BEGIN
        RAISERROR('No se puede confirmar una agenda cancelada o concluida.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.proc_agendaDetalleServicio ds
        WHERE ds.folioAgenda = @folioAgenda
          AND ds.idEntidad = @idEntidad
          AND ISNULL(ds.activo,1) = 1
          AND ISNULL(ds.cancelado,0) = 0
    )
    BEGIN
        RAISERROR('No se puede confirmar una agenda sin servicios activos.',16,1);
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.proc_agendaDetalleServicio ds
        WHERE ds.folioAgenda = @folioAgenda
          AND ds.idEntidad = @idEntidad
          AND ISNULL(ds.activo,1) = 1
          AND ISNULL(ds.cancelado,0) = 0
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.proc_agendaDetalleServicioEmpleado dse
              WHERE dse.folioAgendaDetalleServicio = ds.folioAgendaDetalleServicio
                AND dse.idEntidad = ds.idEntidad
                AND ISNULL(dse.activo,1) = 1
          )
    )
    BEGIN
        RAISERROR('No se puede confirmar la agenda porque existen servicios sin empleado asignado.',16,1);
        RETURN;
    END

    SELECT @idEstatusNuevo = cea.idEstatusAgenda
    FROM dbo.cat_estatusAgenda cea
    WHERE cea.idEntidad = @idEntidad
      AND cea.clave = 'CONFIRMADA'
      AND ISNULL(cea.activo,1) = 1;

    IF ISNULL(@idEstatusNuevo,0) = 0
    BEGIN
        RAISERROR('No existe el estatus CONFIRMADA.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = ctm.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda ctm
    WHERE ctm.idEntidad = @idEntidad
      AND ctm.clave = 'CAMBIOESTATUS'
      AND ISNULL(ctm.activo,1) = 1;

    IF ISNULL(@idTipoMovimientoAgenda,0) = 0
    BEGIN
        RAISERROR('No existe el tipo de movimiento CAMBIOESTATUS.',16,1);
        RETURN;
    END

    UPDATE dbo.proc_agenda
       SET confirmada = 1,
           fechaConfirmacion = GETDATE(),
           idEstatusAgenda = @idEstatusNuevo,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgenda = @folioAgenda
       AND idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda,
        idEstatusAnterior, idEstatusNuevo, descripcionMovimiento,
        datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion,
        idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, NULL, @idTipoMovimientoAgenda,
        @idEstatusAnterior, @idEstatusNuevo, 'Confirmación de agenda',
        NULL, NULL, GETDATE(),
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgenda AS folioAgenda;
END
GO

/* =========================================================
   5) CAMBIO DE ESTATUS DE AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaCambioEstatus
(
    @folioAgenda int,
    @idEstatusAgendaNuevo int,
    @descripcionMovimiento varchar(450) = NULL,
    @comentarios varchar(450) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAnterior int,
            @claveEstatusAnterior varchar(50),
            @claveEstatusNuevo varchar(50),
            @idTipoMovimientoAgenda int;

    SELECT
        @idEstatusAnterior = a.idEstatusAgenda,
        @claveEstatusAnterior = ea.clave
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF ISNULL(@idEstatusAnterior,0) = 0
    BEGIN
        RAISERROR('No se encontró la agenda indicada.',16,1);
        RETURN;
    END

    SELECT @claveEstatusNuevo = ea.clave
    FROM dbo.cat_estatusAgenda ea
    WHERE ea.idEstatusAgenda = @idEstatusAgendaNuevo
      AND ea.idEntidad = @idEntidad
      AND ISNULL(ea.activo,1) = 1;

    IF @claveEstatusNuevo IS NULL
    BEGIN
        RAISERROR('No se encontró el nuevo estatus de agenda.',16,1);
        RETURN;
    END

    IF @idEstatusAnterior = @idEstatusAgendaNuevo
    BEGIN
        RAISERROR('La agenda ya se encuentra en el estatus indicado.',16,1);
        RETURN;
    END

    IF @claveEstatusAnterior IN ('CANCELADA','CONCLUIDA')
    BEGIN
        RAISERROR('No se puede cambiar el estatus de una agenda cancelada o concluida.',16,1);
        RETURN;
    END

    IF @claveEstatusNuevo = 'REGISTRADA'
    BEGIN
        RAISERROR('No se permite regresar una agenda a REGISTRADA.',16,1);
        RETURN;
    END

    IF @claveEstatusNuevo IN ('CONFIRMADA','ENPROCESO')
    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.proc_agendaDetalleServicio ds
            WHERE ds.folioAgenda = @folioAgenda
              AND ds.idEntidad = @idEntidad
              AND ISNULL(ds.activo,1) = 1
              AND ISNULL(ds.cancelado,0) = 0
        )
        BEGIN
            RAISERROR('La agenda no tiene servicios activos.',16,1);
            RETURN;
        END
    END

    IF @claveEstatusNuevo = 'CONCLUIDA'
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM dbo.proc_agendaDetalleServicio ds
            INNER JOIN dbo.cat_estatusAgendaDetalleServicio eds
                ON eds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
               AND eds.idEntidad = ds.idEntidad
            WHERE ds.folioAgenda = @folioAgenda
              AND ds.idEntidad = @idEntidad
              AND ISNULL(ds.activo,1) = 1
              AND eds.clave NOT IN ('CONCLUIDO','CANCELADO')
        )
        BEGIN
            RAISERROR('No se puede concluir la agenda mientras existan servicios pendientes, asignados o en proceso.',16,1);
            RETURN;
        END
    END

    SELECT @idTipoMovimientoAgenda = idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda
    WHERE idEntidad = @idEntidad
      AND clave = 'CAMBIOESTATUS'
      AND ISNULL(activo,1) = 1;

    IF ISNULL(@idTipoMovimientoAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el tipo de movimiento CAMBIOESTATUS.',16,1);
        RETURN;
    END

    UPDATE dbo.proc_agenda
       SET idEstatusAgenda = @idEstatusAgendaNuevo,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgenda = @folioAgenda
       AND idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda, idEstatusAnterior, idEstatusNuevo,
        descripcionMovimiento, datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, NULL, @idTipoMovimientoAgenda, @idEstatusAnterior, @idEstatusAgendaNuevo,
        ISNULL(@descripcionMovimiento,'Cambio de estatus de agenda'), NULL, NULL, GETDATE(),
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgenda AS folioAgenda;
END
GO

/* =========================================================
   6) CAMBIO DE ESTATUS DETALLE SERVICIO
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaCambioEstatusDetalleServicio
(
    @folioAgendaDetalleServicio int,
    @idEstatusAgendaDetalleServicioNuevo int,
    @descripcionMovimiento varchar(450) = NULL,
    @comentarios varchar(450) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAnterior int,
            @folioAgenda int,
            @idTipoMovimientoAgenda int,
            @claveNuevo varchar(50),
            @claveAnterior varchar(50),
            @claveAgenda varchar(50);

    SELECT
        @idEstatusAnterior = ds.idEstatusAgendaDetalleServicio,
        @folioAgenda = ds.folioAgenda,
        @claveAnterior = eds.clave
    FROM dbo.proc_agendaDetalleServicio ds
    INNER JOIN dbo.cat_estatusAgendaDetalleServicio eds
        ON eds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
       AND eds.idEntidad = ds.idEntidad
    WHERE ds.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
      AND ds.idEntidad = @idEntidad
      AND ISNULL(ds.activo,1) = 1;

    IF @folioAgenda IS NULL
    BEGIN
        RAISERROR('No existe el detalle de servicio indicado.',16,1);
        RETURN;
    END

    SELECT @claveAgenda = ea.clave
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF @claveAgenda IN ('CANCELADA','CONCLUIDA')
    BEGIN
        RAISERROR('No se puede cambiar el estatus de un detalle cuando la agenda está cancelada o concluida.',16,1);
        RETURN;
    END

    SELECT @claveNuevo = clave
    FROM dbo.cat_estatusAgendaDetalleServicio
    WHERE idEstatusAgendaDetalleServicio = @idEstatusAgendaDetalleServicioNuevo
      AND idEntidad = @idEntidad
      AND ISNULL(activo,1) = 1;

    IF @claveNuevo IS NULL
    BEGIN
        RAISERROR('No existe el nuevo estatus del detalle de servicio.',16,1);
        RETURN;
    END

    IF @idEstatusAnterior = @idEstatusAgendaDetalleServicioNuevo
    BEGIN
        RAISERROR('El detalle ya se encuentra en el estatus indicado.',16,1);
        RETURN;
    END

    IF @claveAnterior IN ('CANCELADO','CONCLUIDO')
    BEGIN
        RAISERROR('No se puede cambiar el estatus de un detalle cancelado o concluido.',16,1);
        RETURN;
    END

    IF @claveNuevo = 'PENDIENTE'
    BEGIN
        RAISERROR('No se permite regresar un detalle a PENDIENTE.',16,1);
        RETURN;
    END

    IF @claveNuevo = 'ENPROCESO'
    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.proc_agendaDetalleServicioEmpleado dse
            WHERE dse.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
              AND dse.idEntidad = @idEntidad
              AND ISNULL(dse.activo,1) = 1
        )
        BEGIN
            RAISERROR('No se puede iniciar un servicio sin empleado asignado.',16,1);
            RETURN;
        END
    END

    IF @claveNuevo = 'CONCLUIDO'
    BEGIN
        IF @claveAnterior NOT IN ('ASIGNADO','ENPROCESO')
        BEGIN
            RAISERROR('Solo se puede concluir un detalle asignado o en proceso.',16,1);
            RETURN;
        END
    END

    IF @claveNuevo = 'CANCELADO' AND @claveAnterior = 'CONCLUIDO'
    BEGIN
        RAISERROR('No se puede cancelar un detalle concluido.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda
    WHERE idEntidad = @idEntidad
      AND clave = 'CAMBIOESTATUS'
      AND ISNULL(activo,1) = 1;

    IF ISNULL(@idTipoMovimientoAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el tipo de movimiento CAMBIOESTATUS.',16,1);
        RETURN;
    END

    UPDATE dbo.proc_agendaDetalleServicio
       SET idEstatusAgendaDetalleServicio = @idEstatusAgendaDetalleServicioNuevo,
           cancelado = CASE WHEN @claveNuevo = 'CANCELADO' THEN 1 ELSE cancelado END,
           motivoCancelacion = CASE WHEN @claveNuevo = 'CANCELADO' THEN ISNULL(@descripcionMovimiento,@comentarios) ELSE motivoCancelacion END,
           horaInicioReal = CASE WHEN @claveNuevo = 'ENPROCESO' AND horaInicioReal IS NULL THEN GETDATE() ELSE horaInicioReal END,
           horaFinReal = CASE WHEN @claveNuevo = 'CONCLUIDO' THEN GETDATE() ELSE horaFinReal END,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgendaDetalleServicio = @folioAgendaDetalleServicio
       AND idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda,
        idEstatusAnterior, idEstatusNuevo, descripcionMovimiento,
        datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, @folioAgendaDetalleServicio, @idTipoMovimientoAgenda,
        @idEstatusAnterior, @idEstatusAgendaDetalleServicioNuevo,
        ISNULL(@descripcionMovimiento,'Cambio de estatus de detalle de servicio'),
        NULL, NULL, GETDATE(),
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgendaDetalleServicio AS folioAgendaDetalleServicio;
END
GO

/* =========================================================
   7) CANCELAR DETALLE DE SERVICIO
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_cancelarDetalleServicio
(
    @folioAgendaDetalleServicio int,
    @motivoCancelacion varchar(450),
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @folioAgenda int,
            @idEstatusAnterior int,
            @idEstatusNuevo int,
            @idTipoMovimientoAgenda int,
            @claveEstatusAnterior varchar(50),
            @claveAgenda varchar(50);

    IF ISNULL(LTRIM(RTRIM(ISNULL(@motivoCancelacion,''))),'') = ''
    BEGIN
        RAISERROR('El motivo de cancelación es obligatorio.',16,1);
        RETURN;
    END

    SELECT
        @folioAgenda = ds.folioAgenda,
        @idEstatusAnterior = ds.idEstatusAgendaDetalleServicio,
        @claveEstatusAnterior = eds.clave
    FROM dbo.proc_agendaDetalleServicio ds
    INNER JOIN dbo.cat_estatusAgendaDetalleServicio eds
        ON eds.idEstatusAgendaDetalleServicio = ds.idEstatusAgendaDetalleServicio
       AND eds.idEntidad = ds.idEntidad
    WHERE ds.folioAgendaDetalleServicio = @folioAgendaDetalleServicio
      AND ds.idEntidad = @idEntidad
      AND ISNULL(ds.activo,1) = 1;

    IF ISNULL(@folioAgenda,0) = 0
    BEGIN
        RAISERROR('No existe el detalle de servicio indicado.',16,1);
        RETURN;
    END

    IF @claveEstatusAnterior = 'CANCELADO'
    BEGIN
        RAISERROR('El detalle de servicio ya está cancelado.',16,1);
        RETURN;
    END

    IF @claveEstatusAnterior = 'CONCLUIDO'
    BEGIN
        RAISERROR('No se puede cancelar un detalle concluido.',16,1);
        RETURN;
    END

    SELECT @claveAgenda = ea.clave
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF @claveAgenda IN ('CANCELADA','CONCLUIDA')
    BEGIN
        RAISERROR('No se puede cancelar un detalle cuando la agenda está cancelada o concluida.',16,1);
        RETURN;
    END

    SELECT @idEstatusNuevo = ceds.idEstatusAgendaDetalleServicio
    FROM dbo.cat_estatusAgendaDetalleServicio ceds
    WHERE ceds.idEntidad = @idEntidad
      AND ceds.clave = 'CANCELADO'
      AND ISNULL(ceds.activo,1) = 1;

    IF ISNULL(@idEstatusNuevo,0) = 0
    BEGIN
        RAISERROR('No existe el estatus CANCELADO para detalle.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = ctm.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda ctm
    WHERE ctm.idEntidad = @idEntidad
      AND ctm.clave = 'CAMBIOESTATUS'
      AND ISNULL(ctm.activo,1) = 1;

    IF ISNULL(@idTipoMovimientoAgenda,0) = 0
    BEGIN
        RAISERROR('No existe el tipo de movimiento CAMBIOESTATUS.',16,1);
        RETURN;
    END

    UPDATE dbo.proc_agendaDetalleServicio
       SET idEstatusAgendaDetalleServicio = @idEstatusNuevo,
           cancelado = 1,
           motivoCancelacion = @motivoCancelacion,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgendaDetalleServicio = @folioAgendaDetalleServicio
       AND idEntidad = @idEntidad;

    UPDATE a
       SET totalCotizado = ISNULL((
            SELECT SUM(ISNULL(ds.precioFinal,0) * ISNULL(ds.cantidad,1))
            FROM dbo.proc_agendaDetalleServicio ds
            WHERE ds.folioAgenda = a.folioAgenda
              AND ds.idEntidad = a.idEntidad
              AND ISNULL(ds.activo,1) = 1
              AND ISNULL(ds.cancelado,0) = 0
        ),0),
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
    FROM dbo.proc_agenda a
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda,
        idEstatusAnterior, idEstatusNuevo, descripcionMovimiento,
        datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion,
        idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, @folioAgendaDetalleServicio, @idTipoMovimientoAgenda,
        @idEstatusAnterior, @idEstatusNuevo, 'Cancelación de detalle de servicio',
        NULL, NULL, GETDATE(),
        @motivoCancelacion, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgendaDetalleServicio AS folioAgendaDetalleServicio;
END
GO

/* =========================================================
   8) CANCELAR AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_cancelarAgenda
(
    @folioAgenda int,
    @motivoCancelacion varchar(450),
    @cancelarDetalles bit = 1,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEstatusAnterior int,
            @idEstatusNuevo int,
            @idTipoMovimientoAgenda int,
            @idEstatusDetalleCancelado int,
            @claveEstatusAnterior varchar(50);

    IF ISNULL(LTRIM(RTRIM(ISNULL(@motivoCancelacion,''))),'') = ''
    BEGIN
        RAISERROR('El motivo de cancelación es obligatorio.',16,1);
        RETURN;
    END

    SELECT
        @idEstatusAnterior = a.idEstatusAgenda,
        @claveEstatusAnterior = ea.clave
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF ISNULL(@idEstatusAnterior,0) = 0
    BEGIN
        RAISERROR('No existe la agenda indicada.',16,1);
        RETURN;
    END

    IF @claveEstatusAnterior = 'CANCELADA'
    BEGIN
        RAISERROR('La agenda ya está cancelada.',16,1);
        RETURN;
    END

    IF @claveEstatusAnterior = 'CONCLUIDA'
    BEGIN
        RAISERROR('No se puede cancelar una agenda concluida.',16,1);
        RETURN;
    END

    SELECT @idEstatusNuevo = cea.idEstatusAgenda
    FROM dbo.cat_estatusAgenda cea
    WHERE cea.idEntidad = @idEntidad
      AND cea.clave = 'CANCELADA'
      AND ISNULL(cea.activo,1) = 1;

    IF ISNULL(@idEstatusNuevo,0) = 0
    BEGIN
        RAISERROR('No existe el estatus CANCELADA.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = ctm.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda ctm
    WHERE ctm.idEntidad = @idEntidad
      AND ctm.clave = 'CAMBIOESTATUS'
      AND ISNULL(ctm.activo,1) = 1;

    IF ISNULL(@idTipoMovimientoAgenda,0) = 0
    BEGIN
        RAISERROR('No existe el tipo de movimiento CAMBIOESTATUS.',16,1);
        RETURN;
    END

    SELECT @idEstatusDetalleCancelado = ceds.idEstatusAgendaDetalleServicio
    FROM dbo.cat_estatusAgendaDetalleServicio ceds
    WHERE ceds.idEntidad = @idEntidad
      AND ceds.clave = 'CANCELADO'
      AND ISNULL(ceds.activo,1) = 1;

    UPDATE dbo.proc_agenda
       SET idEstatusAgenda = @idEstatusNuevo,
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
     WHERE folioAgenda = @folioAgenda
       AND idEntidad = @idEntidad;

    IF @cancelarDetalles = 1 AND ISNULL(@idEstatusDetalleCancelado,0) > 0
    BEGIN
        UPDATE dbo.proc_agendaDetalleServicio
           SET idEstatusAgendaDetalleServicio = CASE 
                                                    WHEN EXISTS
                                                    (
                                                        SELECT 1
                                                        FROM dbo.cat_estatusAgendaDetalleServicio eds
                                                        WHERE eds.idEstatusAgendaDetalleServicio = @idEstatusDetalleCancelado
                                                          AND eds.idEntidad = @idEntidad
                                                    ) THEN @idEstatusDetalleCancelado
                                                    ELSE idEstatusAgendaDetalleServicio
                                                END,
               cancelado = CASE WHEN ISNULL(cancelado,0) = 0 THEN 1 ELSE cancelado END,
               motivoCancelacion = CASE WHEN ISNULL(cancelado,0) = 0 THEN @motivoCancelacion ELSE motivoCancelacion END,
               fechaModificacion = GETDATE(),
               idUsuarioModifica = @idUsuarioAlta
         WHERE folioAgenda = @folioAgenda
           AND idEntidad = @idEntidad
           AND ISNULL(activo,1) = 1
           AND ISNULL(cancelado,0) = 0
           AND idEstatusAgendaDetalleServicio NOT IN
               (
                   SELECT idEstatusAgendaDetalleServicio
                   FROM dbo.cat_estatusAgendaDetalleServicio
                   WHERE idEntidad = @idEntidad
                     AND clave = 'CONCLUIDO'
               );
    END

    UPDATE a
       SET totalCotizado = ISNULL((
            SELECT SUM(ISNULL(ds.precioFinal,0) * ISNULL(ds.cantidad,1))
            FROM dbo.proc_agendaDetalleServicio ds
            WHERE ds.folioAgenda = a.folioAgenda
              AND ds.idEntidad = a.idEntidad
              AND ISNULL(ds.activo,1) = 1
              AND ISNULL(ds.cancelado,0) = 0
        ),0),
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
    FROM dbo.proc_agenda a
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda,
        idEstatusAnterior, idEstatusNuevo, descripcionMovimiento,
        datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion,
        idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, NULL, @idTipoMovimientoAgenda,
        @idEstatusAnterior, @idEstatusNuevo, 'Cancelación de agenda',
        NULL, NULL, GETDATE(),
        @motivoCancelacion, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgenda AS folioAgenda;
END
GO

/* =========================================================
   9) REPROGRAMACION DE AGENDA
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaReprogramacion
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
        ON ea.idEstatusAgenda = a.idEstatusAgenda
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

    SELECT @idTipoMovimientoAgenda = ctm.idTipoMovimientoAgenda
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
GO

/* =========================================================
   10) PAGO DE AGENDA - ALTA CON VALIDACIONES
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ui_agendaPago
(
    @folioAgenda int,
    @idTipoMovimientoPagoAgenda int,
    @idTipoPago int,
    @montoPago decimal(16,4),
    @numeroAutorizacion varchar(250) = NULL,
    @referenciaOperacion varchar(250) = NULL,
    @referenciaExterna varchar(250) = NULL,
    @comentarios varchar(450) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @folioAgendaPago int,
            @idEstatusPagoAgenda int,
            @idTipoMovimientoAgenda int,
            @idEstatusAgenda int,
            @claveEstatusAgenda varchar(50),
            @totalCotizado decimal(16,4),
            @totalPagadoActual decimal(16,4),
            @saldoPendiente decimal(16,4),
            @claveTipoMovimientoPago varchar(50);

    IF ISNULL(@folioAgenda,0) <= 0
    BEGIN
        RAISERROR('La agenda es obligatoria.',16,1);
        RETURN;
    END

    IF ISNULL(@idTipoMovimientoPagoAgenda,0) <= 0
    BEGIN
        RAISERROR('El tipo de movimiento de pago es obligatorio.',16,1);
        RETURN;
    END

    IF ISNULL(@idTipoPago,0) <= 0
    BEGIN
        RAISERROR('El tipo de pago es obligatorio.',16,1);
        RETURN;
    END

    IF ISNULL(@montoPago,0) <= 0
    BEGIN
        RAISERROR('El monto de pago debe ser mayor a 0.',16,1);
        RETURN;
    END

    SELECT
        @idEstatusAgenda = a.idEstatusAgenda,
        @claveEstatusAgenda = ea.clave,
        @totalCotizado = ISNULL(a.totalCotizado,0),
        @totalPagadoActual = ISNULL(a.totalPagado,0)
    FROM dbo.proc_agenda a
    INNER JOIN dbo.cat_estatusAgenda ea
        ON ea.idEstatusAgenda = a.idEstatusAgenda
       AND ea.idEntidad = a.idEntidad
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad
      AND ISNULL(a.activo,1) = 1;

    IF ISNULL(@idEstatusAgenda,0) = 0
    BEGIN
        RAISERROR('La agenda no existe o no está activa.',16,1);
        RETURN;
    END

    IF @claveEstatusAgenda IN ('CANCELADA','CONCLUIDA')
    BEGIN
        RAISERROR('No se pueden registrar pagos en una agenda cancelada o concluida.',16,1);
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_tipoMovimientoPagoAgenda tmpa
        WHERE tmpa.idTipoMovimientoPagoAgenda = @idTipoMovimientoPagoAgenda
          AND tmpa.idEntidad = @idEntidad
          AND ISNULL(tmpa.activo,1) = 1
    )
    BEGIN
        RAISERROR('El tipo de movimiento de pago no existe o no está activo.',16,1);
        RETURN;
    END

    SELECT @claveTipoMovimientoPago = tmpa.clave
    FROM dbo.cat_tipoMovimientoPagoAgenda tmpa
    WHERE tmpa.idTipoMovimientoPagoAgenda = @idTipoMovimientoPagoAgenda
      AND tmpa.idEntidad = @idEntidad
      AND ISNULL(tmpa.activo,1) = 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_tiposPago tp
        WHERE tp.id = @idTipoPago
          AND ISNULL(tp.activo,1) = 1
    )
    BEGIN
        RAISERROR('El tipo de pago no existe o no está activo.',16,1);
        RETURN;
    END

    SELECT @idEstatusPagoAgenda = epa.idEstatusPagoAgenda
    FROM dbo.cat_estatusPagoAgenda epa
    WHERE epa.idEntidad = @idEntidad
      AND epa.clave = 'APLICADO'
      AND ISNULL(epa.activo,1) = 1;

    IF ISNULL(@idEstatusPagoAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el estatus de pago APLICADO.',16,1);
        RETURN;
    END

    SELECT @idTipoMovimientoAgenda = tma.idTipoMovimientoAgenda
    FROM dbo.cat_tipoMovimientoAgenda tma
    WHERE tma.idEntidad = @idEntidad
      AND tma.clave = 'PAGO'
      AND ISNULL(tma.activo,1) = 1;

    IF ISNULL(@idTipoMovimientoAgenda,0) = 0
    BEGIN
        RAISERROR('No se encontró el tipo de movimiento PAGO.',16,1);
        RETURN;
    END

    IF ISNULL(@totalCotizado,0) <= 0
    BEGIN
        RAISERROR('La agenda no tiene total cotizado válido para registrar pago.',16,1);
        RETURN;
    END

    SET @saldoPendiente = ISNULL(@totalCotizado,0) - ISNULL(@totalPagadoActual,0);

    IF @claveTipoMovimientoPago IN ('ANTICIPO','LIQUIDACION')
    BEGIN
        IF @saldoPendiente <= 0
        BEGIN
            RAISERROR('La agenda ya no tiene saldo pendiente.',16,1);
            RETURN;
        END

        IF @montoPago > @saldoPendiente
        BEGIN
            RAISERROR('El monto de pago excede el saldo pendiente de la agenda.',16,1);
            RETURN;
        END
    END

    INSERT INTO dbo.proc_agendaPago
    (
        folioAgenda, idTipoMovimientoPagoAgenda, idEstatusPagoAgenda, montoTotal,
        fechaPago, referenciaExterna, comentarios, activo, idEntidad,
        fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, @idTipoMovimientoPagoAgenda, @idEstatusPagoAgenda, @montoPago,
        GETDATE(), @referenciaExterna, @comentarios, 1, @idEntidad,
        NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SET @folioAgendaPago = SCOPE_IDENTITY();

    INSERT INTO dbo.proc_agendaPagoDetalle
    (
        folioAgendaPago, idTipoPago, montoPago, numeroAutorizacion, referenciaOperacion,
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgendaPago, @idTipoPago, @montoPago, @numeroAutorizacion, @referenciaOperacion,
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    UPDATE a
       SET totalPagado = ISNULL((
            SELECT SUM(ISNULL(ap.montoTotal,0))
            FROM dbo.proc_agendaPago ap
            WHERE ap.folioAgenda = a.folioAgenda
              AND ap.idEntidad = a.idEntidad
              AND ISNULL(ap.activo,1) = 1
        ),0),
           fechaModificacion = GETDATE(),
           idUsuarioModifica = @idUsuarioAlta
    FROM dbo.proc_agenda a
    WHERE a.folioAgenda = @folioAgenda
      AND a.idEntidad = @idEntidad;

    INSERT INTO dbo.proc_agendaBitacora
    (
        folioAgenda, folioAgendaDetalleServicio, idTipoMovimientoAgenda, idEstatusAnterior, idEstatusNuevo,
        descripcionMovimiento, datosAntes, datosDespues, fechaMovimiento,
        comentarios, activo, idEntidad, fechaModificacion, idUsuarioModifica, fechaAlta, idUsuarioAlta
    )
    VALUES
    (
        @folioAgenda, NULL, @idTipoMovimientoAgenda, NULL, NULL,
        'Registro de pago de agenda', NULL, NULL, GETDATE(),
        @comentarios, 1, @idEntidad, NULL, NULL, GETDATE(), @idUsuarioAlta
    );

    SELECT @folioAgendaPago AS folioAgendaPago;
END
GO

/* =========================================================
   11) CONSULTA HORARIOS Y BLOQUEOS 
   ========================================================= */
   CREATE OR ALTER PROCEDURE dbo.sp_se_empleadoHorario
(
    @folioEmpleado int,
    @idEntidad int
)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(@folioEmpleado,0) <= 0
    BEGIN
        RAISERROR('El empleado es obligatorio.',16,1);
        RETURN;
    END

    SELECT
        eh.folioEmpleadoHorario,
        eh.folioEmpleado,
        eh.diaSemana,
        eh.horaEntrada,
        eh.horaSalida,
        eh.comentarios,
        eh.activo,
        eh.idEntidad,
        eh.fechaModificacion,
        eh.idUsuarioModifica,
        eh.fechaAlta,
        eh.idUsuarioAlta
    FROM dbo.proc_empleadoHorario eh
    WHERE eh.folioEmpleado = @folioEmpleado
      AND eh.idEntidad = @idEntidad
    ORDER BY eh.diaSemana, eh.horaEntrada;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_se_empleadoBloqueoHorario
(
    @folioEmpleado int,
    @idEntidad int,
    @fechaInicio datetime = NULL,
    @fechaFin datetime = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(@folioEmpleado,0) <= 0
    BEGIN
        RAISERROR('El empleado es obligatorio.',16,1);
        RETURN;
    END

    SELECT
        ebh.folioEmpleadoBloqueoHorario,
        ebh.folioEmpleado,
        ebh.fecha,
        ebh.horaInicio,
        ebh.horaFin,
        ebh.idTipoBloqueoHorario,
        tbh.descripcion AS tipoBloqueoHorario,
        ebh.motivo,
        ebh.comentarios,
        ebh.activo,
        ebh.idEntidad,
        ebh.fechaModificacion,
        ebh.idUsuarioModifica,
        ebh.fechaAlta,
        ebh.idUsuarioAlta
    FROM dbo.proc_empleadoBloqueoHorario ebh
    INNER JOIN dbo.cat_tipoBloqueoHorario tbh
        ON tbh.idTipoBloqueoHorario = ebh.idTipoBloqueoHorario
       AND tbh.idEntidad = ebh.idEntidad
    WHERE ebh.folioEmpleado = @folioEmpleado
      AND ebh.idEntidad = @idEntidad
      AND (@fechaInicio IS NULL OR CONVERT(date, ebh.fecha) >= CONVERT(date, @fechaInicio))
      AND (@fechaFin IS NULL OR CONVERT(date, ebh.fecha) <= CONVERT(date, @fechaFin))
    ORDER BY ebh.fecha, ebh.horaInicio;
END
GO

---- 
Select * From cat_productosServicios where identidad = 10007
Select * From cat_precios
Select * From cat_tiposPersonas where descripcion = 'Cliente'  And idEntidad = 10007
Select * From cat_tiposPersonas where descripcion = 'Empleado' And idEntidad = 10007
Select * From cat_personas where  idTipoPersona IN( 29,30) and idEntidad = 10007
Select * From cat_sucursales where idEntidad = 10007
Select * From cat_tiposPago 
Select * From proc_entradasSalidas
Select * From proc_entradasSalidasDetalles
Select * From proc_entradasSalidaPago
Select * From cat_estatusAgenda
Select * From cat_estatusAgendaDetalleServicio
Select * From cat_origenAgenda
Select * From cat_tipoMovimientoAgenda
Select * From cat_tipoMovimientoPagoAgenda
Select * From cat_estatusPagoAgenda
Select * From cat_tipoBloqueoHorario
Select * From cat_rolParticipacionServicio
Select * From proc_empleadoHorario
Select * From proc_empleadoBloqueoHorario
Select * From proc_agenda
Select * From proc_agendaDetalleServicio
Select * From proc_agendaDetalleServicioEmpleado
Select * From proc_agendaPago
Select * From proc_agendaPagoDetalle
Select * From proc_agendaBitacora
Select * From proc_agendaReprogramacion
-- 

