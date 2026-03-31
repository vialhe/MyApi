/* =========================================================
   SETUP TIENDA BASE (Entidad ya existente)
   Incluye: TiposPersona, Persona Admin, Perfil Admin, Usuario Admin,
            Magnitudes + Unidades de Medida + Conversiones
   ========================================================= */

DECLARE @idEntidad INT = 10007;
DECLARE @idUsuarioSistema INT = 1;

DECLARE @usuarioAdmin VARCHAR(50) = 'Administrador';
DECLARE @correoAdmin  VARCHAR(150)= 'admin@hotmail.com';
DECLARE @telefonoAdmin VARCHAR(30)= '1111111';
DECLARE @fechaNacimiento DATE = '1998-12-21';
DECLARE @nombreAdmin  VARCHAR(100)= 'QA';

/* ---------- Validación mínima ---------- */
IF NOT EXISTS (SELECT 1 FROM sys_entidades WHERE id = @idEntidad)
BEGIN
	RAISERROR('La entidad %d no existe en sys_entidades.', 16, 1, @idEntidad);
	RETURN;
END;
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
BEGIN TRY
	BEGIN TRAN;
	
	/* =========================================================
	   1) TIPOS DE PERSONA (Administrador / Proveedor)
	   ========================================================= */
	IF NOT EXISTS (SELECT 1 FROM cat_tiposPersonas WHERE idEntidad=@idEntidad AND descripcion='Administrador' )
		EXEC sp_ui_catalogos 0,'Administrador','',@idEntidad,1,@idUsuarioSistema,'cat_tiposPersonas';

	IF NOT EXISTS (SELECT 1 FROM cat_tiposPersonas WHERE idEntidad=@idEntidad AND descripcion='Proveedor' )
		EXEC sp_ui_catalogos 0,'Proveedor','',@idEntidad,1,@idUsuarioSistema,'cat_tiposPersonas';
	IF NOT EXISTS (SELECT 1 FROM cat_tiposPersonas WHERE idEntidad=@idEntidad AND descripcion='Cliente' )
		EXEC sp_ui_catalogos 0,'Cliente','',@idEntidad,1,@idUsuarioSistema,'cat_tiposPersonas';

	DECLARE @idTipoPersonaAdmin INT =
		(SELECT TOP 1 id FROM cat_tiposPersonas WHERE idEntidad=@idEntidad AND descripcion='Administrador' Order By id);

	IF @idTipoPersonaAdmin IS NULL RAISERROR('No se pudo obtener TipoPersona Administrador',16,1);
	/* =========================================================
	   2) PERSONA ADMIN (si no existe por correo)
	   ========================================================= */
	IF NOT EXISTS (SELECT 1 FROM cat_personas WHERE idEntidad=@idEntidad AND correo=@correoAdmin)
	BEGIN
		EXEC sp_ui_persona
			@id = 0,
			@idTipoPersona = @idTipoPersonaAdmin,
			@nombre = @nombreAdmin,
			@apellidoPaterno = '',
			@apellidoMaterno = '',
			@idGenero = 1,
			@fechaNacimiento = @fechaNacimiento,
			@numeroTelefono = @telefonoAdmin,
			@correo = @correoAdmin,
			@comentarios = '',
			@activo = 1,
			@idEntidad = @idEntidad,
			@idUsuarioModifica = @idUsuarioSistema;
	END;

	DECLARE @idPersonaAdmin INT =
		(SELECT TOP 1 id FROM cat_personas WHERE idEntidad=@idEntidad AND correo=@correoAdmin order by id);

	IF @idPersonaAdmin IS NULL RAISERROR('No se pudo obtener Persona Admin',16,1);
	/* =========================================================
	   3) PERFIL ADMIN y CLIENTE
	   ========================================================= */
	IF NOT EXISTS (SELECT 1 FROM sys_perfiles WHERE idEntidad=@idEntidad AND descripcion='Administrador')
		EXEC sp_ui_catalogos 0,'Administrador','',@idEntidad,1,@idUsuarioSistema,'sys_perfiles';
	IF NOT EXISTS (SELECT 1 FROM sys_perfiles WHERE idEntidad=@idEntidad AND descripcion='Cliente')
		EXEC sp_ui_catalogos 0,'Cliente','',@idEntidad,1,@idUsuarioSistema,'sys_perfiles';

	DECLARE @idPerfilAdmin INT =
		(SELECT TOP 1 id FROM sys_perfiles WHERE idEntidad=@idEntidad AND descripcion='Administrador' order by id);
	IF @idPerfilAdmin IS NULL RAISERROR('No se pudo obtener Perfil Administrador',16,1);

	/* =========================================================
	   4) USUARIO ADMIN
	   (password/salt vacíos: se setean por tu endpoint ChangePassword)
	   ========================================================= */
	IF NOT EXISTS (SELECT 1 FROM sys_usuarios WHERE idEntidad=@idEntidad AND usuario=@usuarioAdmin)
	BEGIN
		EXEC sp_ui_usuarios
			@id = 0,
			@idPerfil = @idPerfilAdmin,
			@usuario = @usuarioAdmin,
			@password = '',
			@salt = '',
			@idPersona = @idPersonaAdmin,
			@nombre = '',
			@comentarios = '',
			@activo = 1,
			@idEntidad = @idEntidad,
			@idUsuarioModifica = @idUsuarioSistema;
	END;

	/* =========================================================
	   5) UNIDADES MEDIDA CON SCRIPT QUE ME PASASTE
	   ========================================================= */
	
	/* =========================
     1) MAGNITUDES
     ========================= */
  DECLARE @idMagnConteo INT, @idMagnMasa INT, @idMagnVolumen INT;

  SELECT @idMagnConteo = id
  FROM cat_magnitudMedida
  WHERE idEntidad=@idEntidad AND descripcion='Conteo';

  IF @idMagnConteo IS NULL
  BEGIN
    INSERT INTO cat_magnitudMedida
      (descripcion, comentarios, activo, idEntidad, fechaAlta, idUsuarioAlta)
    VALUES
      ('Conteo','Piezas, docenas, etc.',1,@idEntidad,GETDATE(),@idUsuarioSistema);

    SET @idMagnConteo = SCOPE_IDENTITY();
  END

  SELECT @idMagnMasa = id
  FROM cat_magnitudMedida
  WHERE idEntidad=@idEntidad AND descripcion='Masa';

  IF @idMagnMasa IS NULL
  BEGIN
    INSERT INTO cat_magnitudMedida
      (descripcion, comentarios, activo, idEntidad, fechaAlta, idUsuarioAlta)
    VALUES
      ('Masa','g, kg, mg',1,@idEntidad,GETDATE(),@idUsuarioSistema);

    SET @idMagnMasa = SCOPE_IDENTITY();
  END

  SELECT @idMagnVolumen = id
  FROM cat_magnitudMedida
  WHERE idEntidad=@idEntidad AND descripcion='Volumen';

  IF @idMagnVolumen IS NULL
  BEGIN
    INSERT INTO cat_magnitudMedida
      (descripcion, comentarios, activo, idEntidad, fechaAlta, idUsuarioAlta)
    VALUES
      ('Volumen','ml, l',1,@idEntidad,GETDATE(),@idUsuarioSistema);

    SET @idMagnVolumen = SCOPE_IDENTITY();
  END

  /* =========================
     2) UNIDADES (UPSERT)
     Clave práctica: (idEntidad, abreviatura)
     ========================= */

  DECLARE @idUM_pza INT, @idUM_doc INT;
  DECLARE @idUM_mg  INT, @idUM_g   INT, @idUM_kg INT;
  DECLARE @idUM_ml  INT, @idUM_l   INT, @idUM_cc INT;

  /* --- Conteo --- */
  SELECT @idUM_pza = id FROM cat_unidadesMedida WHERE idEntidad=@idEntidad AND abreviatura='pza';
  IF @idUM_pza IS NULL
  BEGIN
    INSERT INTO cat_unidadesMedida
      (descripcion, comentarios, activo, idEntidad, fechaAlta, idUsuarioAlta,
       abreviatura, idMagnitud, factorAUnidadBaseMagnitud, esUnidadBaseMagnitud, precisionRedondeo, requiereFactorProducto)
    VALUES
      ('Pieza','',1,@idEntidad,GETDATE(),@idUsuarioSistema,'pza',@idMagnConteo,1,1,0,0);

    SET @idUM_pza = SCOPE_IDENTITY();
  END
  ELSE
  BEGIN
    UPDATE cat_unidadesMedida
      SET descripcion='Pieza',
          idMagnitud=@idMagnConteo,
          factorAUnidadBaseMagnitud=1,
          esUnidadBaseMagnitud=1,
          precisionRedondeo=0,
          requiereFactorProducto=0,
          activo=1
    WHERE id=@idUM_pza AND idEntidad=@idEntidad;
  END

  -- Asegura 1 sola base en Conteo
  UPDATE cat_unidadesMedida
    SET esUnidadBaseMagnitud=0
  WHERE idEntidad=@idEntidad AND idMagnitud=@idMagnConteo AND id<>@idUM_pza;

  SELECT @idUM_doc = id FROM cat_unidadesMedida WHERE idEntidad=@idEntidad AND abreviatura='doc';
  IF @idUM_doc IS NULL
  BEGIN
    INSERT INTO cat_unidadesMedida
      (descripcion, comentarios, activo, idEntidad, fechaAlta, idUsuarioAlta,
       abreviatura, idMagnitud, factorAUnidadBaseMagnitud, esUnidadBaseMagnitud, precisionRedondeo, requiereFactorProducto)
    VALUES
      ('Docena','12 piezas',1,@idEntidad,GETDATE(),@idUsuarioSistema,'doc',@idMagnConteo,12,0,0,0);

    SET @idUM_doc = SCOPE_IDENTITY();
  END
  ELSE
  BEGIN
    UPDATE cat_unidadesMedida
      SET descripcion='Docena',
          comentarios='12 piezas',
          idMagnitud=@idMagnConteo,
          factorAUnidadBaseMagnitud=12,
          esUnidadBaseMagnitud=0,
          precisionRedondeo=0,
          requiereFactorProducto=0,
          activo=1
    WHERE id=@idUM_doc AND idEntidad=@idEntidad;
  END

  /* --- Masa (Base = g) --- */
  SELECT @idUM_g = id FROM cat_unidadesMedida WHERE idEntidad=@idEntidad AND abreviatura='g';
  IF @idUM_g IS NULL
  BEGIN
    INSERT INTO cat_unidadesMedida
      (descripcion, comentarios, activo, idEntidad, fechaAlta, idUsuarioAlta,
       abreviatura, idMagnitud, factorAUnidadBaseMagnitud, esUnidadBaseMagnitud, precisionRedondeo, requiereFactorProducto)
    VALUES
      ('Gramo','',1,@idEntidad,GETDATE(),@idUsuarioSistema,'g',@idMagnMasa,1,1,3,0);

    SET @idUM_g = SCOPE_IDENTITY();
  END
  ELSE
  BEGIN
    UPDATE cat_unidadesMedida
      SET descripcion='Gramo',
          idMagnitud=@idMagnMasa,
          factorAUnidadBaseMagnitud=1,
          esUnidadBaseMagnitud=1,
          precisionRedondeo=3,
          requiereFactorProducto=0,
          activo=1
    WHERE id=@idUM_g AND idEntidad=@idEntidad;
  END

  -- Asegura 1 sola base en Masa
  UPDATE cat_unidadesMedida
    SET esUnidadBaseMagnitud=0
  WHERE idEntidad=@idEntidad AND idMagnitud=@idMagnMasa AND id<>@idUM_g;

  SELECT @idUM_mg = id FROM cat_unidadesMedida WHERE idEntidad=@idEntidad AND abreviatura='mg';
  IF @idUM_mg IS NULL
  BEGIN
    INSERT INTO cat_unidadesMedida
      (descripcion, comentarios, activo, idEntidad, fechaAlta, idUsuarioAlta,
       abreviatura, idMagnitud, factorAUnidadBaseMagnitud, esUnidadBaseMagnitud, precisionRedondeo, requiereFactorProducto)
    VALUES
      ('Miligramo','',1,@idEntidad,GETDATE(),@idUsuarioSistema,'mg',@idMagnMasa,0.001,0,0,0);

    SET @idUM_mg = SCOPE_IDENTITY();
  END
  ELSE
  BEGIN
    UPDATE cat_unidadesMedida
      SET descripcion='Miligramo',
          idMagnitud=@idMagnMasa,
          factorAUnidadBaseMagnitud=0.001,
          esUnidadBaseMagnitud=0,
          precisionRedondeo=0,
          requiereFactorProducto=0,
          activo=1
    WHERE id=@idUM_mg AND idEntidad=@idEntidad;
  END

  SELECT @idUM_kg = id FROM cat_unidadesMedida WHERE idEntidad=@idEntidad AND abreviatura='kg';
  IF @idUM_kg IS NULL
  BEGIN
    INSERT INTO cat_unidadesMedida
      (descripcion, comentarios, activo, idEntidad, fechaAlta, idUsuarioAlta,
       abreviatura, idMagnitud, factorAUnidadBaseMagnitud, esUnidadBaseMagnitud, precisionRedondeo, requiereFactorProducto)
    VALUES
      ('Kilogramo','',1,@idEntidad,GETDATE(),@idUsuarioSistema,'kg',@idMagnMasa,1000,0,3,0);

    SET @idUM_kg = SCOPE_IDENTITY();
  END
  ELSE
  BEGIN
    UPDATE cat_unidadesMedida
      SET descripcion='Kilogramo',
          idMagnitud=@idMagnMasa,
          factorAUnidadBaseMagnitud=1000,
          esUnidadBaseMagnitud=0,
          precisionRedondeo=3,
          requiereFactorProducto=0,
          activo=1
    WHERE id=@idUM_kg AND idEntidad=@idEntidad;
  END

  /* --- Volumen (Base = ml) --- */
  SELECT @idUM_ml = id FROM cat_unidadesMedida WHERE idEntidad=@idEntidad AND abreviatura='ml';
  IF @idUM_ml IS NULL
  BEGIN
    INSERT INTO cat_unidadesMedida
      (descripcion, comentarios, activo, idEntidad, fechaAlta, idUsuarioAlta,
       abreviatura, idMagnitud, factorAUnidadBaseMagnitud, esUnidadBaseMagnitud, precisionRedondeo, requiereFactorProducto)
    VALUES
      ('Mililitro','',1,@idEntidad,GETDATE(),@idUsuarioSistema,'ml',@idMagnVolumen,1,1,0,0);

    SET @idUM_ml = SCOPE_IDENTITY();
  END
  ELSE
  BEGIN
    UPDATE cat_unidadesMedida
      SET descripcion='Mililitro',
          idMagnitud=@idMagnVolumen,
          factorAUnidadBaseMagnitud=1,
          esUnidadBaseMagnitud=1,
          precisionRedondeo=0,
          requiereFactorProducto=0,
          activo=1
    WHERE id=@idUM_ml AND idEntidad=@idEntidad;
  END

  -- Asegura 1 sola base en Volumen
  UPDATE cat_unidadesMedida
    SET esUnidadBaseMagnitud=0
  WHERE idEntidad=@idEntidad AND idMagnitud=@idMagnVolumen AND id<>@idUM_ml;

  SELECT @idUM_l = id FROM cat_unidadesMedida WHERE idEntidad=@idEntidad AND abreviatura='l';
  IF @idUM_l IS NULL
  BEGIN
    INSERT INTO cat_unidadesMedida
      (descripcion, comentarios, activo, idEntidad, fechaAlta, idUsuarioAlta,
       abreviatura, idMagnitud, factorAUnidadBaseMagnitud, esUnidadBaseMagnitud, precisionRedondeo, requiereFactorProducto)
    VALUES
      ('Litro','',1,@idEntidad,GETDATE(),@idUsuarioSistema,'l',@idMagnVolumen,1000,0,3,0);

    SET @idUM_l = SCOPE_IDENTITY();
  END
  ELSE
  BEGIN
    UPDATE cat_unidadesMedida
      SET descripcion='Litro',
          idMagnitud=@idMagnVolumen,
          factorAUnidadBaseMagnitud=1000,
          esUnidadBaseMagnitud=0,
          precisionRedondeo=3,
          requiereFactorProducto=0,
          activo=1
    WHERE id=@idUM_l AND idEntidad=@idEntidad;
  END

  SELECT @idUM_cc = id FROM cat_unidadesMedida WHERE idEntidad=@idEntidad AND abreviatura='cc';
  IF @idUM_cc IS NULL
  BEGIN
    INSERT INTO cat_unidadesMedida
      (descripcion, comentarios, activo, idEntidad, fechaAlta, idUsuarioAlta,
       abreviatura, idMagnitud, factorAUnidadBaseMagnitud, esUnidadBaseMagnitud, precisionRedondeo, requiereFactorProducto)
    VALUES
      ('Centímetro cúbico','Equivale a 1 ml',1,@idEntidad,GETDATE(),@idUsuarioSistema,'cc',@idMagnVolumen,1,0,0,0);

    SET @idUM_cc = SCOPE_IDENTITY();
  END
  ELSE
  BEGIN
    UPDATE cat_unidadesMedida
      SET descripcion='Centímetro cúbico',
          comentarios='Equivale a 1 ml',
          idMagnitud=@idMagnVolumen,
          factorAUnidadBaseMagnitud=1,
          esUnidadBaseMagnitud=0,
          precisionRedondeo=0,
          requiereFactorProducto=0,
          activo=1
    WHERE id=@idUM_cc AND idEntidad=@idEntidad;
  END

  /* =========================
     3) CONVERSIONES (matriz por magnitud)
     factor(A->B) = factorBase(A) / factorBase(B)
     ========================= */

  ;WITH U AS (
    SELECT
      id AS idUM,
      idMagnitud,
      CAST(factorAUnidadBaseMagnitud AS DECIMAL(18,10)) AS factorBase
    FROM cat_unidadesMedida
    WHERE idEntidad=@idEntidad AND activo=1
  )
  INSERT INTO proc_unidadMedidaConversion (idUMOrigen, idUMDestino, factor)
  SELECT
    u1.idUM,
    u2.idUM,
    CAST(u1.factorBase / NULLIF(u2.factorBase,0) AS DECIMAL(18,10)) AS factor
  FROM U u1
  JOIN U u2
    ON u1.idMagnitud = u2.idMagnitud
   AND u1.idUM <> u2.idUM
  WHERE NOT EXISTS (
    SELECT 1
    FROM proc_unidadMedidaConversion c
    WHERE c.idUMOrigen = u1.idUM
      AND c.idUMDestino = u2.idUM
  );

  ;WITH U AS (
	  SELECT id AS idUM, idMagnitud,
			 CAST(factorAUnidadBaseMagnitud AS DECIMAL(18,10)) AS factorBase
	  FROM cat_unidadesMedida
	  WHERE idEntidad=@idEntidad AND activo=1
	),
	M AS (
	  SELECT u1.idUM AS idUMOrigen, u2.idUM AS idUMDestino,
			 CAST(u1.factorBase / NULLIF(u2.factorBase,0) AS DECIMAL(18,10)) AS factor
	  FROM U u1
	  JOIN U u2 ON u1.idMagnitud=u2.idMagnitud AND u1.idUM<>u2.idUM
	)
	UPDATE c
	  SET c.factor = m.factor
	FROM proc_unidadMedidaConversion c
	JOIN M m ON m.idUMOrigen=c.idUMOrigen AND m.idUMDestino=c.idUMDestino;

	/* =========================================================
	   6) TIPOS DE PRODUCTOS (tu bloque, pero con COMMIT real)
	   ========================================================= */
	IF NOT EXISTS (SELECT 1 FROM cat_tiposProductosServicios WHERE idEntidad=@idEntidad)
	BEGIN
		-- Catálogo genérico depurado: cat_tiposProductosServicios
		EXEC sp_ui_catalogos 0,'Frutas y Verduras','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Lácteos','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Carnes y Embutidos','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Panadería y Tortillería','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Congelados','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Abarrotes (Granos/Harinas/Cereales)','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Pastas y Sopas','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Enlatados y Conservas','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Aceites, Condimentos y Salsas','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Snacks (Botanas y Galletas)','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Dulces y Chocolates','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Bebidas','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Bebés','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Higiene Personal','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Limpieza del Hogar','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Mascotas','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Papelería','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Ferretería y Pilas','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Farmacia','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Productos de Temporada','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Lo Nuevo','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Servicios','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
		EXEC sp_ui_catalogos 0,'Otros','',@idEntidad,1,@idUsuarioSistema,'cat_tiposProductosServicios';
	END;

	COMMIT;

	/* ---------- Resumen rápido ---------- */
	SELECT 'TiposPersona' AS bloque, * FROM cat_tiposPersonas WHERE idEntidad=@idEntidad;
	SELECT 'PersonaAdmin' AS bloque, * FROM cat_personas WHERE idEntidad=@idEntidad AND id=@idPersonaAdmin;
	SELECT 'Perfil' AS bloque, * FROM sys_perfiles WHERE idEntidad=@idEntidad;
	SELECT 'UsuarioAdmin' AS bloque, * FROM sys_usuarios WHERE idEntidad=@idEntidad AND usuario=@usuarioAdmin;

	SELECT * FROM cat_magnitudMedida WHERE idEntidad=@idEntidad ORDER BY id;
	SELECT * FROM cat_unidadesMedida WHERE idEntidad=@idEntidad ORDER BY idMagnitud, esUnidadBaseMagnitud DESC, id;
	SELECT COUNT(*) AS totalConversiones
	FROM proc_unidadMedidaConversion c
	WHERE EXISTS (SELECT 1 FROM cat_unidadesMedida u WHERE u.idEntidad=@idEntidad AND u.id=c.idUMOrigen);


END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK;
	DECLARE @err NVARCHAR(4000) = ERROR_MESSAGE();
	RAISERROR('Setup tienda falló: %s',16,1,@err);
END CATCH;



--SELECT * FROM sys_usuarios WHERE idEntidad = 9999