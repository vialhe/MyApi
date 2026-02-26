DECLARE @DiasMov INT = 30;                 -- valida movimientos de los últimos N días
DECLARE @Tol DECIMAL(18,8) = 0.00010000;   -- tolerancia para comparaciones decimales

;WITH Entidades AS (
    SELECT DISTINCT idEntidad FROM dbo.cat_unidadesMedida
    UNION
    SELECT DISTINCT idEntidad FROM dbo.cat_productosServicios
),
MagnitudesReq AS (
    SELECT * FROM (VALUES ('Conteo'),('Masa'),('Volumen')) v(descripcion)
),
MovRecientes AS (
    SELECT *
    FROM dbo.proc_movimientosInventariosDetalles
    WHERE fechaAlta >= DATEADD(DAY, -@DiasMov, GETDATE())
)
SELECT
    CheckName,
    CASE WHEN Issues = 0 THEN 'OK' ELSE 'FAIL' END AS Estado,
    Issues
FROM (
    /* =========================================================
       A) Magnitudes / Unidades
       ========================================================= */

    -- A1: Cada entidad debe tener Conteo/Masa/Volumen en cat_magnitudMedida
    SELECT
        'A1 Magnitudes requeridas por entidad (Conteo/Masa/Volumen)' AS CheckName,
        (
            SELECT COUNT(*)
            FROM Entidades e
            CROSS JOIN MagnitudesReq r
            LEFT JOIN dbo.cat_magnitudMedida m
              ON m.idEntidad = e.idEntidad
             AND m.descripcion = r.descripcion
             AND m.activo = 1
            WHERE m.id IS NULL
        ) AS Issues

    UNION ALL
    -- A2: Unidades sin magnitud
    SELECT
        'A2 Unidades SIN idMagnitud' AS CheckName,
        (SELECT COUNT(*) FROM dbo.cat_unidadesMedida WHERE idMagnitud IS NULL) AS Issues

    UNION ALL
    -- A3: Unidades NO packaging sin factor global
    SELECT
        'A3 Unidades requiereFactorProducto=0 SIN factorAUnidadBaseMagnitud' AS CheckName,
        (
            SELECT COUNT(*)
            FROM dbo.cat_unidadesMedida
            WHERE ISNULL(requiereFactorProducto,0) = 0
              AND factorAUnidadBaseMagnitud IS NULL
        ) AS Issues

    UNION ALL
    -- A4: Unidades packaging con factor global (debe ser NULL)
    SELECT
        'A4 Unidades requiereFactorProducto=1 CON factorAUnidadBaseMagnitud (debe ser NULL)' AS CheckName,
        (
            SELECT COUNT(*)
            FROM dbo.cat_unidadesMedida
            WHERE ISNULL(requiereFactorProducto,0) = 1
              AND factorAUnidadBaseMagnitud IS NOT NULL
        ) AS Issues

    UNION ALL
    -- A5: factor global <= 0 (cuando exista)
    SELECT
        'A5 Unidades con factorAUnidadBaseMagnitud <= 0' AS CheckName,
        (
            SELECT COUNT(*)
            FROM dbo.cat_unidadesMedida
            WHERE factorAUnidadBaseMagnitud IS NOT NULL
              AND factorAUnidadBaseMagnitud <= 0
        ) AS Issues

    UNION ALL
    -- A6: Base por magnitud: faltantes (Conteo/Masa/Volumen)
    SELECT
        'A6 Falta unidad base por magnitud (por entidad)' AS CheckName,
        (
            SELECT COUNT(*)
            FROM dbo.cat_magnitudMedida m
            LEFT JOIN dbo.cat_unidadesMedida u
              ON u.idEntidad = m.idEntidad
             AND u.idMagnitud = m.id
             AND u.esUnidadBaseMagnitud = 1
             AND u.activo = 1
            WHERE m.descripcion IN ('Conteo','Masa','Volumen')
              AND u.id IS NULL
        ) AS Issues

    UNION ALL
    -- A7: Más de 1 base por magnitud (no debería pasar por índice filtrado)
    SELECT
        'A7 Más de 1 unidad base por magnitud (por entidad)' AS CheckName,
        (
            SELECT COUNT(*)
            FROM (
                SELECT idEntidad, idMagnitud
                FROM dbo.cat_unidadesMedida
                WHERE esUnidadBaseMagnitud = 1 AND activo = 1
                GROUP BY idEntidad, idMagnitud
                HAVING COUNT(*) > 1
            ) x
        ) AS Issues

    /* =========================================================
       B) Productos / ProductoUnidadMedida
       ========================================================= */

    UNION ALL
    -- B1: Productos activos con unidad base inexistente en catálogo (multi-tenant)
    SELECT
        'B1 Productos activos con idUnidadMedidaBase inexistente en cat_unidadesMedida' AS CheckName,
        (
            SELECT COUNT(*)
            FROM dbo.cat_productosServicios p
            LEFT JOIN dbo.cat_unidadesMedida u
              ON u.idEntidad = p.idEntidad
             AND u.id = p.idUnidadMedidaBase
            WHERE p.activo = 1
              AND p.idUnidadMedidaBase IS NOT NULL
              AND u.id IS NULL
        ) AS Issues

    UNION ALL
    -- B2: Productos activos con unidad compra inexistente
    SELECT
        'B2 Productos activos con idUnidadMedidaCompra inexistente en cat_unidadesMedida' AS CheckName,
        (
            SELECT COUNT(*)
            FROM dbo.cat_productosServicios p
            LEFT JOIN dbo.cat_unidadesMedida u
              ON u.idEntidad = p.idEntidad
             AND u.id = p.idUnidadMedidaCompra
            WHERE p.activo = 1
              AND p.idUnidadMedidaCompra IS NOT NULL
              AND u.id IS NULL
        ) AS Issues

    UNION ALL
    -- B3: Productos activos con unidad venta inexistente
    SELECT
        'B3 Productos activos con idUnidadMedidaVenta inexistente en cat_unidadesMedida' AS CheckName,
        (
            SELECT COUNT(*)
            FROM dbo.cat_productosServicios p
            LEFT JOIN dbo.cat_unidadesMedida u
              ON u.idEntidad = p.idEntidad
             AND u.id = p.idUnidadMedidaVenta
            WHERE p.activo = 1
              AND p.idUnidadMedidaVenta IS NOT NULL
              AND u.id IS NULL
        ) AS Issues

    UNION ALL
    -- B4: Compra/Venta con magnitud distinta a la base (solo si NO es packaging)
    SELECT
        'B4 Productos con UM compra/venta de magnitud distinta a la UM base (no packaging)' AS CheckName,
        (
            SELECT COUNT(*)
            FROM dbo.cat_productosServicios p
            JOIN dbo.cat_unidadesMedida uBase
              ON uBase.idEntidad = p.idEntidad AND uBase.id = p.idUnidadMedidaBase
            LEFT JOIN dbo.cat_unidadesMedida uC
              ON uC.idEntidad = p.idEntidad AND uC.id = p.idUnidadMedidaCompra
            LEFT JOIN dbo.cat_unidadesMedida uV
              ON uV.idEntidad = p.idEntidad AND uV.id = p.idUnidadMedidaVenta
            WHERE p.activo = 1
              AND (
                    (uC.id IS NOT NULL AND ISNULL(uC.requiereFactorProducto,0)=0 AND uC.idMagnitud IS NOT NULL AND uBase.idMagnitud IS NOT NULL AND uC.idMagnitud <> uBase.idMagnitud)
                 OR (uV.id IS NOT NULL AND ISNULL(uV.requiereFactorProducto,0)=0 AND uV.idMagnitud IS NOT NULL AND uBase.idMagnitud IS NOT NULL AND uV.idMagnitud <> uBase.idMagnitud)
                  )
        ) AS Issues

    UNION ALL
    -- B5: ProductoUnidadMedida: cada producto activo debe tener 1 default compra y 1 default venta (activos)
    SELECT
        'B5 proc_productoUnidadMedida: defaults compra/venta != 1 por producto' AS CheckName,
        (
            SELECT COUNT(*)
            FROM (
                SELECT
                    idEntidad, idProductoServicio,
                    SUM(CASE WHEN esDefaultCompra=1 AND activo=1 THEN 1 ELSE 0 END) AS defC,
                    SUM(CASE WHEN esDefaultVenta =1 AND activo=1 THEN 1 ELSE 0 END) AS defV
                FROM dbo.proc_productoUnidadMedida
                GROUP BY idEntidad, idProductoServicio
                HAVING SUM(CASE WHEN esDefaultCompra=1 AND activo=1 THEN 1 ELSE 0 END) <> 1
                    OR SUM(CASE WHEN esDefaultVenta =1 AND activo=1 THEN 1 ELSE 0 END) <> 1
            ) x
        ) AS Issues

    UNION ALL
    -- B6: Defaults en registros inactivos (no debe existir)
    SELECT
        'B6 proc_productoUnidadMedida: defaults marcados en registros inactivos' AS CheckName,
        (
            SELECT COUNT(*)
            FROM dbo.proc_productoUnidadMedida
            WHERE activo = 0
              AND (esDefaultCompra = 1 OR esDefaultVenta = 1)
        ) AS Issues

    UNION ALL
    -- B7: ProductoUnidadMedida debe tener al menos la fila de la UM base del producto
    SELECT
        'B7 proc_productoUnidadMedida: falta fila para UM base del producto' AS CheckName,
        (
            SELECT COUNT(*)
            FROM dbo.cat_productosServicios p
            WHERE p.activo = 1
              AND p.idUnidadMedidaBase IS NOT NULL
              AND NOT EXISTS (
                    SELECT 1
                    FROM dbo.proc_productoUnidadMedida pum
                    WHERE pum.idEntidad = p.idEntidad
                      AND pum.idProductoServicio = p.id
                      AND pum.idUnidadMedida = p.idUnidadMedidaBase
                      AND pum.activo = 1
              )
        ) AS Issues

    /* =========================================================
       C) Movimientos: original + base
       ========================================================= */

    UNION ALL
    -- C1: Movimientos recientes sin cálculo de base (campos nulos)
    SELECT
        'C1 MovInvDet recientes SIN cantidadBase/idUnidadMedidaBase/factorConversionAplicado' AS CheckName,
        (
            SELECT COUNT(*)
            FROM MovRecientes d
            WHERE d.cantidadBase IS NULL
               OR d.idUnidadMedidaBase IS NULL
               OR d.factorConversionAplicado IS NULL
        ) AS Issues

    UNION ALL
    -- C2: Movimientos recientes donde UM base calculada != UM base del producto
    SELECT
        'C2 MovInvDet recientes con idUnidadMedidaBase != producto.idUnidadMedidaBase' AS CheckName,
        (
            SELECT COUNT(*)
            FROM MovRecientes d
            JOIN dbo.cat_productosServicios p
              ON p.idEntidad = d.idEntidad AND p.id = d.idProductoServicio
            WHERE d.idUnidadMedidaBase IS NOT NULL
              AND p.idUnidadMedidaBase IS NOT NULL
              AND d.idUnidadMedidaBase <> p.idUnidadMedidaBase
        ) AS Issues

    UNION ALL
    -- C3: Movimientos recientes con factor <= 0
    SELECT
        'C3 MovInvDet recientes con factorConversionAplicado <= 0' AS CheckName,
        (
            SELECT COUNT(*)
            FROM MovRecientes d
            WHERE d.factorConversionAplicado IS NOT NULL
              AND d.factorConversionAplicado <= 0
        ) AS Issues

    UNION ALL
    -- C4: Movimientos recientes: fórmula cantidadBase ≈ cantidad * factor (con tolerancia)
    SELECT
        'C4 MovInvDet recientes con inconsistencia cantidadBase vs cantidad*factor' AS CheckName,
        (
            SELECT COUNT(*)
            FROM MovRecientes d
            WHERE d.cantidadBase IS NOT NULL
              AND d.factorConversionAplicado IS NOT NULL
              AND ABS(d.cantidadBase - (CAST(d.cantidad AS DECIMAL(18,8)) * d.factorConversionAplicado)) > @Tol
        ) AS Issues

    UNION ALL
    -- C5: Movimientos recientes con unidad capturada inexistente (debería ser 0 si FK ya está)
    SELECT
        'C5 MovInvDet recientes con unidad capturada inexistente en cat_unidadesMedida' AS CheckName,
        (
            SELECT COUNT(*)
            FROM MovRecientes d
            LEFT JOIN dbo.cat_unidadesMedida u
              ON u.idEntidad = d.idEntidad AND u.id = d.idUnidadMedida
            WHERE d.idUnidadMedida IS NOT NULL
              AND u.id IS NULL
        ) AS Issues

    UNION ALL
    -- C6: Movimientos recientes con unidad base inexistente (si ya creas FK a unidad base, debe ser 0)
    SELECT
        'C6 MovInvDet recientes con unidad base inexistente en cat_unidadesMedida' AS CheckName,
        (
            SELECT COUNT(*)
            FROM MovRecientes d
            LEFT JOIN dbo.cat_unidadesMedida u
              ON u.idEntidad = d.idEntidad AND u.id = d.idUnidadMedidaBase
            WHERE d.idUnidadMedidaBase IS NOT NULL
              AND u.id IS NULL
        ) AS Issues

    /* =========================================================
       D) Objetos “clave” existentes (función/trigger/índices/FKs)
       ========================================================= */

    UNION ALL
    SELECT
        'D1 Existe función fn_FactorUnidadAUnidadBaseProducto' AS CheckName,
        CASE WHEN OBJECT_ID('dbo.fn_FactorUnidadAUnidadBaseProducto') IS NULL THEN 1 ELSE 0 END AS Issues

    UNION ALL
    SELECT
        'D2 Existe trigger trg_MovInvDet_CalculaBase habilitado' AS CheckName,
        (
            SELECT CASE
                WHEN NOT EXISTS (
                    SELECT 1 FROM sys.triggers
                    WHERE name = 'trg_MovInvDet_CalculaBase'
                      AND parent_id = OBJECT_ID('dbo.proc_movimientosInventariosDetalles')
                      AND is_disabled = 0
                )
                THEN 1 ELSE 0 END
        ) AS Issues

    UNION ALL
    SELECT
        'D3 Índices únicos filtrados defaults (Compra/Venta) existen' AS CheckName,
        (
            SELECT CASE
                WHEN EXISTS (
                    SELECT 1 FROM sys.indexes
                    WHERE object_id = OBJECT_ID('dbo.proc_productoUnidadMedida')
                      AND name IN ('UX_ProdUM_DefaultCompra','UX_ProdUM_DefaultVenta')
                    GROUP BY object_id
                    HAVING COUNT(*) = 2
                )
                THEN 0 ELSE 1 END
        ) AS Issues

    UNION ALL
    SELECT
        'D4 Índice único base por magnitud existe (UX_catUM_BasePorMagnitud)' AS CheckName,
        CASE WHEN EXISTS (
            SELECT 1 FROM sys.indexes
            WHERE object_id = OBJECT_ID('dbo.cat_unidadesMedida')
              AND name = 'UX_catUM_BasePorMagnitud'
        ) THEN 0 ELSE 1 END AS Issues

    UNION ALL
    -- FKs no confiables (si usaste WITH NOCHECK en alguno)
    SELECT
        'D5 Foreign Keys NOT TRUSTED (revisar is_not_trusted=1)' AS CheckName,
        (
            SELECT COUNT(*)
            FROM sys.foreign_keys
            WHERE parent_object_id IN (
                OBJECT_ID('dbo.proc_movimientosInventariosDetalles'),
                OBJECT_ID('dbo.proc_productoUnidadMedida'),
                OBJECT_ID('dbo.proc_ProductoPrecioUnidad')
            )
              AND is_not_trusted = 1
        ) AS Issues

) R
ORDER BY
    CASE
      WHEN LEFT(CheckName,2)='A1' THEN 1
      WHEN LEFT(CheckName,2)='A2' THEN 2
      WHEN LEFT(CheckName,2)='A3' THEN 3
      WHEN LEFT(CheckName,2)='A4' THEN 4
      WHEN LEFT(CheckName,2)='A5' THEN 5
      WHEN LEFT(CheckName,2)='A6' THEN 6
      WHEN LEFT(CheckName,2)='A7' THEN 7
      WHEN LEFT(CheckName,2)='B1' THEN 10
      WHEN LEFT(CheckName,2)='B2' THEN 11
      WHEN LEFT(CheckName,2)='B3' THEN 12
      WHEN LEFT(CheckName,2)='B4' THEN 13
      WHEN LEFT(CheckName,2)='B5' THEN 14
      WHEN LEFT(CheckName,2)='B6' THEN 15
      WHEN LEFT(CheckName,2)='B7' THEN 16
      WHEN LEFT(CheckName,2)='C1' THEN 20
      WHEN LEFT(CheckName,2)='C2' THEN 21
      WHEN LEFT(CheckName,2)='C3' THEN 22
      WHEN LEFT(CheckName,2)='C4' THEN 23
      WHEN LEFT(CheckName,2)='C5' THEN 24
      WHEN LEFT(CheckName,2)='C6' THEN 25
      WHEN LEFT(CheckName,2)='D1' THEN 30
      WHEN LEFT(CheckName,2)='D2' THEN 31
      WHEN LEFT(CheckName,2)='D3' THEN 32
      WHEN LEFT(CheckName,2)='D4' THEN 33
      WHEN LEFT(CheckName,2)='D5' THEN 34
      ELSE 99
    END;