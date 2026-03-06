/* =========================================================
   VALIDACIÓN SETUP TIENDA (antes de entrar al POS)
   - Ajusta @idEntidad y credenciales esperadas
   ========================================================= */
DECLARE @idEntidad INT = 9999;
DECLARE @usuarioAdmin VARCHAR(50) = 'test';
DECLARE @correoAdmin  VARCHAR(150)= 'qas@hotmail.com';

SET NOCOUNT ON;

DECLARE @Checks TABLE(
  codigo VARCHAR(10),
  validacion VARCHAR(200),
  status VARCHAR(10),
  detalle VARCHAR(4000)
);

DECLARE @cnt INT, @eps DECIMAL(18,10) = CAST(0.0000000001 AS DECIMAL(18,10));

/* =========================
   A) ENTIDAD
   ========================= */
SELECT @cnt = COUNT(*) FROM sys_entidades WHERE id=@idEntidad;
INSERT INTO @Checks VALUES
('A1','Entidad existe', IIF(@cnt=1,'OK','FAIL'), CONCAT('Encontradas: ',@cnt));

/* =========================
   B) ADMIN (TipoPersona / Persona / Perfil / Usuario)
   ========================= */
SELECT @cnt = COUNT(*) FROM cat_tiposPersonas WHERE idEntidad=@idEntidad AND descripcion='Administrador';
INSERT INTO @Checks VALUES ('B1','TipoPersona Administrador existe', IIF(@cnt>=1,'OK','FAIL'), CONCAT('Encontradas: ',@cnt));

SELECT @cnt = COUNT(*) FROM cat_tiposPersonas WHERE idEntidad=@idEntidad AND descripcion='Proveedor';
INSERT INTO @Checks VALUES ('B2','TipoPersona Proveedor existe', IIF(@cnt>=1,'OK','FAIL'), CONCAT('Encontradas: ',@cnt));

SELECT @cnt = COUNT(*) FROM cat_personas WHERE idEntidad=@idEntidad AND correo=@correoAdmin;
INSERT INTO @Checks VALUES ('B3','Persona admin existe (por correo)', IIF(@cnt>=1,'OK','FAIL'), CONCAT('Encontradas: ',@cnt));

SELECT @cnt = COUNT(*) FROM sys_perfiles WHERE idEntidad=@idEntidad AND descripcion='Administrador';
INSERT INTO @Checks VALUES ('B4','Perfil Administrador existe', IIF(@cnt>=1,'OK','FAIL'), CONCAT('Encontrados: ',@cnt));

SELECT @cnt = COUNT(*) FROM sys_usuarios WHERE idEntidad=@idEntidad AND usuario=@usuarioAdmin;
INSERT INTO @Checks VALUES ('B5','Usuario admin existe (por usuario)', IIF(@cnt>=1,'OK','FAIL'), CONCAT('Encontrados: ',@cnt));

/* Usuario ligado a persona + perfil */
SELECT @cnt = COUNT(*)
FROM sys_usuarios u
JOIN cat_personas p ON p.id = u.idPersona AND p.idEntidad=@idEntidad
JOIN sys_perfiles pf ON pf.id = u.idPerfil AND pf.idEntidad=@idEntidad
WHERE u.idEntidad=@idEntidad
  AND u.usuario=@usuarioAdmin
  AND p.correo=@correoAdmin
  AND pf.descripcion='Administrador';
INSERT INTO @Checks VALUES ('B6','Usuario admin ligado a Persona+Perfil', IIF(@cnt>=1,'OK','FAIL'), CONCAT('Matches: ',@cnt));

/* Password/Salt (solo aviso) */
SELECT @cnt = COUNT(*)
FROM sys_usuarios
WHERE idEntidad=@idEntidad AND usuario=@usuarioAdmin
  AND (ISNULL(LTRIM(RTRIM(hashpassword)),'')='' OR ISNULL(LTRIM(RTRIM(salt)),'')='');
INSERT INTO @Checks VALUES ('B7','Usuario tiene hashpassword+salt (recomendado)', IIF(@cnt=0,'OK','WARN'),
       IIF(@cnt=0,'OK','hashpassword y/o salt vacío. Si no puedes login, aplica ChangePassword.'));

/* =========================
   C) MAGNITUDES / UNIDADES
   ========================= */
SELECT @cnt = COUNT(*) FROM cat_magnitudMedida WHERE idEntidad=@idEntidad AND descripcion IN ('Conteo','Masa','Volumen');
INSERT INTO @Checks VALUES ('C1','Magnitudes Conteo/Masa/Volumen existen', IIF(@cnt=3,'OK','FAIL'), CONCAT('Encontradas: ',@cnt,' (esperado 3)'));

-- base única por magnitud
;WITH M AS (
  SELECT id AS idMagnitud, descripcion
  FROM cat_magnitudMedida
  WHERE idEntidad=@idEntidad AND descripcion IN ('Conteo','Masa','Volumen')
),
B AS (
  SELECT u.idMagnitud, COUNT(*) baseCount
  FROM cat_unidadesMedida u
  JOIN M ON M.idMagnitud=u.idMagnitud
  WHERE u.idEntidad=@idEntidad AND u.activo=1 AND u.esUnidadBaseMagnitud=1
  GROUP BY u.idMagnitud
)
SELECT @cnt = COUNT(*) FROM B WHERE baseCount<>1;
INSERT INTO @Checks VALUES ('C2','Cada magnitud tiene 1 sola unidad base', IIF(@cnt=0,'OK','FAIL'),
  IIF(@cnt=0,'OK','Hay magnitudes con 0 o >1 base'));

-- base factor = 1
SELECT @cnt = COUNT(*)
FROM cat_unidadesMedida u
JOIN cat_magnitudMedida m ON m.id=u.idMagnitud AND m.idEntidad=@idEntidad
WHERE u.idEntidad=@idEntidad AND u.activo=1
  AND u.esUnidadBaseMagnitud=1
  AND CAST(u.factorAUnidadBaseMagnitud AS DECIMAL(18,10)) <> CAST(1 AS DECIMAL(18,10));
INSERT INTO @Checks VALUES ('C3','Unidad base tiene factor=1', IIF(@cnt=0,'OK','FAIL'),
  IIF(@cnt=0,'OK',CONCAT('Bases con factor != 1: ',@cnt)));

-- base esperada por magnitud (pza/g/ml)
SELECT @cnt = COUNT(*)
FROM cat_unidadesMedida u
JOIN cat_magnitudMedida m ON m.id=u.idMagnitud AND m.idEntidad=@idEntidad
WHERE u.idEntidad=@idEntidad AND u.activo=1 AND u.esUnidadBaseMagnitud=1
  AND (
    (m.descripcion='Conteo'  AND u.abreviatura<>'pza') OR
    (m.descripcion='Masa'    AND u.abreviatura<>'g')   OR
    (m.descripcion='Volumen' AND u.abreviatura<>'ml')
  );
INSERT INTO @Checks VALUES ('C4','Base por magnitud es pza/g/ml', IIF(@cnt=0,'OK','WARN'),
  IIF(@cnt=0,'OK','La base no coincide con pza/g/ml (puede ser intencional).'));

-- abreviaturas duplicadas
SELECT @cnt = COUNT(*)
FROM (
  SELECT abreviatura
  FROM cat_unidadesMedida
  WHERE idEntidad=@idEntidad AND activo=1 AND abreviatura IS NOT NULL AND LTRIM(RTRIM(abreviatura))<>''
  GROUP BY abreviatura
  HAVING COUNT(*)>1
) d;
INSERT INTO @Checks VALUES ('C5','No hay abreviaturas duplicadas', IIF(@cnt=0,'OK','FAIL'),
  IIF(@cnt=0,'OK',CONCAT('Duplicadas: ',@cnt)));

/* =========================
   D) CONVERSIONES
   ========================= */
;WITH U AS (
  SELECT
    u.id AS idUM,
    u.idMagnitud,
    CAST(u.factorAUnidadBaseMagnitud AS DECIMAL(18,10)) AS factorBase
  FROM cat_unidadesMedida u
  WHERE u.idEntidad=@idEntidad AND u.activo=1
),
Pairs AS (
  SELECT u1.idMagnitud, u1.idUM AS idUMOrigen, u2.idUM AS idUMDestino,
         CAST(u1.factorBase / NULLIF(u2.factorBase,0) AS DECIMAL(18,10)) AS factorEsperado
  FROM U u1
  JOIN U u2 ON u1.idMagnitud=u2.idMagnitud AND u1.idUM<>u2.idUM
),
Expected AS (
  SELECT idMagnitud, COUNT(*) expectedPairs
  FROM Pairs
  GROUP BY idMagnitud
),
Actual AS (
  SELECT u1.idMagnitud, COUNT(*) actualPairs
  FROM proc_unidadMedidaConversion c
  JOIN U u1 ON u1.idUM=c.idUMOrigen
  JOIN U u2 ON u2.idUM=c.idUMDestino AND u2.idMagnitud=u1.idMagnitud
  GROUP BY u1.idMagnitud
),
Missing AS (
  SELECT e.idMagnitud, (e.expectedPairs - ISNULL(a.actualPairs,0)) missingPairs
  FROM Expected e
  LEFT JOIN Actual a ON a.idMagnitud=e.idMagnitud
)
SELECT @cnt = COUNT(*) FROM Missing WHERE missingPairs<>0;

INSERT INTO @Checks VALUES ('D1','Matriz conversiones completa por magnitud', IIF(@cnt=0,'OK','FAIL'),
  IIF(@cnt=0,'OK','Faltan pares de conversión en alguna magnitud'));

-- factores correctos (tolerancia eps)
/* --- D2 (CORREGIDO): factores correctos comparando al SCALE real de la columna --- */
DECLARE @scale INT =
(
  SELECT c.scale
  FROM sys.columns c
  WHERE c.object_id = OBJECT_ID('proc_unidadMedidaConversion')
    AND c.name = 'factor'
);

;WITH U AS (
  SELECT
    u.id AS idUM,
    u.idMagnitud,
    CAST(u.factorAUnidadBaseMagnitud AS DECIMAL(38,18)) AS factorBase
  FROM cat_unidadesMedida u
  WHERE u.idEntidad=@idEntidad AND u.activo=1
),
M AS (
  SELECT
    u1.idUM AS idUMOrigen,
    u2.idUM AS idUMDestino,
    CAST(u1.factorBase / NULLIF(u2.factorBase,0) AS DECIMAL(38,18)) AS factorEsperado
  FROM U u1
  JOIN U u2
    ON u1.idMagnitud=u2.idMagnitud
   AND u1.idUM<>u2.idUM
)
SELECT @cnt = COUNT(*)
FROM proc_unidadMedidaConversion c
JOIN M
  ON M.idUMOrigen=c.idUMOrigen
 AND M.idUMDestino=c.idUMDestino
WHERE ROUND(CAST(c.factor AS DECIMAL(38,18)), @scale) <> ROUND(M.factorEsperado, @scale);

INSERT INTO @Checks VALUES ('D2','Factores de conversión correctos', IIF(@cnt=0,'OK','FAIL'),
  IIF(@cnt=0,'OK',CONCAT('Pares con factor diferente: ',@cnt)));

/* =========================
   E) TIPOS PRODUCTOS
   ========================= */
SELECT @cnt = COUNT(*) FROM cat_tiposProductosServicios WHERE idEntidad=@idEntidad AND activo=1;
INSERT INTO @Checks VALUES ('E1','Tipos de producto cargados (>=1)', IIF(@cnt>=1,'OK','WARN'),
  CONCAT('Activos: ',@cnt));

/* =========================
   RESULTADO
   ========================= */
SELECT *
FROM @Checks
ORDER BY
  CASE status WHEN 'FAIL' THEN 1 WHEN 'WARN' THEN 2 ELSE 3 END,
  codigo;

/* =========================================================
   DETALLES (solo si algo falla)
   ========================================================= */
---- Bases por magnitud:
-- SELECT m.descripcion AS magnitud, u.descripcion, u.abreviatura, u.factorAUnidadBaseMagnitud, u.esUnidadBaseMagnitud
-- FROM cat_magnitudMedida m
-- JOIN cat_unidadesMedida u ON u.idMagnitud=m.id AND u.idEntidad=@idEntidad
-- WHERE m.idEntidad=@idEntidad
-- ORDER BY m.descripcion, u.esUnidadBaseMagnitud DESC, u.abreviatura;

---- Pares de conversión faltantes (si D1 falla):
-- ;WITH U AS (
--   SELECT u.id idUM, u.idMagnitud, CAST(u.factorAUnidadBaseMagnitud AS DECIMAL(18,10)) factorBase
--   FROM cat_unidadesMedida u WHERE u.idEntidad=@idEntidad AND u.activo=1
-- ), Pairs AS (
--   SELECT u1.idMagnitud, u1.idUM idUMOrigen, u2.idUM idUMDestino
--   FROM U u1 JOIN U u2 ON u1.idMagnitud=u2.idMagnitud AND u1.idUM<>u2.idUM
-- )
-- SELECT p.*
-- FROM Pairs p
-- LEFT JOIN proc_unidadMedidaConversion c
--   ON c.idUMOrigen=p.idUMOrigen AND c.idUMDestino=p.idUMDestino
-- WHERE c.id IS NULL
-- ORDER BY p.idMagnitud, p.idUMOrigen, p.idUMDestino;






-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- valida las vonersiones de cada unidad de medida
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
GO
DECLARE @idEntidad INT = 9999;
SELECT
  mo.descripcion AS magnitud,
  uo.abreviatura AS UMOrigen,
  ud.abreviatura AS UMDestino,
  c.factor
FROM proc_unidadMedidaConversion c
JOIN cat_unidadesMedida uo ON uo.id=c.idUMOrigen AND uo.idEntidad=@idEntidad
JOIN cat_unidadesMedida ud ON ud.id=c.idUMDestino AND ud.idEntidad=@idEntidad
JOIN cat_magnitudMedida mo ON mo.id=uo.idMagnitud AND mo.idEntidad=@idEntidad
ORDER BY mo.descripcion, uo.abreviatura, ud.abreviatura;


