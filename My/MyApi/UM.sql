/* =========================================================
   1) cat_magnitudMedida
   ========================================================= */
IF OBJECT_ID('dbo.cat_magnitudMedida', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.cat_magnitudMedida
    (
        id		             INT IDENTITY(1,1) NOT NULL,
        descripcion          VARCHAR(450) NOT NULL,
        comentarios          VARCHAR(450) NULL,
        activo               BIT NOT NULL CONSTRAINT DF_CatMagnitudUnidad_activo DEFAULT (1),
        idEntidad            INT NOT NULL,
        fechaModificacion    DATETIME NULL,
        idUsuarioModifica    INT NULL,
        fechaAlta            DATETIME NOT NULL CONSTRAINT DF_CatMagnitudUnidad_fechaAlta DEFAULT (GETDATE()),
        idUsuarioAlta        INT NOT NULL,

        CONSTRAINT PK_CatMagnitudUnidad PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_CatMagnitudUnidad_desc_ent UNIQUE (idEntidad, descripcion)
    );
END
GO


/* =========================================================
   2) Extender CatalogoUnidadesMedida
   ========================================================= */
-- idMagnitud
IF COL_LENGTH('dbo.cat_UnidadesMedida', 'idMagnitud') IS NULL
BEGIN
    ALTER TABLE dbo.cat_UnidadesMedida
    ADD idMagnitud INT NULL; -- NULL por migración (ya tienes filas)
END
GO

-- factorAUnidadBaseMagnitud
IF COL_LENGTH('dbo.cat_UnidadesMedida', 'factorAUnidadBaseMagnitud') IS NULL
BEGIN
    ALTER TABLE dbo.cat_UnidadesMedida
    ADD factorAUnidadBaseMagnitud DECIMAL(18,8) NULL;
END
GO

-- esUnidadBaseMagnitud
IF COL_LENGTH('dbo.cat_UnidadesMedida', 'esUnidadBaseMagnitud') IS NULL
BEGIN
    ALTER TABLE dbo.cat_UnidadesMedida
    ADD esUnidadBaseMagnitud BIT NOT NULL CONSTRAINT DF_CatUM_esUnidadBaseMagnitud DEFAULT (0);
END
GO

-- precisionRedondeo
IF COL_LENGTH('dbo.cat_UnidadesMedida', 'precisionRedondeo') IS NULL
BEGIN
    ALTER TABLE dbo.cat_UnidadesMedida
    ADD precisionRedondeo TINYINT NULL;
END
GO

-- requiereFactorProducto
IF COL_LENGTH('dbo.cat_UnidadesMedida', 'requiereFactorProducto') IS NULL
BEGIN
    ALTER TABLE dbo.cat_UnidadesMedida
    ADD requiereFactorProducto BIT NOT NULL CONSTRAINT DF_CatUM_requiereFactorProducto DEFAULT (0);
END
GO

-- FK a CatMagnitudUnidad (solo si no existe)
IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_CatalogoUnidadesMedida_CatMagnitudUnidad'
)
BEGIN
    ALTER TABLE dbo.cat_UnidadesMedida
    ADD CONSTRAINT FK_CatalogoUnidadesMedida_CatMagnitudUnidad
        FOREIGN KEY (idMagnitud)
        REFERENCES dbo.cat_MagnitudMedida(id);
END
GO

-- Índice para búsquedas por magnitud
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_CatalogoUnidadesMedida_idMagnitud'
      AND object_id = OBJECT_ID('dbo.cat_UnidadesMedida')
)
BEGIN
    CREATE INDEX IX_CatalogoUnidadesMedida_idMagnitud
    ON dbo.cat_UnidadesMedida(idMagnitud);
END
GO


/* =========================================================
   3) proc_productoUnidadMedida
   ========================================================= */
IF OBJECT_ID('dbo.proc_productoUnidadMedida', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.proc_productoUnidadMedida
    (
        id                    INT IDENTITY(1,1) NOT NULL,

        idProductoServicio     INT NOT NULL,
        idUnidadMedida         INT NOT NULL,

        -- Si es NULL, usas el factor global de la magnitud (cuando aplique).
        -- Si requiereFactorProducto=1 (caja/bolsa/etc), aquí DEBE venir el factor real.
        factorAUnidadBaseProducto DECIMAL(18,8) NULL,

        esCompra               BIT NOT NULL CONSTRAINT DF_ProdUM_esCompra DEFAULT (0),
        esVenta                BIT NOT NULL CONSTRAINT DF_ProdUM_esVenta DEFAULT (0),
        esDefaultCompra        BIT NOT NULL CONSTRAINT DF_ProdUM_esDefaultCompra DEFAULT (0),
        esDefaultVenta         BIT NOT NULL CONSTRAINT DF_ProdUM_esDefaultVenta DEFAULT (0),

        codigoBarrasPresentacion VARCHAR(100) NULL,

        -- Auditoría estándar
        descripcion            VARCHAR(450) NOT NULL,  -- etiqueta/presentación (ej: "Caja x12", "Gramos", etc.)
        comentarios            VARCHAR(450) NULL,
        activo                 BIT NOT NULL CONSTRAINT DF_ProdUM_activo DEFAULT (1),
        idEntidad              INT NOT NULL,
        fechaModificacion      DATETIME NULL,
        idUsuarioModifica      INT NULL,
        fechaAlta              DATETIME NOT NULL CONSTRAINT DF_ProdUM_fechaAlta DEFAULT (GETDATE()),
        idUsuarioAlta          INT NOT NULL,

        CONSTRAINT PK_proc_productoUnidadMedida PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_proc_productoUnidadMedida UNIQUE (idProductoServicio, idUnidadMedida),

        -- Reglas básicas
        CONSTRAINT CK_ProdUM_CompraOVenta CHECK (esCompra = 1 OR esVenta = 1),
        CONSTRAINT CK_ProdUM_DefaultCompraImplicaCompra CHECK (esDefaultCompra = 0 OR esCompra = 1),
        CONSTRAINT CK_ProdUM_DefaultVentaImplicaVenta CHECK (esDefaultVenta = 0 OR esVenta = 1)
    );



    -- FK a ProductoServicio (AJUSTA el nombre si tu tabla se llama diferente)
    ALTER TABLE dbo.proc_productoUnidadMedida
    ADD CONSTRAINT FK_ProdUM_ProductoServicio
        FOREIGN KEY (idProductoServicio)
        REFERENCES dbo.cat_productosServicios(id);

	
	IF NOT EXISTS (
		SELECT 1
		FROM sys.indexes
		WHERE name = 'UX_proc_productoUnidadMedida_idEntidad_id'
		  AND object_id = OBJECT_ID('dbo.proc_productoUnidadMedida')
	)
	BEGIN
		CREATE UNIQUE INDEX UX_proc_productoUnidadMedida_idEntidad_id
		ON dbo.proc_productoUnidadMedida (idEntidad, id);
	END
    ALTER TABLE dbo.proc_productoUnidadMedida
    ADD CONSTRAINT FK_ProdUM_CatalogoUnidadesMedida
        FOREIGN KEY (idUnidadMedida)
        REFERENCES dbo.cat_unidadesMedida(id);

    CREATE INDEX IX_ProdUM_Producto ON dbo.proc_productoUnidadMedida(idProductoServicio);
    CREATE INDEX IX_ProdUM_Unidad   ON dbo.proc_productoUnidadMedida(idUnidadMedida);




END


/* =========================================================
   4) proc_ProductoPrecioUnidad (opcional)
   Nota: dejo 1 precio por (producto, unidad). Si luego quieres historial
   por vigencias, se ajusta el UNIQUE.
   ========================================================= */
IF OBJECT_ID('dbo.proc_ProductoPrecioUnidad', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.proc_ProductoPrecioUnidad
    (
        id                    INT IDENTITY(1,1) NOT NULL,

        idProductoServicio     INT NOT NULL,
        idUnidadMedida         INT NOT NULL,

        precioVenta            DECIMAL(18,6) NOT NULL,
        vigenteDesde           DATETIME NULL,
        vigenteHasta           DATETIME NULL,

        -- Auditoría estándar
        descripcion            VARCHAR(450) NOT NULL, -- ej: "Precio caja", "Precio gramo"
        comentarios            VARCHAR(450) NULL,
        activo                 BIT NOT NULL CONSTRAINT DF_ProdPrecioUM_activo DEFAULT (1),
        idEntidad              INT NOT NULL,
        fechaModificacion      DATETIME NULL,
        idUsuarioModifica      INT NULL,
        fechaAlta              DATETIME NOT NULL CONSTRAINT DF_ProdPrecioUM_fechaAlta DEFAULT (GETDATE()),
        idUsuarioAlta          INT NOT NULL,

        CONSTRAINT PK_proc_ProductoPrecioUnidad PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_proc_ProductoPrecioUnidad UNIQUE (idProductoServicio, idUnidadMedida),
        CONSTRAINT CK_ProdPrecioUM_Vigencia CHECK (
            vigenteDesde IS NULL OR vigenteHasta IS NULL OR vigenteHasta >= vigenteDesde
        )
    );

    ALTER TABLE dbo.proc_ProductoPrecioUnidad
    ADD CONSTRAINT FK_ProdPrecioUM_ProductoServicio
        FOREIGN KEY (idProductoServicio)
        REFERENCES dbo.cat_productosServicios(id);

		--PENDIENTEEE
    --ALTER TABLE dbo.proc_ProductoPrecioUnidad
    --ADD CONSTRAINT FK_ProdPrecioUM_CatalogoUnidadesMedida
    --    FOREIGN KEY (idUnidadMedida)
    --    REFERENCES dbo.cat_unidadesMedida(id);

    --CREATE INDEX IX_ProdPrecioUM_Producto ON dbo.proc_ProductoPrecioUnidad(idProductoServicio);
    --CREATE INDEX IX_ProdPrecioUM_Unidad   ON dbo.proc_ProductoPrecioUnidad(idUnidadMedida);
END
GO


IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_cat_unidadesMedida_idEntidad_id'
      AND object_id = OBJECT_ID('dbo.cat_unidadesMedida')
)
BEGIN
    CREATE UNIQUE INDEX UX_cat_unidadesMedida_idEntidad_id
    ON dbo.cat_unidadesMedida (idEntidad, id);
END
GO
-- Si quedó un FK medio creado, bórralo primero (si existe)
IF EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_ProdUM_CatalogoUnidadesMedida'
      AND parent_object_id = OBJECT_ID('dbo.proc_productoUnidadMedida')
)
BEGIN
    ALTER TABLE dbo.proc_productoUnidadMedida
    DROP CONSTRAINT FK_ProdUM_CatalogoUnidadesMedida;
END
GO

-- Crear FK compuesto (recomendado)
ALTER TABLE dbo.proc_productoUnidadMedida
ADD CONSTRAINT FK_ProdUM_CatalogoUnidadesMedida
FOREIGN KEY (idEntidad, idUnidadMedida)
REFERENCES dbo.cat_unidadesMedida (idEntidad, id);
GO
GO




/* =========================================================
   PATCH: Blindaje multi-tenant + constraints + FKs faltantes
   ========================================================= */

------------------------------------------------------------
-- 0) Candidate key en cat_productosServicios para FK compuesto
------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_cat_productosServicios_idEntidad_id'
      AND object_id = OBJECT_ID('dbo.cat_productosServicios')
)
BEGIN
    CREATE UNIQUE INDEX UX_cat_productosServicios_idEntidad_id
    ON dbo.cat_productosServicios (idEntidad, id);
END
GO

------------------------------------------------------------
-- 1) Ajustar FK de proc_productoUnidadMedida -> productos (compuesto)
------------------------------------------------------------
IF EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_ProdUM_ProductoServicio'
      AND parent_object_id = OBJECT_ID('dbo.proc_productoUnidadMedida')
)
BEGIN
    ALTER TABLE dbo.proc_productoUnidadMedida
    DROP CONSTRAINT FK_ProdUM_ProductoServicio;
END
GO

ALTER TABLE dbo.proc_productoUnidadMedida
ADD CONSTRAINT FK_ProdUM_ProductoServicio
FOREIGN KEY (idEntidad, idProductoServicio)
REFERENCES dbo.cat_productosServicios (idEntidad, id);
GO

------------------------------------------------------------
-- 2) Asegurar UNIQUE multi-tenant en proc_productoUnidadMedida
--    (reemplaza el UNIQUE viejo sin idEntidad)
------------------------------------------------------------
IF EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = 'UQ_proc_productoUnidadMedida'
      AND parent_object_id = OBJECT_ID('dbo.proc_productoUnidadMedida')
)
BEGIN
    ALTER TABLE dbo.proc_productoUnidadMedida
    DROP CONSTRAINT UQ_proc_productoUnidadMedida;
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_proc_productoUnidadMedida_Ent_Prod_Unidad'
      AND object_id = OBJECT_ID('dbo.proc_productoUnidadMedida')
)
BEGIN
    CREATE UNIQUE INDEX UX_proc_productoUnidadMedida_Ent_Prod_Unidad
    ON dbo.proc_productoUnidadMedida (idEntidad, idProductoServicio, idUnidadMedida);
END
GO

------------------------------------------------------------
-- 3) Índices únicos filtrados: 1 default compra/venta por producto
------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'UX_ProdUM_DefaultCompra'
      AND object_id = OBJECT_ID('dbo.proc_productoUnidadMedida')
)
BEGIN
    CREATE UNIQUE INDEX UX_ProdUM_DefaultCompra
    ON dbo.proc_productoUnidadMedida (idEntidad, idProductoServicio)
    WHERE esDefaultCompra = 1 AND activo = 1;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'UX_ProdUM_DefaultVenta'
      AND object_id = OBJECT_ID('dbo.proc_productoUnidadMedida')
)
BEGIN
    CREATE UNIQUE INDEX UX_ProdUM_DefaultVenta
    ON dbo.proc_productoUnidadMedida (idEntidad, idProductoServicio)
    WHERE esDefaultVenta = 1 AND activo = 1;
END
GO

------------------------------------------------------------
-- 4) Blindaje en cat_unidadesMedida (reglas globales)
------------------------------------------------------------
-- factor global > 0 cuando exista
IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_catUM_factorGlobalPositivo'
      AND parent_object_id = OBJECT_ID('dbo.cat_unidadesMedida')
)
BEGIN
    ALTER TABLE dbo.cat_unidadesMedida
    ADD CONSTRAINT CK_catUM_factorGlobalPositivo
    CHECK (factorAUnidadBaseMagnitud IS NULL OR factorAUnidadBaseMagnitud > 0);
END
GO

-- si requiereFactorProducto=1 => factorAUnidadBaseMagnitud debe ser NULL
IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_catUM_packagingSinFactorGlobal'
      AND parent_object_id = OBJECT_ID('dbo.cat_unidadesMedida')
)
BEGIN
    ALTER TABLE dbo.cat_unidadesMedida
    ADD CONSTRAINT CK_catUM_packagingSinFactorGlobal
    CHECK (requiereFactorProducto = 0 OR factorAUnidadBaseMagnitud IS NULL);
END
GO

-- 1 sola unidad base por magnitud (por entidad) usando índice filtrado
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_catUM_BasePorMagnitud'
      AND object_id = OBJECT_ID('dbo.cat_unidadesMedida')
)
BEGIN
    CREATE UNIQUE INDEX UX_catUM_BasePorMagnitud
    ON dbo.cat_unidadesMedida (idEntidad, idMagnitud)
    WHERE esUnidadBaseMagnitud = 1 AND activo = 1;
END
GO

------------------------------------------------------------
-- 5) Completar proc_ProductoPrecioUnidad: FKs + índices + UNIQUE multi-tenant
------------------------------------------------------------
-- FK a productos (compuesto)
IF EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_ProdPrecioUM_ProductoServicio'
      AND parent_object_id = OBJECT_ID('dbo.proc_ProductoPrecioUnidad')
)
BEGIN
    ALTER TABLE dbo.proc_ProductoPrecioUnidad
    DROP CONSTRAINT FK_ProdPrecioUM_ProductoServicio;
END
GO

ALTER TABLE dbo.proc_ProductoPrecioUnidad
ADD CONSTRAINT FK_ProdPrecioUM_ProductoServicio
FOREIGN KEY (idEntidad, idProductoServicio)
REFERENCES dbo.cat_productosServicios (idEntidad, id);
GO

-- FK a unidades (compuesto)
IF EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_ProdPrecioUM_CatalogoUnidadesMedida'
      AND parent_object_id = OBJECT_ID('dbo.proc_ProductoPrecioUnidad')
)
BEGIN
    ALTER TABLE dbo.proc_ProductoPrecioUnidad
    DROP CONSTRAINT FK_ProdPrecioUM_CatalogoUnidadesMedida;
END
GO

ALTER TABLE dbo.proc_ProductoPrecioUnidad
ADD CONSTRAINT FK_ProdPrecioUM_CatalogoUnidadesMedida
FOREIGN KEY (idEntidad, idUnidadMedida)
REFERENCES dbo.cat_unidadesMedida (idEntidad, id);
GO

-- Reemplazar UNIQUE viejo (sin idEntidad)
IF EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = 'UQ_proc_ProductoPrecioUnidad'
      AND parent_object_id = OBJECT_ID('dbo.proc_ProductoPrecioUnidad')
)
BEGIN
    ALTER TABLE dbo.proc_ProductoPrecioUnidad
    DROP CONSTRAINT UQ_proc_ProductoPrecioUnidad;
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_ProdPrecioUM_Ent_Prod_Unidad'
      AND object_id = OBJECT_ID('dbo.proc_ProductoPrecioUnidad')
)
BEGIN
    CREATE UNIQUE INDEX UX_ProdPrecioUM_Ent_Prod_Unidad
    ON dbo.proc_ProductoPrecioUnidad (idEntidad, idProductoServicio, idUnidadMedida);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_ProdPrecioUM_Producto'
      AND object_id = OBJECT_ID('dbo.proc_ProductoPrecioUnidad')
)
BEGIN
    CREATE INDEX IX_ProdPrecioUM_Producto
    ON dbo.proc_ProductoPrecioUnidad (idEntidad, idProductoServicio);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_ProdPrecioUM_Unidad'
      AND object_id = OBJECT_ID('dbo.proc_ProductoPrecioUnidad')
)
BEGIN
    CREATE INDEX IX_ProdPrecioUM_Unidad
    ON dbo.proc_ProductoPrecioUnidad (idEntidad, idUnidadMedida);
END
GO

Select * From cat_magnitudMedida
Select * From cat_unidadesMedida
Select * From proc_productoUnidadMedida
Select * From proc_ProductoPrecioUnidad
Select * From proc_unidadMedidaConversion

CREATE OR ALTER TRIGGER dbo.trg_ProductoUnidadMedida_ValidaFactor
ON dbo.proc_productoUnidadMedida
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Si se especifica factor, debe ser > 0
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.factorAUnidadBaseProducto IS NOT NULL
          AND i.factorAUnidadBaseProducto <= 0
    )
    BEGIN
        THROW 51000, 'factorAUnidadBaseProducto debe ser mayor que 0 cuando se especifique.', 1;
    END;

    -- 2) Packaging => requiere factor por producto (obligatorio)
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.cat_unidadesMedida u
            ON u.idEntidad = i.idEntidad
           AND u.id = i.idUnidadMedida
        WHERE u.requiereFactorProducto = 1
          AND i.factorAUnidadBaseProducto IS NULL
    )
    BEGIN
        THROW 51001, 'La unidad requiereFactorProducto=1; debes capturar factorAUnidadBaseProducto en proc_productoUnidadMedida.', 1;
    END;

    -- 3) Si NO es packaging: debe existir factor global o factor por producto
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.cat_unidadesMedida u
            ON u.idEntidad = i.idEntidad
           AND u.id = i.idUnidadMedida
        WHERE ISNULL(u.requiereFactorProducto, 0) = 0
          AND u.factorAUnidadBaseMagnitud IS NULL
          AND i.factorAUnidadBaseProducto IS NULL
    )
    BEGIN
        THROW 51002, 'No existe factor de conversión: unidad sin factor global y sin factor por producto.', 1;
    END;
END
GO
CREATE OR ALTER TRIGGER dbo.trg_ProductoUnidadMedida_ValidaDefaultsUnicos
ON dbo.proc_productoUnidadMedida
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Impactados TABLE
    (
        idEntidad INT NOT NULL,
        idProductoServicio INT NOT NULL,
        PRIMARY KEY (idEntidad, idProductoServicio)
    );

    INSERT INTO @Impactados (idEntidad, idProductoServicio)
    SELECT DISTINCT idEntidad, idProductoServicio
    FROM inserted;

    -- DefaultCompra no puede existir en inactivos
    IF EXISTS (
        SELECT 1
        FROM dbo.proc_productoUnidadMedida pum
        INNER JOIN @Impactados x
            ON x.idEntidad = pum.idEntidad
           AND x.idProductoServicio = pum.idProductoServicio
        WHERE pum.esDefaultCompra = 1
          AND pum.activo = 0
    )
    BEGIN
        THROW 51010, 'esDefaultCompra=1 no puede existir en registros inactivos (activo=0).', 1;
    END;

    -- DefaultVenta no puede existir en inactivos
    IF EXISTS (
        SELECT 1
        FROM dbo.proc_productoUnidadMedida pum
        INNER JOIN @Impactados x
            ON x.idEntidad = pum.idEntidad
           AND x.idProductoServicio = pum.idProductoServicio
        WHERE pum.esDefaultVenta = 1
          AND pum.activo = 0
    )
    BEGIN
        THROW 51011, 'esDefaultVenta=1 no puede existir en registros inactivos (activo=0).', 1;
    END;
END
GO
CREATE OR ALTER TRIGGER dbo.trg_ProductoUnidadMedida_ValidaMagnitud
ON dbo.proc_productoUnidadMedida
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.cat_productosServicios p
            ON p.idEntidad = i.idEntidad
           AND p.id = i.idProductoServicio
        INNER JOIN dbo.cat_unidadesMedida uCaptura
            ON uCaptura.idEntidad = i.idEntidad
           AND uCaptura.id = i.idUnidadMedida
        INNER JOIN dbo.cat_unidadesMedida uBase
            ON uBase.idEntidad = p.idEntidad
           AND uBase.id = p.idUnidadMedidaBase
        WHERE ISNULL(uCaptura.requiereFactorProducto,0) = 0
          AND uCaptura.idMagnitud IS NOT NULL
          AND uBase.idMagnitud IS NOT NULL
          AND uCaptura.idMagnitud <> uBase.idMagnitud
    )
    BEGIN
        THROW 51003, 'Magnitud inválida: la unidad no coincide con la magnitud de la unidad base del producto.', 1;
    END;
END
GO


--Select * From cat_productosServicios
--select * From proc_movimientosInventarios
--select * From proc_movimientosInventariosDetalles

/* 1.1 Agregar ID identity (recomendado) */
IF COL_LENGTH('dbo.proc_movimientosInventariosDetalles', 'id') IS NULL
BEGIN
    ALTER TABLE dbo.proc_movimientosInventariosDetalles
    ADD id BIGINT IDENTITY(1,1) NOT NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'UX_proc_movInvDet_id'
      AND object_id = OBJECT_ID('dbo.proc_movimientosInventariosDetalles')
)
BEGIN
    CREATE UNIQUE INDEX UX_proc_movInvDet_id
    ON dbo.proc_movimientosInventariosDetalles(id);
END
GO

/* 1.2 Columnas de conversión */
IF COL_LENGTH('dbo.proc_movimientosInventariosDetalles', 'cantidadBase') IS NULL
    ALTER TABLE dbo.proc_movimientosInventariosDetalles ADD cantidadBase DECIMAL(18,8) NULL;
GO

IF COL_LENGTH('dbo.proc_movimientosInventariosDetalles', 'idUnidadMedidaBase') IS NULL
    ALTER TABLE dbo.proc_movimientosInventariosDetalles ADD idUnidadMedidaBase INT NULL;
GO

IF COL_LENGTH('dbo.proc_movimientosInventariosDetalles', 'factorConversionAplicado') IS NULL
    ALTER TABLE dbo.proc_movimientosInventariosDetalles ADD factorConversionAplicado DECIMAL(18,8) NULL;
GO

IF COL_LENGTH('dbo.proc_movimientosInventariosDetalles', 'costoUnitarioBase') IS NULL
    ALTER TABLE dbo.proc_movimientosInventariosDetalles ADD costoUnitarioBase DECIMAL(18,8) NULL;
GO

IF COL_LENGTH('dbo.proc_movimientosInventariosDetalles', 'precioVentaUnitarioBase') IS NULL
    ALTER TABLE dbo.proc_movimientosInventariosDetalles ADD precioVentaUnitarioBase DECIMAL(18,8) NULL;
GO

/* FK a productos (compuesto) */
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_MovInvDet_Producto'
      AND parent_object_id = OBJECT_ID('dbo.proc_movimientosInventariosDetalles')
)
BEGIN
    ALTER TABLE dbo.proc_movimientosInventariosDetalles
    ADD CONSTRAINT FK_MovInvDet_Producto
    FOREIGN KEY (idEntidad, idProductoServicio)
    REFERENCES dbo.cat_productosServicios (idEntidad, id);
END
GO

/* FK a unidad capturada (compuesto) */ --PENDIENTEEE
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_MovInvDet_UnidadCaptura'
      AND parent_object_id = OBJECT_ID('dbo.proc_movimientosInventariosDetalles')
)
BEGIN
    ALTER TABLE dbo.proc_movimientosInventariosDetalles
    ADD CONSTRAINT FK_MovInvDet_UnidadCaptura
    FOREIGN KEY (idEntidad, idUnidadMedida)
    REFERENCES dbo.cat_unidadesMedida (idEntidad, id);
END
GO

CREATE OR ALTER FUNCTION dbo.fn_FactorUnidadAUnidadBaseProducto
(
    @idEntidad INT,
    @idProductoServicio INT,
    @idUnidadMedida INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        idUnidadMedidaBase = p.idUnidadMedidaBase,

        factor = CASE
            WHEN @idUnidadMedida = p.idUnidadMedidaBase THEN CAST(1.0 AS DECIMAL(18,8))

            -- factor por producto (si existe)
            WHEN pum.factorAUnidadBaseProducto IS NOT NULL THEN pum.factorAUnidadBaseProducto

            -- si requiere factor por producto pero no hay registro/valor -> NULL (se valida en trigger)
            WHEN ISNULL(uCap.requiereFactorProducto,0) = 1 THEN CAST(NULL AS DECIMAL(18,8))

            -- conversión global por magnitud
            WHEN uCap.idMagnitud IS NULL OR uBase.idMagnitud IS NULL THEN CAST(NULL AS DECIMAL(18,8))
            WHEN uCap.idMagnitud <> uBase.idMagnitud THEN CAST(NULL AS DECIMAL(18,8))
            WHEN uCap.factorAUnidadBaseMagnitud IS NULL OR uBase.factorAUnidadBaseMagnitud IS NULL THEN CAST(NULL AS DECIMAL(18,8))
            ELSE uCap.factorAUnidadBaseMagnitud / NULLIF(uBase.factorAUnidadBaseMagnitud, 0)
        END
    FROM dbo.cat_productosServicios p
    LEFT JOIN dbo.proc_productoUnidadMedida pum
        ON pum.idEntidad = p.idEntidad
       AND pum.idProductoServicio = p.id
       AND pum.idUnidadMedida = @idUnidadMedida
       AND pum.activo = 1
    LEFT JOIN dbo.cat_unidadesMedida uCap
        ON uCap.idEntidad = p.idEntidad
       AND uCap.id = @idUnidadMedida
    LEFT JOIN dbo.cat_unidadesMedida uBase
        ON uBase.idEntidad = p.idEntidad
       AND uBase.id = p.idUnidadMedidaBase
    WHERE p.idEntidad = @idEntidad
      AND p.id = @idProductoServicio
);
GO

CREATE OR ALTER TRIGGER dbo.trg_MovInvDet_CalculaBase
ON dbo.proc_movimientosInventariosDetalles
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Evitar re-entrada si el trigger actualiza la misma tabla
    IF TRIGGER_NESTLEVEL() > 1 RETURN;

    DECLARE @Calc TABLE
    (
        id BIGINT PRIMARY KEY,
        idEntidad INT NOT NULL,
        idProductoServicio INT NOT NULL,
        idUnidadMedida INT NOT NULL,
        idUnidadMedidaBase INT NOT NULL,
        factor DECIMAL(18,8) NULL
    );

    INSERT INTO @Calc (id, idEntidad, idProductoServicio, idUnidadMedida, idUnidadMedidaBase, factor)
    SELECT
        d.id,
        i.idEntidad,
        i.idProductoServicio,
        i.idUnidadMedida,
        f.idUnidadMedidaBase,
        f.factor
    FROM inserted i
    INNER JOIN dbo.proc_movimientosInventariosDetalles d
        ON d.id = i.id
    OUTER APPLY dbo.fn_FactorUnidadAUnidadBaseProducto(i.idEntidad, i.idProductoServicio, i.idUnidadMedida) f;

    -- 1) Si no hay factor, no se puede convertir => error
    IF EXISTS (SELECT 1 FROM @Calc WHERE factor IS NULL)
    BEGIN
        THROW 52000, 'No se pudo calcular factor de conversión hacia unidad base del producto. Revisa configuración de unidades/magnitud o factor por producto (packaging).', 1;
    END;

    -- 2) Guardar base + factor + costos/precios base
    UPDATE d
    SET
        d.idUnidadMedidaBase = c.idUnidadMedidaBase,
        d.factorConversionAplicado = c.factor,
        d.cantidadBase = CAST(d.cantidad AS DECIMAL(18,8)) * c.factor,

        d.costoUnitarioBase =
            CASE
                WHEN d.costoUnitario IS NULL THEN NULL
                ELSE CAST(d.costoUnitario AS DECIMAL(18,8)) / NULLIF(c.factor, 0)
            END,

        d.precioVentaUnitarioBase =
            CASE
                WHEN d.precioVentaUnitario IS NULL THEN NULL
                ELSE CAST(d.precioVentaUnitario AS DECIMAL(18,8)) / NULLIF(c.factor, 0)
            END
    FROM dbo.proc_movimientosInventariosDetalles d
    INNER JOIN @Calc c
        ON c.id = d.id;
END
GO