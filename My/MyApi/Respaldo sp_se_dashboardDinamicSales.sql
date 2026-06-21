CREATE PROCEDURE [dbo].[sp_se_dashboardDinamicSales]      
(      
  @fechaIni datetime,      
  @fechaFin datetime,      
  @idEntidad int = null,      
  @estadoTicket int = 3      
)      
AS      
BEGIN      
     SET NOCOUNT ON;      
      
    IF @fechaIni IS NULL OR @fechaFin IS NULL      
    BEGIN      
        RAISERROR('Parámetros @fechaIni y @fechaFin son obligatorios.', 16, 1);      
        RETURN;      
    END      
      
    -- Normalizamos fin a límite EXCLUSIVO (día siguiente 00:00)      
    --DECLARE @finExcl datetime2 = DATEADD(day, 1, CAST(CONVERT(date, @fechaFin) AS datetime2));      
    DECLARE @finExcl datetime2 = DATEADD(second, 1, CAST(@fechaFin AS datetime2));  
    -- 1) Determinar granularidad      
    DECLARE @dias INT = DATEDIFF(day, CAST(CONVERT(date,@fechaIni) AS datetime2), CAST(CONVERT(date,@fechaFin) AS datetime2));      
    DECLARE @grain VARCHAR(10) =      
    CASE      
      WHEN @dias <= 2   THEN 'HOUR'      
      WHEN @dias <= 31  THEN 'DAY'      
      WHEN @dias <= 180 THEN 'WEEK'      
      ELSE 'MONTH'      
    END;      
      
    -- 2) Calcular el "floor" (inicio de bucket) de fechaIni y de finExcl según granularidad      
    DECLARE @inicioBuckets datetime2 =      
        CASE @grain      
            WHEN 'HOUR'  THEN DATEADD(hour,  DATEDIFF(hour,  0, @fechaIni), 0)      
            WHEN 'DAY'   THEN DATEADD(day,   DATEDIFF(day,   0, @fechaIni), 0)      
            WHEN 'WEEK'  THEN DATEADD(week,  DATEDIFF(week,  0, @fechaIni), 0) -- semana inicia DOM      
            WHEN 'MONTH' THEN DATEADD(month, DATEDIFF(month, 0, @fechaIni), 0)      
        END;      
      
    DECLARE @finExclBuckets datetime2 =      
        CASE @grain      
            WHEN 'HOUR'  THEN DATEADD(hour,  DATEDIFF(hour,  0, @finExcl), 0)      
            WHEN 'DAY'   THEN DATEADD(day,   DATEDIFF(day,   0, @finExcl), 0)      
            WHEN 'WEEK'  THEN DATEADD(week,  DATEDIFF(week,  0, @finExcl), 0) -- semana inicia DOM      
            WHEN 'MONTH' THEN DATEADD(month, DATEDIFF(month, 0, @finExcl), 0)      
        END;      
      
    -- 3) Serie de buckets (recursive CTE). Dado tu umbral de granularidad, MAXRECURSION 0 es seguro.      
    WITH Serie AS (      
    SELECT @inicioBuckets AS bucket_start      
    UNION ALL      
    SELECT      
        CASE @grain      
            WHEN 'HOUR'  THEN DATEADD(hour,  1, bucket_start)      
            WHEN 'DAY'   THEN DATEADD(day,   1, bucket_start)      
            WHEN 'WEEK'  THEN DATEADD(week,  1, bucket_start)      
            WHEN 'MONTH' THEN DATEADD(month, 1, bucket_start)      
        END      
    FROM Serie      
    WHERE bucket_start < @finExclBuckets      
) ,      
    -- 4) Pagos por ticket (evita duplicados por join con detalles)      
    PagosPorTicket AS (      
        SELECT      
            esp.folioEntradaSalida,      
            esp.idEntidad,      
            SUM(esp.montoPago) AS venta      
        FROM proc_entradasSalidaPago AS esp      
        GROUP BY esp.folioEntradaSalida, esp.idEntidad      
    ),      
    -- 5) Tickets con su bucket      
    TicketsConFecha AS (      
        SELECT      
            esh.folioEntradaSalida,      
            esh.idEntidad,      
            esh.fechaAlta,      
            CASE @grain      
                WHEN 'HOUR'  THEN DATEADD(hour,  DATEDIFF(hour,  0, esh.fechaAlta), 0)      
                WHEN 'DAY'   THEN DATEADD(day,   DATEDIFF(day,   0, esh.fechaAlta), 0)      
                WHEN 'WEEK'  THEN DATEADD(week,  DATEDIFF(week,  0, esh.fechaAlta), 0) -- DOM      
                WHEN 'MONTH' THEN DATEADD(month, DATEDIFF(month, 0, esh.fechaAlta), 0)      
            END AS bucket_start      
        FROM proc_entradasSalidas AS esh      
        WHERE esh.idEstadoTicket = @estadoTicket      
          AND esh.fechaAlta >= @fechaIni      
          AND esh.fechaAlta <=  @finExcl     
          AND (@idEntidad IS NULL OR esh.idEntidad = @idEntidad)      
    ),      
    -- 6) Ventas agregadas por bucket      
    VentasPorBucket AS (      
        SELECT      
  t.bucket_start,      
            Cast(SUM(p.venta) AS decimal(10,2))  AS ventasNetas      
        FROM TicketsConFecha AS t      
        JOIN PagosPorTicket AS p      
          ON p.folioEntradaSalida = t.folioEntradaSalida      
         AND p.idEntidad          = t.idEntidad      
        GROUP BY t.bucket_start      
    )      
    -- 7) Junta la serie con las ventas (rellena con 0)      
    SELECT      
        s.bucket_start,      
        Cast(COALESCE(v.ventasNetas, 0) AS decimal(10,2))AS ventasNetas      
    FROM Serie AS s      
    LEFT JOIN VentasPorBucket AS v      
      ON v.bucket_start = s.bucket_start      
    WHERE s.bucket_start < @finExclBuckets      
    ORDER BY s.bucket_start      
    OPTION (MAXRECURSION 0);      
END   
  