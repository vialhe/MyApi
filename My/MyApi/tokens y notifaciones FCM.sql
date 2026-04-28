-- ------------------------------------------------------------------------
--	TABLAS
-- ------------------------------------------------------------------------
Select * From sys_tokenFCM
Select * From sys_notificacionesFCM

-- ------------------------------------------------------------------------
--	REQUERIMIENTO
-- ------------------------------------------------------------------------
--Para esta tabla "sys_tokenFCM" ocupo los siguientes sp:
--GuardaToken* - Cuando es la primera vez que inicio sesion en la app.
--ActualizaTokenUltimaConexion* : Este voy a usarlo cada vez que entro a la app.
--ObtieneListaTokenPorUsuario* : Lista de token activos por usuario.
--ObtieneListaTokenPorEntidad* :Lista de token activos por entidad. --este será el misma SP del punto anterior pero se enviara usuario = 0.
--Para esta tabla:sys_notifacionesFCM
--InsertaNotificacionPorUsuario:Solo para insertar a la tabla por usuario
--InsertaNotificacionPorEntidad:Solo para insertar a la tabla por entidad
--InsertaNotificacionGeneral:*: Solo para insertar a la tabla por entidad
--ObtieneListaNotificacionPorUsuario* :Obtiene lista de notificaciones pendientes por usuario,
--ObtieneListaNotificacionPorEntidad* :Obtiene lista de notificaciones pendientes por usuario,
--ObtieneListaNotificacionPorGeneral* :Obtiene lista de notificaciones pendientes por usuario,


-- ------------------------------------------------------------------------
--	SP DEFINIDOS ( FUNCIONAN DE MARAVILLA )
-- ------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbo.sp_ui_guardaTokenFCM
(
    @idUsuario int,
    @token varchar(450),
    @dispositivo varchar(50),
    @plataforma varchar(50),
    @versionApp varchar(50),
    @comentarios varchar(250) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @idTokenFCM int,
        @accion varchar(30),
        @fechaActual datetime = GETDATE();

    SET @token = NULLIF(LTRIM(RTRIM(@token)), '');
    SET @dispositivo = NULLIF(LTRIM(RTRIM(@dispositivo)), '');
    SET @plataforma = NULLIF(LTRIM(RTRIM(@plataforma)), '');
    SET @versionApp = NULLIF(LTRIM(RTRIM(@versionApp)), '');
    SET @comentarios = NULLIF(LTRIM(RTRIM(@comentarios)), '');

    IF ISNULL(@idUsuario,0) <= 0
    BEGIN
        RAISERROR('El idUsuario es obligatorio.',16,1);
        RETURN;
    END;

    IF ISNULL(@idEntidad,0) <= 0
    BEGIN
        RAISERROR('El idEntidad es obligatorio.',16,1);
        RETURN;
    END;

    IF @token IS NULL
    BEGIN
        RAISERROR('El token FCM es obligatorio.',16,1);
        RETURN;
    END;

    IF @dispositivo IS NULL
    BEGIN
        RAISERROR('El dispositivo es obligatorio.',16,1);
        RETURN;
    END;

    IF @plataforma IS NULL
    BEGIN
        RAISERROR('La plataforma es obligatoria.',16,1);
        RETURN;
    END;

    IF @versionApp IS NULL
    BEGIN
        RAISERROR('La versionApp es obligatoria.',16,1);
        RETURN;
    END;

    IF ISNULL(@idUsuarioAlta,0) <= 0
    BEGIN
        RAISERROR('El idUsuarioAlta es obligatorio.',16,1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRAN;

        SELECT TOP 1
            @idTokenFCM = id
        FROM dbo.sys_tokenFCM WITH (UPDLOCK, HOLDLOCK)
        WHERE idEntidad = @idEntidad
          AND token = @token
        ORDER BY 
            activo DESC,
            fechaUltimaConexion DESC,
            id DESC;

        IF @idTokenFCM IS NULL
        BEGIN
            INSERT INTO dbo.sys_tokenFCM
            (
                idUsuario,
                token,
                dispositivo,
                plataforma,
                fechaUltimaConexion,
                versionApp,
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
                @idUsuario,
                @token,
                @dispositivo,
                @plataforma,
                @fechaActual,
                @versionApp,
                @comentarios,
                1,
                @idEntidad,
                NULL,
                NULL,
                @fechaActual,
                @idUsuarioAlta
            );

            SET @idTokenFCM = SCOPE_IDENTITY();
            SET @accion = 'INSERTADO';
        END
        ELSE
        BEGIN
            UPDATE dbo.sys_tokenFCM
            SET
                idUsuario = @idUsuario,
                dispositivo = @dispositivo,
                plataforma = @plataforma,
                fechaUltimaConexion = @fechaActual,
                versionApp = @versionApp,
                comentarios = ISNULL(@comentarios, comentarios),
                activo = 1,
                fechaModificacion = @fechaActual,
                idUsuarioModifica = @idUsuarioAlta
            WHERE id = @idTokenFCM;

            SET @accion = 'ACTUALIZADO';
        END;

        /* Blindaje: si ya existían duplicados del mismo token, deja activo solo el más reciente */
        UPDATE dbo.sys_tokenFCM
        SET
            activo = 0,
            fechaModificacion = @fechaActual,
            idUsuarioModifica = @idUsuarioAlta,
            comentarios = ISNULL(comentarios, 'Token duplicado desactivado automáticamente.')
        WHERE idEntidad = @idEntidad
          AND token = @token
          AND id <> @idTokenFCM
          AND activo = 1;

        COMMIT;

        SELECT
            @idTokenFCM AS idTokenFCM,
            @accion AS accion,
            'Token FCM guardado correctamente.' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage,16,1);
        RETURN;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_up_actualizaTokenUltimaConexion
(
    @idUsuario int,
    @token varchar(450),
    @dispositivo varchar(50),
    @plataforma varchar(50),
    @versionApp varchar(50),
    @idEntidad int,
    @idUsuarioModifica int
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @idTokenFCM int,
        @accion varchar(30),
        @fechaActual datetime = GETDATE();

    SET @token = NULLIF(LTRIM(RTRIM(@token)), '');
    SET @dispositivo = NULLIF(LTRIM(RTRIM(@dispositivo)), '');
    SET @plataforma = NULLIF(LTRIM(RTRIM(@plataforma)), '');
    SET @versionApp = NULLIF(LTRIM(RTRIM(@versionApp)), '');

    IF ISNULL(@idUsuario,0) <= 0
    BEGIN
        RAISERROR('El idUsuario es obligatorio.',16,1);
        RETURN;
    END;

    IF ISNULL(@idEntidad,0) <= 0
    BEGIN
        RAISERROR('El idEntidad es obligatorio.',16,1);
        RETURN;
    END;

    IF @token IS NULL
    BEGIN
        RAISERROR('El token FCM es obligatorio.',16,1);
        RETURN;
    END;

    IF @dispositivo IS NULL
    BEGIN
        RAISERROR('El dispositivo es obligatorio.',16,1);
        RETURN;
    END;

    IF @plataforma IS NULL
    BEGIN
        RAISERROR('La plataforma es obligatoria.',16,1);
        RETURN;
    END;

    IF @versionApp IS NULL
    BEGIN
        RAISERROR('La versionApp es obligatoria.',16,1);
        RETURN;
    END;

    IF ISNULL(@idUsuarioModifica,0) <= 0
    BEGIN
        RAISERROR('El idUsuarioModifica es obligatorio.',16,1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRAN;

        SELECT TOP 1
            @idTokenFCM = id
        FROM dbo.sys_tokenFCM WITH (UPDLOCK, HOLDLOCK)
        WHERE idEntidad = @idEntidad
          AND token = @token
        ORDER BY 
            activo DESC,
            fechaUltimaConexion DESC,
            id DESC;

        IF @idTokenFCM IS NULL
        BEGIN
            INSERT INTO dbo.sys_tokenFCM
            (
                idUsuario,
                token,
                dispositivo,
                plataforma,
                fechaUltimaConexion,
                versionApp,
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
                @idUsuario,
                @token,
                @dispositivo,
                @plataforma,
                @fechaActual,
                @versionApp,
                'Token insertado desde actualización de última conexión.',
                1,
                @idEntidad,
                NULL,
                NULL,
                @fechaActual,
                @idUsuarioModifica
            );

            SET @idTokenFCM = SCOPE_IDENTITY();
            SET @accion = 'INSERTADO';
        END
        ELSE
        BEGIN
            UPDATE dbo.sys_tokenFCM
            SET
                idUsuario = @idUsuario,
                dispositivo = @dispositivo,
                plataforma = @plataforma,
                versionApp = @versionApp,
                fechaUltimaConexion = @fechaActual,
                activo = 1,
                fechaModificacion = @fechaActual,
                idUsuarioModifica = @idUsuarioModifica
            WHERE id = @idTokenFCM;

            SET @accion = 'ACTUALIZADO';
        END;

        /* Blindaje contra duplicados previos */
        UPDATE dbo.sys_tokenFCM
        SET
            activo = 0,
            fechaModificacion = @fechaActual,
            idUsuarioModifica = @idUsuarioModifica,
            comentarios = ISNULL(comentarios, 'Token duplicado desactivado automáticamente.')
        WHERE idEntidad = @idEntidad
          AND token = @token
          AND id <> @idTokenFCM
          AND activo = 1;

        COMMIT;

        SELECT
            @idTokenFCM AS idTokenFCM,
            @accion AS accion,
            'Última conexión del token FCM actualizada correctamente.' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage,16,1);
        RETURN;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_se_tokenFCM
(
    @idEntidad int,
    @idUsuario int = 0,
    @soloActivos bit = 1,
    @plataforma varchar(50) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @plataforma = NULLIF(LTRIM(RTRIM(@plataforma)), '');

    IF ISNULL(@idEntidad,0) <= 0
    BEGIN
        RAISERROR('El idEntidad es obligatorio.',16,1);
        RETURN;
    END;

    IF ISNULL(@idUsuario,0) < 0
    BEGIN
        RAISERROR('El idUsuario no puede ser negativo.',16,1);
        RETURN;
    END;

    ;WITH Tokens AS
    (
        SELECT
            t.id,
            t.idUsuario,
            t.token,
            t.dispositivo,
            t.plataforma,
            t.fechaUltimaConexion,
            t.versionApp,
            t.comentarios,
            t.activo,
            t.idEntidad,
            ROW_NUMBER() OVER
            (
                PARTITION BY t.idEntidad, t.token
                ORDER BY 
                    t.activo DESC,
                    t.fechaUltimaConexion DESC,
                    t.id DESC
            ) AS rn
        FROM dbo.sys_tokenFCM t WITH (NOLOCK)
        WHERE t.idEntidad = @idEntidad
          AND (@idUsuario = 0 OR t.idUsuario = @idUsuario)
          AND (@soloActivos = 0 OR t.activo = 1)
          AND (@plataforma IS NULL OR t.plataforma = @plataforma)
          AND ISNULL(t.token,'') <> ''
    )
    SELECT
        id,
        idUsuario,
        token,
        dispositivo,
        plataforma,
        fechaUltimaConexion,
        versionApp,
        comentarios,
        activo,
        idEntidad
    FROM Tokens
    WHERE rn = 1
    ORDER BY fechaUltimaConexion DESC, id DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_up_desactivaTokenFCM
(
    @idEntidad int,
    @token varchar(450),
    @idUsuario int = 0,
    @idUsuarioModifica int,
    @comentarios varchar(250) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @filasAfectadas int,
        @fechaActual datetime = GETDATE();

    SET @token = NULLIF(LTRIM(RTRIM(@token)), '');
    SET @comentarios = NULLIF(LTRIM(RTRIM(@comentarios)), '');

    IF ISNULL(@idEntidad,0) <= 0
    BEGIN
        RAISERROR('El idEntidad es obligatorio.',16,1);
        RETURN;
    END;

    IF @token IS NULL
    BEGIN
        RAISERROR('El token FCM es obligatorio.',16,1);
        RETURN;
    END;

    IF ISNULL(@idUsuario,0) < 0
    BEGIN
        RAISERROR('El idUsuario no puede ser negativo.',16,1);
        RETURN;
    END;

    IF ISNULL(@idUsuarioModifica,0) <= 0
    BEGIN
        RAISERROR('El idUsuarioModifica es obligatorio.',16,1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRAN;

        UPDATE dbo.sys_tokenFCM
        SET
            activo = 0,
            fechaModificacion = @fechaActual,
            idUsuarioModifica = @idUsuarioModifica,
            comentarios = ISNULL(@comentarios, 'Token FCM desactivado.')
        WHERE idEntidad = @idEntidad
          AND token = @token
          AND (@idUsuario = 0 OR idUsuario = @idUsuario)
          AND activo = 1;

        SET @filasAfectadas = @@ROWCOUNT;

        COMMIT;

        SELECT
            @filasAfectadas AS filasAfectadas,
            CASE 
                WHEN @filasAfectadas > 0 THEN 'DESACTIVADO'
                ELSE 'NO_ENCONTRADO'
            END AS accion,
            CASE 
                WHEN @filasAfectadas > 0 THEN 'Token FCM desactivado correctamente.'
                ELSE 'No se encontró token activo para desactivar.'
            END AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage,16,1);
        RETURN;
    END CATCH;
END;
GO

IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_sys_tokenFCM_idEntidad_token'
      AND object_id = OBJECT_ID('dbo.sys_tokenFCM')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_sys_tokenFCM_idEntidad_token
    ON dbo.sys_tokenFCM (idEntidad, token)
    INCLUDE (idUsuario, activo, fechaUltimaConexion);
END;
GO

IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_sys_tokenFCM_idEntidad_idUsuario_activo'
      AND object_id = OBJECT_ID('dbo.sys_tokenFCM')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_sys_tokenFCM_idEntidad_idUsuario_activo
    ON dbo.sys_tokenFCM (idEntidad, idUsuario, activo)
    INCLUDE (token, dispositivo, plataforma, versionApp, fechaUltimaConexion);
END;
GO


CREATE OR ALTER PROCEDURE dbo.sp_ui_insertaNotificacionFCMPorUsuario
(
    @idUsuario int,
    @titulo varchar(250),
    @mensaje varchar(250),
    @imagen varbinary(max) = NULL,
    @comentarios varchar(250) = NULL,
    @idEntidad int,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @idNotificacionFCM int,
        @fechaActual datetime = GETDATE();

    SET @titulo = NULLIF(LTRIM(RTRIM(@titulo)), '');
    SET @mensaje = NULLIF(LTRIM(RTRIM(@mensaje)), '');
    SET @comentarios = NULLIF(LTRIM(RTRIM(@comentarios)), '');

    IF ISNULL(@idUsuario,0) <= 0
    BEGIN
        RAISERROR('El idUsuario es obligatorio.',16,1);
        RETURN;
    END;

    IF ISNULL(@idEntidad,0) <= 0
    BEGIN
        RAISERROR('El idEntidad es obligatorio.',16,1);
        RETURN;
    END;

    IF @titulo IS NULL
    BEGIN
        RAISERROR('El titulo es obligatorio.',16,1);
        RETURN;
    END;

    IF @mensaje IS NULL
    BEGIN
        RAISERROR('El mensaje es obligatorio.',16,1);
        RETURN;
    END;

    IF ISNULL(@idUsuarioAlta,0) <= 0
    BEGIN
        RAISERROR('El idUsuarioAlta es obligatorio.',16,1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO dbo.sys_notificacionesFCM
        (
            idUsuario,
            titulo,
            mensaje,
            imagen,
            enviado,
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
            @idUsuario,
            @titulo,
            @mensaje,
            @imagen,
            0,
            @comentarios,
            1,
            @idEntidad,
            NULL,
            NULL,
            @fechaActual,
            @idUsuarioAlta
        );

        SET @idNotificacionFCM = CONVERT(int, SCOPE_IDENTITY());

        COMMIT;

        SELECT
            @idNotificacionFCM AS idNotificacionFCM,
            'USUARIO' AS tipo,
            'INSERTADO' AS accion,
            'Notificación FCM por usuario insertada correctamente.' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage,16,1);
        RETURN;
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE dbo.sp_ui_insertaNotificacionFCMPorEntidad
(
    @idEntidad int,
    @titulo varchar(250),
    @mensaje varchar(250),
    @imagen varbinary(max) = NULL,
    @comentarios varchar(250) = NULL,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @idNotificacionFCM int,
        @fechaActual datetime = GETDATE();

    SET @titulo = NULLIF(LTRIM(RTRIM(@titulo)), '');
    SET @mensaje = NULLIF(LTRIM(RTRIM(@mensaje)), '');
    SET @comentarios = NULLIF(LTRIM(RTRIM(@comentarios)), '');

    IF ISNULL(@idEntidad,0) <= 0
    BEGIN
        RAISERROR('El idEntidad es obligatorio.',16,1);
        RETURN;
    END;

    IF @titulo IS NULL
    BEGIN
        RAISERROR('El titulo es obligatorio.',16,1);
        RETURN;
    END;

    IF @mensaje IS NULL
    BEGIN
        RAISERROR('El mensaje es obligatorio.',16,1);
        RETURN;
    END;

    IF ISNULL(@idUsuarioAlta,0) <= 0
    BEGIN
        RAISERROR('El idUsuarioAlta es obligatorio.',16,1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO dbo.sys_notificacionesFCM
        (
            idUsuario,
            titulo,
            mensaje,
            imagen,
            enviado,
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
            0,
            @titulo,
            @mensaje,
            @imagen,
            0,
            @comentarios,
            1,
            @idEntidad,
            NULL,
            NULL,
            @fechaActual,
            @idUsuarioAlta
        );

        SET @idNotificacionFCM = CONVERT(int, SCOPE_IDENTITY());

        COMMIT;

        SELECT
            @idNotificacionFCM AS idNotificacionFCM,
            'ENTIDAD' AS tipo,
            'INSERTADO' AS accion,
            'Notificación FCM por entidad insertada correctamente.' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage,16,1);
        RETURN;
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE dbo.sp_ui_insertaNotificacionFCMGeneral
(
    @titulo varchar(250),
    @mensaje varchar(250),
    @imagen varbinary(max) = NULL,
    @comentarios varchar(250) = NULL,
    @idUsuarioAlta int
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @idNotificacionFCM int,
        @fechaActual datetime = GETDATE();

    SET @titulo = NULLIF(LTRIM(RTRIM(@titulo)), '');
    SET @mensaje = NULLIF(LTRIM(RTRIM(@mensaje)), '');
    SET @comentarios = NULLIF(LTRIM(RTRIM(@comentarios)), '');

    IF @titulo IS NULL
    BEGIN
        RAISERROR('El titulo es obligatorio.',16,1);
        RETURN;
    END;

    IF @mensaje IS NULL
    BEGIN
        RAISERROR('El mensaje es obligatorio.',16,1);
        RETURN;
    END;

    IF ISNULL(@idUsuarioAlta,0) <= 0
    BEGIN
        RAISERROR('El idUsuarioAlta es obligatorio.',16,1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO dbo.sys_notificacionesFCM
        (
            idUsuario,
            titulo,
            mensaje,
            imagen,
            enviado,
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
            0,
            @titulo,
            @mensaje,
            @imagen,
            0,
            @comentarios,
            1,
            NULL,
            NULL,
            NULL,
            @fechaActual,
            @idUsuarioAlta
        );

        SET @idNotificacionFCM = CONVERT(int, SCOPE_IDENTITY());

        COMMIT;

        SELECT
            @idNotificacionFCM AS idNotificacionFCM,
            'GENERAL' AS tipo,
            'INSERTADO' AS accion,
            'Notificación FCM general insertada correctamente.' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage,16,1);
        RETURN;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_se_notificacionesFCMPendientes
(
    @tipo varchar(20),
    @idEntidad int = NULL,
    @idUsuario int = 0,
    @top int = 100,
    @incluirImagen bit = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @tipo = UPPER(NULLIF(LTRIM(RTRIM(@tipo)), ''));

    IF @tipo IS NULL
    BEGIN
        RAISERROR('El tipo es obligatorio: USUARIO, ENTIDAD o GENERAL.',16,1);
        RETURN;
    END;

    IF @tipo NOT IN ('USUARIO','ENTIDAD','GENERAL')
    BEGIN
        RAISERROR('Tipo inválido. Valores permitidos: USUARIO, ENTIDAD o GENERAL.',16,1);
        RETURN;
    END;

    IF ISNULL(@top,0) <= 0
        SET @top = 100;

    IF @top > 1000
        SET @top = 1000;

    IF @tipo = 'USUARIO'
    BEGIN
        IF ISNULL(@idEntidad,0) <= 0
        BEGIN
            RAISERROR('El idEntidad es obligatorio para tipo USUARIO.',16,1);
            RETURN;
        END;

        IF ISNULL(@idUsuario,0) <= 0
        BEGIN
            RAISERROR('El idUsuario es obligatorio para tipo USUARIO.',16,1);
            RETURN;
        END;
    END;

    IF @tipo = 'ENTIDAD'
    BEGIN
        IF ISNULL(@idEntidad,0) <= 0
        BEGIN
            RAISERROR('El idEntidad es obligatorio para tipo ENTIDAD.',16,1);
            RETURN;
        END;
    END;

    SELECT TOP (@top)
        n.id,
        n.idUsuario,
        n.titulo,
        n.mensaje,
        CASE 
            WHEN @incluirImagen = 1 THEN n.imagen 
            ELSE NULL 
        END AS imagen,
        n.enviado,
        n.comentarios,
        n.activo,
        n.idEntidad,
        n.fechaAlta,
        n.idUsuarioAlta,
        CASE
            WHEN n.idUsuario > 0 AND n.idEntidad IS NOT NULL THEN 'USUARIO'
            WHEN n.idUsuario = 0 AND n.idEntidad IS NOT NULL THEN 'ENTIDAD'
            WHEN n.idUsuario = 0 AND n.idEntidad IS NULL THEN 'GENERAL'
            ELSE 'NO_DEFINIDO'
        END AS tipoNotificacion
    FROM dbo.sys_notificacionesFCM n
    WHERE n.enviado = 0
      AND n.activo = 1
      AND
      (
            (
                @tipo = 'USUARIO'
                AND n.idUsuario = @idUsuario
                AND n.idEntidad = @idEntidad
            )
            OR
            (
                @tipo = 'ENTIDAD'
                AND n.idUsuario = 0
                AND n.idEntidad = @idEntidad
            )
            OR
            (
                @tipo = 'GENERAL'
                AND n.idUsuario = 0
                AND n.idEntidad IS NULL
            )
      )
    ORDER BY 
        n.fechaAlta ASC,
        n.id ASC;
END;
GO


CREATE OR ALTER PROCEDURE dbo.sp_up_notificacionFCMEnviada
(
    @idNotificacionFCM int,
    @idUsuarioModifica int,
    @comentarios varchar(250) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @enviadoActual bit,
        @activoActual bit,
        @fechaActual datetime = GETDATE();

    SET @comentarios = NULLIF(LTRIM(RTRIM(@comentarios)), '');

    IF ISNULL(@idNotificacionFCM,0) <= 0
    BEGIN
        RAISERROR('El idNotificacionFCM es obligatorio.',16,1);
        RETURN;
    END;

    IF ISNULL(@idUsuarioModifica,0) <= 0
    BEGIN
        RAISERROR('El idUsuarioModifica es obligatorio.',16,1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRAN;

        SELECT
            @enviadoActual = enviado,
            @activoActual = activo
        FROM dbo.sys_notificacionesFCM WITH (UPDLOCK, HOLDLOCK)
        WHERE id = @idNotificacionFCM;

        IF @enviadoActual IS NULL
        BEGIN
            RAISERROR('No existe la notificación FCM indicada.',16,1);
            ROLLBACK;
            RETURN;
        END;

        IF @activoActual = 0
        BEGIN
            COMMIT;

            SELECT
                @idNotificacionFCM AS idNotificacionFCM,
                'INACTIVA' AS accion,
                'La notificación está inactiva. No se marcó como enviada.' AS mensaje;
            RETURN;
        END;

        IF @enviadoActual = 1
        BEGIN
            COMMIT;

            SELECT
                @idNotificacionFCM AS idNotificacionFCM,
                'YA_ENVIADA' AS accion,
                'La notificación ya estaba marcada como enviada.' AS mensaje;
            RETURN;
        END;

        UPDATE dbo.sys_notificacionesFCM
        SET
            enviado = 1,
            fechaModificacion = @fechaActual,
            idUsuarioModifica = @idUsuarioModifica,
            comentarios = ISNULL(@comentarios, comentarios)
        WHERE id = @idNotificacionFCM;

        COMMIT;

        SELECT
            @idNotificacionFCM AS idNotificacionFCM,
            'ENVIADA' AS accion,
            'Notificación FCM marcada como enviada correctamente.' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage,16,1);
        RETURN;
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE dbo.sp_up_cancelaNotificacionFCM
(
    @idNotificacionFCM int,
    @idUsuarioModifica int,
    @comentarios varchar(250) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @enviadoActual bit,
        @activoActual bit,
        @fechaActual datetime = GETDATE();

    SET @comentarios = NULLIF(LTRIM(RTRIM(@comentarios)), '');

    IF ISNULL(@idNotificacionFCM,0) <= 0
    BEGIN
        RAISERROR('El idNotificacionFCM es obligatorio.',16,1);
        RETURN;
    END;

    IF ISNULL(@idUsuarioModifica,0) <= 0
    BEGIN
        RAISERROR('El idUsuarioModifica es obligatorio.',16,1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRAN;

        SELECT
            @enviadoActual = enviado,
            @activoActual = activo
        FROM dbo.sys_notificacionesFCM WITH (UPDLOCK, HOLDLOCK)
        WHERE id = @idNotificacionFCM;

        IF @enviadoActual IS NULL
        BEGIN
            RAISERROR('No existe la notificación FCM indicada.',16,1);
            ROLLBACK;
            RETURN;
        END;

        IF @enviadoActual = 1
        BEGIN
            COMMIT;

            SELECT
                @idNotificacionFCM AS idNotificacionFCM,
                'YA_ENVIADA_NO_CANCELADA' AS accion,
                'La notificación ya fue enviada. No se puede cancelar.' AS mensaje;
            RETURN;
        END;

        IF @activoActual = 0
        BEGIN
            COMMIT;

            SELECT
                @idNotificacionFCM AS idNotificacionFCM,
                'YA_CANCELADA' AS accion,
                'La notificación ya estaba cancelada.' AS mensaje;
            RETURN;
        END;

        UPDATE dbo.sys_notificacionesFCM
        SET
            activo = 0,
            fechaModificacion = @fechaActual,
            idUsuarioModifica = @idUsuarioModifica,
            comentarios = ISNULL(@comentarios, 'Notificación FCM cancelada.')
        WHERE id = @idNotificacionFCM;

        COMMIT;

        SELECT
            @idNotificacionFCM AS idNotificacionFCM,
            'CANCELADA' AS accion,
            'Notificación FCM cancelada correctamente.' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage,16,1);
        RETURN;
    END CATCH;
END;
GO


IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_sys_notificacionesFCM_pendientes_usuario'
      AND object_id = OBJECT_ID('dbo.sys_notificacionesFCM')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_sys_notificacionesFCM_pendientes_usuario
    ON dbo.sys_notificacionesFCM (idEntidad, idUsuario, enviado, activo, fechaAlta)
    INCLUDE (titulo, mensaje);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_sys_notificacionesFCM_pendientes_general'
      AND object_id = OBJECT_ID('dbo.sys_notificacionesFCM')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_sys_notificacionesFCM_pendientes_general
    ON dbo.sys_notificacionesFCM (idUsuario, idEntidad, enviado, activo, fechaAlta)
    INCLUDE (titulo, mensaje);
END;
GO


-- ------------------------------------------------------------------------
--	TEST TOKENS -- OK
-- ------------------------------------------------------------------------
exec sp_ui_guardaTokenFCM 
	@idUsuario = 53
	,@token = 'a65f1a81d6w1d3a1d32d6as1d6a00'
	,@dispositivo = 'Iphone 12 Mini'
	,@plataforma = 'iOS'
	,@versionApp = '1.1'
	,@comentarios = ''
	,@idEntidad = 10007
	,@idUsuarioAlta = 1

exec sp_up_actualizaTokenUltimaConexion 
	@idUsuario =53
	,@token = 'a65f1a81d6w1d3a1d32d6as1d6a00'
	,@dispositivo = 'Iphone 12 Mini'
	,@plataforma = 'iOS'
	,@versionApp ='1.1'
	,@idEntidad = 10007
	,@idUsuarioModifica = 1

exec sp_se_tokenFCM 
	@idEntidad = 10007
	,@idUsuario = 0
	,@soloActivos = 0
	,@plataforma = 'iOS'

exec sp_up_desactivaTokenFCM 
	@idEntidad = 10007
	,@token = 'a65f1a81d6w1d3a1d32d6as1d6a00'
	,@idUsuario = 53
	,@idUsuarioModifica = 1
	,@comentarios = 'Cierre Sesion manual'
-- ------------------------------------------------------------------------
--	TEST NOTIFICACIONES --OK
-- ------------------------------------------------------------------------
EXEC dbo.sp_ui_insertaNotificacionFCMPorUsuario
    @idUsuario = 52,
    @titulo = 'Nueva cita',
    @mensaje = 'Tienes una cita pendiente.',
    @imagen = NULL,
    @comentarios = NULL,
    @idEntidad = 10007,
    @idUsuarioAlta = 1;

EXEC dbo.sp_ui_insertaNotificacionFCMPorEntidad
    @idEntidad = 10007,
    @titulo = 'Aviso general',
    @mensaje = 'Hay una actualización disponible.',
    @imagen = NULL,
    @comentarios = NULL,
    @idUsuarioAlta = 1;

EXEC dbo.sp_ui_insertaNotificacionFCMGeneral
    @titulo = 'Mantenimiento',
    @mensaje = 'El sistema tendrá mantenimiento.',
    @imagen = NULL,
    @comentarios = NULL,
    @idUsuarioAlta = 1;

EXEC dbo.sp_se_notificacionesFCMPendientes
    @tipo = 'USUARIO',
    @idEntidad = 10007,
    @idUsuario = 52;

EXEC dbo.sp_se_notificacionesFCMPendientes
    @tipo = 'ENTIDAD',
    @idEntidad = 10007;

EXEC dbo.sp_se_notificacionesFCMPendientes
    @tipo = 'GENERAL';

EXEC dbo.sp_up_notificacionFCMEnviada
    @idNotificacionFCM = 1,
    @idUsuarioModifica = 1,
    @comentarios = 'Enviada correctamente por Firebase.';

EXEC dbo.sp_up_cancelaNotificacionFCM
    @idNotificacionFCM = 2,
    @idUsuarioModifica = 1,
    @comentarios = 'Cancelada manualmente.';