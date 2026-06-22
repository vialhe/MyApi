exec sp_se_dashboard_ventas '20260622','20260622 23:59:59',10007
Go

ALTER PROCEDURE sp_se_dashboard
 @fechaIni datetime ,  
 @fechaFin datetime ,  
 @idEntidad int,  
 @idEstadoTicket int = 3  ,
 @idSucursal int = null
AS
Begin
	exec [sp_se_dashboard_ventas] @fechaIni, @fechaFin,@idEntidad,@idEstadoTicket,@idSucursal 
	exec [sp_se_dashboard_productos] @fechaIni, @fechaFin,@idEntidad,@idSucursal 
End
Go
ALTER PROCEDURE [dbo].[sp_se_dashboard_ventas]
(
    --DECLARE
    @fechaIni       DATETIME,
    @fechaFin       DATETIME,
    @idEntidad      INT,
    @idEstadoTicket INT = 3,
    @idSucursal     INT = NULL
)
AS
BEGIN
    
    SET NOCOUNT ON;
    --SELECT @fechaIni='20260622', @fechaFin='20260622 23:59:59', @idEntidad = 10007
    DECLARE @total             DECIMAL(18,2) = 0;
    DECLARE @totalPOS          DECIMAL(18,2) = 0;
    DECLARE @totalAgenda       DECIMAL(18,2) = 0;

    DECLARE @totalPagos        DECIMAL(18,2) = 0;
    DECLARE @totalPagosPOS     DECIMAL(18,2) = 0;
    DECLARE @totalPagosAgenda  DECIMAL(18,2) = 0;

    DECLARE @totalNeto         DECIMAL(18,2) = 0;
    DECLARE @costoPOS          DECIMAL(18,2) = 0;
    DECLARE @costoAgenda       DECIMAL(18,2) = 0;

    DECLARE @cantidad          INT = 0;
    DECLARE @cantidadPOS       INT = 0;
    DECLARE @cantidadAgenda    INT = 0;

    DECLARE @estatusPagoAgenda INT;

    SELECT 
        @estatusPagoAgenda = idEstatusPagoAgenda
    FROM cat_estatusPagoAgenda
    WHERE idEntidad = @idEntidad
      AND clave = 'APLICADO';

    DECLARE @fechaIniFiltro DATETIME = CAST(CAST(@fechaIni AS DATE) AS DATETIME);
    DECLARE @fechaFinFiltro DATETIME = DATEADD(DAY, 1, CAST(CAST(@fechaFin AS DATE) AS DATETIME));

    DECLARE @tbl TABLE
    (
        orden    TINYINT,
        nombre   VARCHAR(150),
        Total    DECIMAL(18,2),
        Cantidad INT,
        Tipo     VARCHAR(20)
    );

    ------------------------------------------------------------
    -- TOTAL POS
    ------------------------------------------------------------
    SELECT
        @totalPOS = ISNULL(SUM(CAST(esh.montoTotalTicket AS DECIMAL(18,2))), 0)
    FROM proc_entradasSalidas esh
    WHERE esh.idEstadoTicket = @idEstadoTicket
      AND esh.fechaAlta >= @fechaIniFiltro
      AND esh.fechaAlta <  @fechaFinFiltro
      AND esh.idEntidad = @idEntidad
      AND (@idSucursal IS NULL OR esh.idSucursal = @idSucursal)

    ------------------------------------------------------------
    -- TOTAL AGENDA
    -- Solo pagos aplicados y activos.
    ------------------------------------------------------------
    SELECT
        @totalAgenda = ISNULL(SUM(CAST(ap.montoTotal AS DECIMAL(18,2))), 0)
    FROM proc_agendaPago ap
    WHERE ap.idEstatusPagoAgenda = @estatusPagoAgenda
      AND ap.activo = 1
      AND ap.fechaPago >= @fechaIniFiltro
      AND ap.fechaPago <  @fechaFinFiltro
      AND ap.idEntidad = @idEntidad
      AND (@idSucursal IS NULL OR ap.idSucursal = @idSucursal)

    SET @total = ISNULL(@totalPOS, 0) + ISNULL(@totalAgenda, 0);

    ------------------------------------------------------------
    -- TOTAL PAGOS POS
    ------------------------------------------------------------
    SELECT
        @totalPagosPOS = ISNULL(SUM(CAST(esp.montoPago AS DECIMAL(18,2))), 0)
    FROM proc_entradasSalidas esh
    INNER JOIN proc_entradasSalidaPago esp
        ON  esh.folioEntradaSalida = esp.folioEntradaSalida
        AND esh.idEntidad = esp.idEntidad
    WHERE esh.idEstadoTicket = @idEstadoTicket
      AND esh.fechaAlta >= @fechaIniFiltro
      AND esh.fechaAlta <  @fechaFinFiltro
      AND esh.idEntidad = @idEntidad
      AND (@idSucursal IS NULL OR esh.idSucursal = @idSucursal)

    ------------------------------------------------------------
    -- TOTAL PAGOS AGENDA
    -- Para pagos se usa el detalle porque ahí vive idTipoPago.
    ------------------------------------------------------------
    SELECT
        @totalPagosAgenda = ISNULL(SUM(CAST(apd.montoPago AS DECIMAL(18,2))), 0)
    FROM proc_agendaPago ap
    INNER JOIN proc_agendaPagoDetalle apd
        ON  apd.folioAgendaPago = ap.folioAgendaPago
        AND apd.idEntidad = ap.idEntidad
    WHERE ap.idEstatusPagoAgenda = @estatusPagoAgenda
      AND ap.activo = 1
      AND apd.activo = 1
      AND ap.fechaPago >= @fechaIniFiltro
      AND ap.fechaPago <  @fechaFinFiltro
      AND ap.idEntidad = @idEntidad
      AND (@idSucursal IS NULL OR ap.idSucursal = @idSucursal)

    SET @totalPagos = ISNULL(@totalPagosPOS, 0) + ISNULL(@totalPagosAgenda, 0);

    ------------------------------------------------------------
    -- RESULT SET 1:
    -- Row 1: Total ingresos
    -- Row 2: Total pagos
    ------------------------------------------------------------
    SELECT CAST(ISNULL(@total, 0) AS DECIMAL(18,2)) AS Total
    UNION ALL
    SELECT CAST(ISNULL(@totalPagos, 0) AS DECIMAL(18,2)) AS Total;

    ------------------------------------------------------------
    -- COSTO POS
    ------------------------------------------------------------
    SELECT
        @costoPOS = CAST(
            ISNULL(
                SUM(
                    CASE 
                        WHEN ISNULL(esd.costo, 0) > 0 
                            THEN CAST(esd.costo AS DECIMAL(18,2))
                        ELSE ISNULL(prec.Costo, 0)
                    END
                ),
                0
            ) AS DECIMAL(18,2)
        )
    FROM proc_entradasSalidas esh
    INNER JOIN proc_entradasSalidasDetalles esd
        ON  esh.folioEntradaSalida = esd.folioEntradaSalida
        AND esh.idEntidad = esd.idEntidad
    OUTER APPLY
    (
        SELECT TOP (1)
            CAST(p.Costo AS DECIMAL(18,2)) AS Costo
        FROM cat_precios p
        WHERE p.idProductoServicio = esd.idProductoServicio
          AND p.idEntidad = esd.idEntidad
    ) prec
    WHERE esh.idEstadoTicket = @idEstadoTicket
      AND esh.fechaAlta >= @fechaIniFiltro
      AND esh.fechaAlta <  @fechaFinFiltro
      AND esh.idEntidad = @idEntidad
      AND (@idSucursal IS NULL OR esh.idSucursal = @idSucursal)

    ------------------------------------------------------------
    -- COSTO AGENDA
    -- Costo proporcional al monto pagado.
    ------------------------------------------------------------
    ;WITH PagosAgendaCosto AS
    (
        SELECT
            ap.folioAgendaPago,
            ap.folioAgenda,
            ap.idEntidad,
            CAST(ap.montoTotal AS DECIMAL(18,2)) AS montoPagado
        FROM proc_agendaPago ap
        WHERE ap.idEstatusPagoAgenda = @estatusPagoAgenda
          AND ap.activo = 1
          AND ap.fechaPago >= @fechaIniFiltro
          AND ap.fechaPago <  @fechaFinFiltro
          AND ap.idEntidad = @idEntidad
          AND (@idSucursal IS NULL OR ap.idSucursal = @idSucursal)
    ),
    CostoPorAgenda AS
    (
        SELECT
            ags.folioAgenda,
            ags.idEntidad,
            SUM(CAST(ISNULL(ags.precioFinal, 0) AS DECIMAL(18,2))) AS precioTotalAgenda,
            SUM(CAST(ISNULL(prec.Costo, 0) AS DECIMAL(18,2))) AS costoTotalAgenda
        FROM proc_agendaDetalleServicio ags
        OUTER APPLY
        (
            SELECT TOP (1)
                CAST(p.Costo AS DECIMAL(18,2)) AS Costo
            FROM cat_precios p
            WHERE p.idProductoServicio = ags.idProductoServicio
              AND p.idEntidad = ags.idEntidad
        ) prec
        WHERE ags.idEntidad = @idEntidad
        AND (@idSucursal IS NULL OR ags.idSucursal = @idSucursal)
        GROUP BY
            ags.folioAgenda,
            ags.idEntidad
    )
    SELECT
        @costoAgenda = CAST(
            ISNULL(
                SUM(
                    CASE 
                        WHEN ISNULL(cpa.precioTotalAgenda, 0) > 0
                            THEN pag.montoPagado * cpa.costoTotalAgenda / cpa.precioTotalAgenda
                        ELSE 0
                    END
                ),
                0
            ) AS DECIMAL(18,2)
        )
    FROM PagosAgendaCosto pag
    INNER JOIN CostoPorAgenda cpa
        ON  cpa.folioAgenda = pag.folioAgenda
        AND cpa.idEntidad = pag.idEntidad;

    SET @totalNeto = ISNULL(@costoPOS, 0) + ISNULL(@costoAgenda, 0);

    ------------------------------------------------------------
    -- RESULT SET 2: TOTAL NETO / COSTO
    ------------------------------------------------------------
    SELECT
        CAST(ISNULL(@totalNeto, 0) AS DECIMAL(18,2)) AS TotalNeto;

    ------------------------------------------------------------
    -- CANTIDAD POS
    ------------------------------------------------------------
    SELECT
        @cantidadPOS = COUNT(esh.folioEntradaSalida)
    FROM proc_entradasSalidas esh
    WHERE esh.idEstadoTicket = @idEstadoTicket
      AND esh.fechaAlta >= @fechaIniFiltro
      AND esh.fechaAlta <  @fechaFinFiltro
      AND esh.idEntidad = @idEntidad
      AND (@idSucursal IS NULL OR esh.idSucursal = @idSucursal)

    ------------------------------------------------------------
    -- CANTIDAD AGENDA
    -- Se cuenta cada pago aplicado como operación de ingreso.
    ------------------------------------------------------------
    SELECT
        @cantidadAgenda = COUNT(ap.folioAgendaPago)
    FROM proc_agendaPago ap
    WHERE ap.idEstatusPagoAgenda = @estatusPagoAgenda
      AND ap.activo = 1
      AND ap.fechaPago >= @fechaIniFiltro
      AND ap.fechaPago <  @fechaFinFiltro
      AND ap.idEntidad = @idEntidad
      AND (@idSucursal IS NULL OR ap.idSucursal = @idSucursal)

    SET @cantidad = ISNULL(@cantidadPOS, 0) + ISNULL(@cantidadAgenda, 0);

    ------------------------------------------------------------
    -- RESULT SET 3: PROMEDIO
    ------------------------------------------------------------
    SELECT
        CAST(ISNULL(@total / NULLIF(@cantidad, 0), 0) AS DECIMAL(18,2)) AS Prom;

    ------------------------------------------------------------
    -- RESULT SET 4: CANTIDAD
    ------------------------------------------------------------
    SELECT
        ISNULL(@cantidad, 0) AS Cantidad;

    ------------------------------------------------------------
    -- RESULT SET 5: TOTAL POR TIPO DE PAGO
    ------------------------------------------------------------
    ;WITH PagosPorTipo AS
    (
        SELECT
            esp.idTipoPago,
            SUM(CAST(esp.montoPago AS DECIMAL(18,2))) AS Total
        FROM proc_entradasSalidas esh
        INNER JOIN proc_entradasSalidaPago esp
            ON  esh.folioEntradaSalida = esp.folioEntradaSalida
            AND esh.idEntidad = esp.idEntidad
        WHERE esh.idEstadoTicket = @idEstadoTicket
          AND esh.fechaAlta >= @fechaIniFiltro
          AND esh.fechaAlta <  @fechaFinFiltro
          AND esh.idEntidad = @idEntidad
          AND (@idSucursal IS NULL OR esh.idSucursal = @idSucursal)
        GROUP BY
            esp.idTipoPago

        UNION ALL

        SELECT
            apd.idTipoPago,
            SUM(CAST(apd.montoPago AS DECIMAL(18,2))) AS Total
        FROM proc_agendaPago ap
        INNER JOIN proc_agendaPagoDetalle apd
            ON  apd.folioAgendaPago = ap.folioAgendaPago
            AND apd.idEntidad = ap.idEntidad
        WHERE ap.idEstatusPagoAgenda = @estatusPagoAgenda
          AND ap.activo = 1
          AND apd.activo = 1
          AND ap.fechaPago >= @fechaIniFiltro
          AND ap.fechaPago <  @fechaFinFiltro
          AND ap.idEntidad = @idEntidad
          AND (@idSucursal IS NULL OR ap.idSucursal = @idSucursal)
        GROUP BY
            apd.idTipoPago
    )
    SELECT
        CAST(SUM(ppt.Total) AS DECIMAL(18,2)) AS Total,
        b.descripcion
    FROM PagosPorTipo ppt
    INNER JOIN cat_tiposPago b
        ON b.id = ppt.idTipoPago
    GROUP BY
        b.descripcion;

    ------------------------------------------------------------
    -- RESULT SET 6: DASHBOARD DINÁMICO RANGO SOLICITADO
    -- Este SP ya debe sumar POS + AgendaPago.
    ------------------------------------------------------------
    EXEC dbo.sp_se_dashboardDinamicSales 
        @fechaIni, 
        @fechaFin, 
        @idEntidad,
        @idEstadoTicket,
        @idSucursal

    ------------------------------------------------------------
    -- RESULT SET 7: DASHBOARD DINÁMICO HOY
    -- Se manda hoy-hoy para evitar tomar dos días.
    ------------------------------------------------------------
    DECLARE @hoy DATE = CAST(dbo.fn_GetDateMX() AS DATE);
    DECLARE @inicioHoy DATETIME = CAST(@hoy AS DATETIME);

    EXEC dbo.sp_se_dashboardDinamicSales 
        @inicioHoy,
        @inicioHoy,
        @idEntidad,
        @idEstadoTicket,
        @idSucursal

    ------------------------------------------------------------
    -- TOTAL POR CAJERO / VENTAS
    ------------------------------------------------------------
    INSERT INTO @tbl
    (
        orden,
        nombre,
        Total,
        Cantidad,
        Tipo
    )
    SELECT
        1 AS orden,
        LTRIM(RTRIM(
            ISNULL(c.nombre, '') + ' ' +
            ISNULL(c.apellidoPaterno, '') + ' ' +
            ISNULL(c.apellidoMaterno, '')
        )) AS nombre,
        SUM(CAST(esh.montoTotalTicket AS DECIMAL(18,2))) AS Total,
        COUNT(*) AS Cantidad,
        'Venta' AS Tipo
    FROM proc_entradasSalidas esh
    INNER JOIN sys_usuarios b
        ON b.id = esh.idUsuarioAlta
    INNER JOIN cat_personas c
        ON c.id = b.idPersona
    WHERE esh.idEstadoTicket = @idEstadoTicket
      AND esh.fechaAlta >= @fechaIniFiltro
      AND esh.fechaAlta <  @fechaFinFiltro
      AND esh.idEntidad = @idEntidad
      AND (@idSucursal IS NULL OR esh.idSucursal = @idSucursal)
    GROUP BY
        LTRIM(RTRIM(
            ISNULL(c.nombre, '') + ' ' +
            ISNULL(c.apellidoPaterno, '') + ' ' +
            ISNULL(c.apellidoMaterno, '')
        ));

    ------------------------------------------------------------
    -- TOTAL POR EMPLEADO / AGENDA
    -- Pago real distribuido proporcionalmente por servicio.
    ------------------------------------------------------------
    ;WITH PagosPorAgenda AS
    (
        SELECT
            ap.folioAgenda,
            ap.idEntidad,
            SUM(CAST(ap.montoTotal AS DECIMAL(18,2))) AS totalPagado
        FROM proc_agendaPago ap
        WHERE ap.idEstatusPagoAgenda = @estatusPagoAgenda
          AND ap.activo = 1
          AND ap.fechaPago >= @fechaIniFiltro
          AND ap.fechaPago <  @fechaFinFiltro
          AND ap.idEntidad = @idEntidad
          AND (@idSucursal IS NULL OR ap.idSucursal = @idSucursal)
        GROUP BY
            ap.folioAgenda,
            ap.idEntidad
    ),
    PesoTotalPorAgenda AS
    (
        SELECT
            ags.folioAgenda,
            ags.idEntidad,
            SUM(CAST(ISNULL(ags.precioFinal, 0) AS DECIMAL(18,2))) AS pesoTotal
        FROM proc_agendaDetalleServicio ags
        WHERE ags.idEntidad = @idEntidad
        AND (@idSucursal IS NULL OR ags.idSucursal = @idSucursal)
        GROUP BY
            ags.folioAgenda,
            ags.idEntidad
    )
    INSERT INTO @tbl
    (
        orden,
        nombre,
        Total,
        Cantidad,
        Tipo
    )
    SELECT
        2 AS orden,
        LTRIM(RTRIM(
            ISNULL(c.nombre, '') + ' ' +
            ISNULL(c.apellidoPaterno, '') + ' ' +
            ISNULL(c.apellidoMaterno, '')
        )) AS nombre,
        CAST(
            ISNULL(
                SUM(
                    pag.totalPagado
                    * (
                        CAST(ISNULL(ags.precioFinal, 0) AS DECIMAL(18,2))
                        * CAST(ISNULL(agse.porcentajeParticipacion, 100) AS DECIMAL(18,2)) / 100.0
                    )
                    / NULLIF(ptpa.pesoTotal, 0)
                ),
                0
            ) AS DECIMAL(18,2)
        ) AS Total,
        COUNT(DISTINCT ags.folioAgenda) AS Cantidad,
        'Agenda' AS Tipo
    FROM PagosPorAgenda pag
    INNER JOIN proc_agendaDetalleServicio ags
        ON  ags.folioAgenda = pag.folioAgenda
        AND ags.idEntidad = pag.idEntidad
    INNER JOIN proc_agendaDetalleServicioEmpleado agse
        ON  agse.folioAgendaDetalleServicio = ags.folioAgendaDetalleServicio
        AND agse.idEntidad = ags.idEntidad
    INNER JOIN PesoTotalPorAgenda ptpa
        ON  ptpa.folioAgenda = pag.folioAgenda
        AND ptpa.idEntidad = pag.idEntidad
    INNER JOIN cat_personas c
        ON c.id = agse.folioEmpleado
    GROUP BY
        LTRIM(RTRIM(
            ISNULL(c.nombre, '') + ' ' +
            ISNULL(c.apellidoPaterno, '') + ' ' +
            ISNULL(c.apellidoMaterno, '')
        ));

    ------------------------------------------------------------
    -- RESULT SET 8: RESULTADO FINAL UNIFICADO
    ------------------------------------------------------------
    SELECT
        nombre,
        Total,
        Cantidad,
        Tipo
    FROM @tbl
    ORDER BY
        orden,
        Total DESC,
        nombre;

END;
GO

ALTER PROCEDURE [dbo].[sp_se_dashboardDinamicSales]
(
    @fechaIni     DATETIME,
    @fechaFin     DATETIME,
    @idEntidad    INT = NULL,
    @estadoTicket INT = 3,
    @idSucursal   INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @fechaIni IS NULL OR @fechaFin IS NULL
    BEGIN
        RAISERROR('Parámetros @fechaIni y @fechaFin son obligatorios.', 16, 1);
        RETURN;
    END;

    /*
        Normalización de fechas:
        - @fechaIniFiltro: inicio del día
        - @fechaFinFiltro: día siguiente 00:00 como límite exclusivo

        Ejemplo:
            @fechaIni = '20260618'
            @fechaFin = '20260618'

        Filtro real:
            >= 2026-06-18 00:00:00
            <  2026-06-19 00:00:00
    */
    DECLARE @fechaIniFiltro DATETIME2 = CAST(CONVERT(DATE, @fechaIni) AS DATETIME2);
    DECLARE @fechaFinFiltro DATETIME2 = DATEADD(DAY, 1, CAST(CONVERT(DATE, @fechaFin) AS DATETIME2));

    ------------------------------------------------------------
    -- 1) Determinar granularidad
    ------------------------------------------------------------
    DECLARE @dias INT = DATEDIFF(DAY, @fechaIniFiltro, DATEADD(DAY, -1, @fechaFinFiltro));

    DECLARE @grain VARCHAR(10) =
    CASE
        WHEN @dias <= 2   THEN 'HOUR'
        WHEN @dias <= 31  THEN 'DAY'
        WHEN @dias <= 180 THEN 'WEEK'
        ELSE 'MONTH'
    END;

    ------------------------------------------------------------
    -- 2) Calcular inicio y fin de buckets
    ------------------------------------------------------------
    DECLARE @inicioBuckets DATETIME2 =
        CASE @grain
            WHEN 'HOUR'  THEN DATEADD(HOUR,  DATEDIFF(HOUR,  0, @fechaIniFiltro), 0)
            WHEN 'DAY'   THEN DATEADD(DAY,   DATEDIFF(DAY,   0, @fechaIniFiltro), 0)
            WHEN 'WEEK'  THEN DATEADD(WEEK,  DATEDIFF(WEEK,  0, @fechaIniFiltro), 0)
            WHEN 'MONTH' THEN DATEADD(MONTH, DATEDIFF(MONTH, 0, @fechaIniFiltro), 0)
        END;

    DECLARE @finExclBuckets DATETIME2 =
        CASE @grain
            WHEN 'HOUR'  THEN DATEADD(HOUR,  DATEDIFF(HOUR,  0, @fechaFinFiltro), 0)
            WHEN 'DAY'   THEN DATEADD(DAY,   DATEDIFF(DAY,   0, @fechaFinFiltro), 0)
            WHEN 'WEEK'  THEN DATEADD(WEEK,  DATEDIFF(WEEK,  0, @fechaFinFiltro), 0)
            WHEN 'MONTH' THEN DATEADD(MONTH, DATEDIFF(MONTH, 0, @fechaFinFiltro), 0)
        END;

    ------------------------------------------------------------
    -- 3) Serie dinámica + ingresos unificados
    ------------------------------------------------------------
    ;WITH Serie AS
    (
        SELECT 
            @inicioBuckets AS bucket_start

        UNION ALL

        SELECT
            CASE @grain
                WHEN 'HOUR'  THEN DATEADD(HOUR,  1, bucket_start)
                WHEN 'DAY'   THEN DATEADD(DAY,   1, bucket_start)
                WHEN 'WEEK'  THEN DATEADD(WEEK,  1, bucket_start)
                WHEN 'MONTH' THEN DATEADD(MONTH, 1, bucket_start)
            END
        FROM Serie
        WHERE bucket_start < @finExclBuckets
    ),

    ------------------------------------------------------------
    -- 4) Pagos por ticket POS
    -- Evita duplicados si después se cruza contra otras tablas.
    ------------------------------------------------------------
    PagosPorTicket AS
    (
        SELECT
            esp.folioEntradaSalida,
            esp.idEntidad,
            SUM(CAST(esp.montoPago AS DECIMAL(18,2))) AS venta
        FROM proc_entradasSalidaPago AS esp
        GROUP BY
            esp.folioEntradaSalida,
            esp.idEntidad
    ),

    ------------------------------------------------------------
    -- 5) Ingresos POS
    ------------------------------------------------------------
    IngresosPOS AS
    (
        SELECT
            esh.fechaAlta AS fechaIngreso,
            esh.idEntidad,
            CAST(p.venta AS DECIMAL(18,2)) AS monto
        FROM proc_entradasSalidas AS esh
INNER JOIN PagosPorTicket AS p
            ON  p.folioEntradaSalida = esh.folioEntradaSalida
            AND p.idEntidad = esh.idEntidad
        WHERE esh.idEstadoTicket = @estadoTicket
          AND esh.fechaAlta >= @fechaIniFiltro
          AND esh.fechaAlta <  @fechaFinFiltro
          AND (@idEntidad IS NULL OR esh.idEntidad = @idEntidad)
          AND (@idSucursal IS NULL OR esh.idSucursal = @idSucursal)
    ),

    ------------------------------------------------------------
    -- 6) Ingresos Agenda
    -- Mientras agendaPago NO genere ticket, se suma como ingreso independiente.
    -- Solo se consideran pagos con estatus APLICADO.
    ------------------------------------------------------------
    IngresosAgenda AS
    (
        SELECT
            ap.fechaPago AS fechaIngreso,
            ap.idEntidad,
            CAST(ap.montoTotal AS DECIMAL(18,2)) AS monto
        FROM proc_agendaPago AS ap
        INNER JOIN cat_estatusPagoAgenda AS cepa
            ON  cepa.idEstatusPagoAgenda = ap.idEstatusPagoAgenda
            AND cepa.idEntidad = ap.idEntidad
            AND cepa.clave = 'APLICADO'
        WHERE ap.fechaPago >= @fechaIniFiltro
          AND ap.fechaPago <  @fechaFinFiltro
          AND (@idEntidad IS NULL OR ap.idEntidad = @idEntidad)
          AND (@idSucursal IS NULL OR ap.idSucursal = @idSucursal)
    ),

    ------------------------------------------------------------
    -- 7) Fuente unificada de ingresos
    ------------------------------------------------------------
    IngresosBase AS
    (
        SELECT
            fechaIngreso,
            idEntidad,
            monto
        FROM IngresosPOS

        UNION ALL

        SELECT
            fechaIngreso,
            idEntidad,
            monto
        FROM IngresosAgenda
    ),

    ------------------------------------------------------------
    -- 8) Ingresos con bucket dinámico
    ------------------------------------------------------------
    IngresosConBucket AS
    (
        SELECT
            CASE @grain
                WHEN 'HOUR'  THEN DATEADD(HOUR,  DATEDIFF(HOUR,  0, fechaIngreso), 0)
                WHEN 'DAY'   THEN DATEADD(DAY,   DATEDIFF(DAY,   0, fechaIngreso), 0)
                WHEN 'WEEK'  THEN DATEADD(WEEK,  DATEDIFF(WEEK,  0, fechaIngreso), 0)
                WHEN 'MONTH' THEN DATEADD(MONTH, DATEDIFF(MONTH, 0, fechaIngreso), 0)
            END AS bucket_start,
            monto
        FROM IngresosBase
    ),

    ------------------------------------------------------------
    -- 9) Ingresos agregados por bucket
    ------------------------------------------------------------
    IngresosPorBucket AS
    (
        SELECT
            bucket_start,
            CAST(SUM(monto) AS DECIMAL(10,2)) AS ventasNetas
        FROM IngresosConBucket
        GROUP BY
            bucket_start
    )

    ------------------------------------------------------------
    -- 10) Resultado final
    ------------------------------------------------------------
    SELECT
        s.bucket_start,
        CAST(COALESCE(i.ventasNetas, 0) AS DECIMAL(10,2)) AS ventasNetas
    FROM Serie AS s
    LEFT JOIN IngresosPorBucket AS i
        ON i.bucket_start = s.bucket_start
    WHERE s.bucket_start < @finExclBuckets
    ORDER BY
        s.bucket_start
    OPTION (MAXRECURSION 0);

END;
Go

ALTER Proc [dbo].[sp_se_corteCaja]
	@idUsuarioIniciaCorte int,
	@idEntidad int,
    @idSucursal int = null
As
Begin
		
		SELECT 
			a.folioCorteTienda,
			b.folioCorteCaja,
			b.idUsuarioIniciaCorte,
			b.saldoInicial,
			b.fechaInicio,
			b.fechaFin
		From
			proc_corteTienda a
			JOIN proc_corteCaja b
				On a.folioCorteTienda = b.folioCorteTienda
				And a.idEntidad =  b.idEntidad
		Where
			b.fechaFin is null
			and b.idUsuarioIniciaCorte = @idUsuarioIniciaCorte
			and b.idEntidad =  @idEntidad
            AND (@idSucursal IS NULL OR b.idSucursal = @idSucursal)
            AND (@idSucursal IS NULL OR a.idSucursal = @idSucursal)

End
Go

ALTER PROC [dbo].[sp_se_reporteDeVentas]  
    @fechaInicio datetime,  
    @fechaFin datetime,  
    @idEntidad int ,
    @idUsuario int = null,
    @idSucursal int = null
  
--Select @fechaInicio =  '20250113', @fechaFin = '20250813', @idEntidad = 9999  
AS  
BEGIN  
    SET LANGUAGE Español;  
    --RETORNA H  
    Select  
        esd.folioEntradaSalida [Folio],   
        es.montoTotalTicket [PagoTotal],
        es.pagoTotal as [SuPago],
        es.suCambio as [SuCambio],
        estados.descripcion [Estatus],  
        FORMAT(es.fechaAlta,'dd-MM-yyyy HH:mm') As [FechaRegistro],  
        pers.nombre +' '+ pers.apellidoPaterno as Atiende  
    From  
        proc_entradasSalidas es   
        Join proc_entradasSalidasDetalles esd  
            On es.folioEntradaSalida = esd.folioEntradaSalida And  
            es.idEntidad = esd.idEntidad  
        Join proc_entradasSalidaPago esp  
            On es.folioEntradaSalida = esp.folioEntradaSalida And  
            es.idEntidad = esp.idEntidad  
        Join proc_movimientosInventarios mi  
            On es.folioMovimientoInventario = mi.folioMovimientoInventario  
            and es.idEntidad = mi.idEntidad  
        Join proc_movimientosInventariosDetalles mid  
            On mi.folioMovimientoInventario = mid.folioMovimientoInventario  
            And mi.idEntidad = mid.idEntidad  
        Left Join cat_tiposEntradasSalidas tes  
            On es.idTipoEntradaSalida = tes.id  
        Left Join cat_productosServicios ps  
            On esd.idProductoServicio = ps.id  
        Left Join cat_unidadesMedida um  
            On esd.idUnidadMedida = um.id  
        Left Join cat_tiposPago tp  
            On esp.idTipoPago = tp.id  
        Left Join cat_tiposMovmientosInventario tmi  
            On mi.idTipoMovimientoInventario = tmi.id  
        LEFT Join cat_estadosEntradaSalida estados  
            On estados.id = ISNULL( es.idEstadoTicket,0)  
        LEFT JOIN sys_usuarios us   
            On us.id = es.idUsuarioAlta  
        LEFT Join cat_personas pers  
            On pers.id = us.idPersona  
    Where  
        es.fechaAlta between @fechaInicio and @fechaFin and 
        es.idEntidad = @idEntidad  and
        (@idUsuario is null or @idUsuario = es.idUsuarioAlta)
        AND (@idSucursal is null or es.idSucursal = @idSucursal)
    Group by  
        esd.folioEntradaSalida,   
        es.fechaAlta,   
        es.montoTotalTicket,  
        es.pagoTotal,
        es.suCambio,
        es.comentarios,  
        estados.descripcion,  
        pers.nombre,  
        pers.apellidoPaterno  
    Order by  
        es.fechaAlta desc, esd.folioEntradaSalida  
  
    --RETORNA DETALLES  
    Select  
        esd.folioEntradaSalida [Folio],   
        ISNULL(esd.cantidad,0)* ISNULL(esd.precioFinal,0) [PagoTotal],  
        estados.descripcion [Estatus],  
        Format(es.fechaAlta,'dd-MM-yyyy HH:mm') As [FechaRegistro],  
        ps.id [SKU],  
        Case When ISNULL(ps.esComodin,0) = 0 Then ps.descripcion Else esd.comentarios End [NombreProducto],  
        --ps.descripcion [NombreProducto],  
        esd.cantidad [Cantidad],  
        esd.precioFinal [PrecioVenta],  
        um.descripcion [UnidadMedida],  
        --um.id [IdUnidadMedida],  
        es.comentarios [Comentarios],  
        pers.nombre +' '+ pers.apellidoPaterno as Atiende,  
        esd.idUnidadMedida as idUnidadMedida,  
        esd.serie,  
        esd.lote,  
        Format(esd.fechaVencimiento,'dd-MM-yyyy HH:mm') as fechaVencimiento,  
        esd.numeracion  
    From  
        proc_entradasSalidas es   
        Join proc_entradasSalidasDetalles esd  
            On es.folioEntradaSalida = esd.folioEntradaSalida And  
            es.idEntidad = esd.idEntidad  
        Left Join proc_entradasSalidaPago esp  
            On es.folioEntradaSalida = esp.folioEntradaSalida And  
            es.idEntidad = esp.idEntidad  
        Join proc_movimientosInventarios mi  
            On es.folioMovimientoInventario = mi.folioMovimientoInventario  
            and es.idEntidad = mi.idEntidad  
        Join proc_movimientosInventariosDetalles mid  
            On mi.folioMovimientoInventario = mid.folioMovimientoInventario  
            And mi.idEntidad = mid.idEntidad  
        Left Join cat_tiposEntradasSalidas tes  
            On es.idTipoEntradaSalida = tes.id  
        Left Join cat_productosServicios ps  
            On esd.idProductoServicio = ps.id  
        Left Join cat_unidadesMedida um  
            On esd.idUnidadMedida = um.id  
        Left Join cat_tiposPago tp  
            On esp.idTipoPago = tp.id  
        Left Join cat_tiposMovmientosInventario tmi  
            On mi.idTipoMovimientoInventario = tmi.id  
        LEFT Join cat_estadosEntradaSalida estados  
            On estados.id = ISNULL( es.idEstadoTicket,0)  
        LEFT JOIN sys_usuarios us   
            On us.id = es.idUsuarioAlta  
        LEFT Join cat_personas pers  
            On pers.id = us.idPersona  
    Where  
        es.fechaAlta between @fechaInicio and @fechaFin and 
        es.idEntidad = @idEntidad  and
        (@idUsuario is null or @idUsuario = es.idUsuarioAlta)
        AND (@idSucursal is null or es.idSucursal = @idSucursal)
    Group by  
        esd.folioEntradaSalida,   
        Format(es.fechaAlta,'dd-MM-yyyy HH:mm'),   
        tmi.descripcion,  
        tes.descripcion,  
        ps.id,  
    --ps.descripcion,
    CASE 
        WHEN ISNULL(ps.esComodin, 0) = 0 
            THEN ps.descripcion 
        ELSE esd.comentarios 
    END,
 esd.cantidad,  
 esd.precioFinal,  
 um.descripcion,  
 um.id,  
 es.montoTotalTicket,  
 es.comentarios,  
 estados.descripcion,  
 pers.nombre,  
 pers.apellidoPaterno,  
 esd.idUnidadMedida,  
 esd.serie,  
 esd.lote,  
 esd.fechaVencimiento,  
 esd.numeracion  
Order by  
 esd.folioEntradaSalida  
  
  
--RETORNA PAGO  
 Select  
 esd.folioEntradaSalida [Folio],   
 es.montoTotalTicket [PagoTotal],  
 Format(es.fechaAlta,'dd-MM-yyyy HH:mm') [FechaRegistro],  
 esp.montoPago ,  
 esp.numeroAutorizacion as [referencia],  
 tp.descripcion [FormaDePago],  
 es.comentarios [Comentarios],  
 pers.nombre +' '+ pers.apellidoPaterno as Atiende  
From  
 proc_entradasSalidas es   
 Join proc_entradasSalidasDetalles esd  
  On es.folioEntradaSalida = esd.folioEntradaSalida And  
  es.idEntidad = esd.idEntidad  
 Join proc_entradasSalidaPago esp  
  On es.folioEntradaSalida = esp.folioEntradaSalida And  
  es.idEntidad = esp.idEntidad  
 Join proc_movimientosInventarios mi  
  On es.folioMovimientoInventario = mi.folioMovimientoInventario  
  and es.idEntidad = mi.idEntidad  
 Join proc_movimientosInventariosDetalles mid  
  On mi.folioMovimientoInventario = mid.folioMovimientoInventario  
  And mi.idEntidad = mid.idEntidad  
 Left Join cat_tiposEntradasSalidas tes  
  On es.idTipoEntradaSalida = tes.id  
 Left Join cat_productosServicios ps  
  On esd.idProductoServicio = ps.id  
 Left Join cat_unidadesMedida um  
  On esd.idUnidadMedida = um.id  
 Left Join cat_tiposPago tp  
  On esp.idTipoPago = tp.id  
 Left Join cat_tiposMovmientosInventario tmi  
  On mi.idTipoMovimientoInventario = tmi.id  
 LEFT Join cat_estadosEntradaSalida estados  
  On estados.id = ISNULL( es.idEstadoTicket,0)  
 LEFT JOIN sys_usuarios us   
  On us.id = es.idUsuarioAlta  
 LEFT Join cat_personas pers  
  On pers.id = us.idPersona  
Where  
 es.fechaAlta between @fechaInicio and @fechaFin and 
 es.idEntidad = @idEntidad  and
 (@idUsuario is null or @idUsuario = es.idUsuarioAlta)
 AND (@idSucursal is null or es.idSucursal = @idSucursal)

Group by  
 esd.folioEntradaSalida,   
 es.fechaAlta,   
 tp.descripcion,  
 esp.montoPago,  
 es.montoTotalTicket,  
 esp.numeroAutorizacion,  
 es.comentarios,  
 es.montoTotalTicket,  
 estados.descripcion,  
 pers.nombre,  
 pers.apellidoPaterno  
Order by  
 esd.folioEntradaSalida  
End  

Go

ALTER PROCEDURE [dbo].[sp_se_dashboard_productos]
(
--Declare
    @fechaIni  DATETIME,
    @fechaFin  DATETIME,
    @idEntidad INT,
    @idSucursal INT = NULL
)
AS
BEGIN
    --Select @fechaIni = '20260618', @fechaFin = '20260618 23:59', @idEntidad = 10007
    SET NOCOUNT ON;

    DECLARE @fechaIniFiltro DATETIME = CAST(CAST(@fechaIni AS DATE) AS DATETIME);
    DECLARE @fechaFinFiltro DATETIME = DATEADD(DAY, 1, CAST(CAST(@fechaFin AS DATE) AS DATETIME));

    DECLARE @estatusPagoAgenda INT;

    SELECT 
        @estatusPagoAgenda = idEstatusPagoAgenda
    FROM cat_estatusPagoAgenda
    WHERE idEntidad = @idEntidad
      AND clave = 'APLICADO';

    DECLARE @ProductosBase TABLE
    (
        idProductoServicio INT,
        producto           VARCHAR(300),
        categoria          VARCHAR(200),
        cantidad           DECIMAL(18,4),
        ventaTotal         DECIMAL(18,2),
        costoTotal         DECIMAL(18,2),
        origen             VARCHAR(20)
    );

    ------------------------------------------------------------
    -- 1. PRODUCTOS / SERVICIOS VENDIDOS DESDE POS
    ------------------------------------------------------------
    INSERT INTO @ProductosBase
    (
        idProductoServicio,
        producto,
        categoria,
        cantidad,
        ventaTotal,
        costoTotal,
        origen
    )
    SELECT
        c.id AS idProductoServicio,
        c.descripcion AS producto,
        ISNULL(d.descripcion, 'Sin categoría') AS categoria,
        CAST(ISNULL(b.cantidad, 0) AS DECIMAL(18,4)) AS cantidad,
        CAST(ISNULL(b.cantidad, 0) * ISNULL(b.precioFinal, 0) AS DECIMAL(18,2)) AS ventaTotal,
        CAST(
            ISNULL(b.cantidad, 0) *
            CASE 
                WHEN ISNULL(b.costo, 0) > 0 
                    THEN ISNULL(b.costo, 0)
                ELSE ISNULL(prec.Costo, 0)
            END
        AS DECIMAL(18,2)) AS costoTotal,
        'POS' AS origen
    FROM proc_entradasSalidas a
    INNER JOIN proc_entradasSalidasDetalles b
        ON  a.folioEntradaSalida = b.folioEntradaSalida
        AND a.idEntidad = b.idEntidad
    INNER JOIN cat_productosServicios c
        ON  c.id = b.idProductoServicio
        AND c.idEntidad = b.idEntidad
    LEFT JOIN cat_tiposProductosServicios d
        ON  d.id = c.idTipoProductoServicio
        AND d.idEntidad = c.idEntidad
    OUTER APPLY
    (
        SELECT TOP (1)
            CAST(p.Costo AS DECIMAL(18,2)) AS Costo
        FROM cat_precios p
        WHERE p.idProductoServicio = b.idProductoServicio
          AND p.idEntidad = b.idEntidad
        ORDER BY
            CASE 
                WHEN p.precioPrimera = b.precio THEN 0 
                ELSE 1 
            END
    ) prec
    WHERE a.idEstadoTicket = 3
      AND a.fechaAlta >= @fechaIniFiltro
      AND a.fechaAlta <  @fechaFinFiltro
      AND a.idEntidad = @idEntidad
      AND (@idSucursal IS NULL OR a.idSucursal = @idSucursal);

    ------------------------------------------------------------
    -- 2. PRODUCTOS / SERVICIOS COBRADOS DESDE AGENDA
    -- Se distribuye el pago proporcionalmente entre los servicios.
    ------------------------------------------------------------
    ;WITH PagosAgenda AS
    (
        SELECT
            ap.folioAgenda,
            ap.idEntidad,
            SUM(CAST(ap.montoTotal AS DECIMAL(18,2))) AS totalPagado
        FROM proc_agendaPago ap
        WHERE ap.idEstatusPagoAgenda = @estatusPagoAgenda
          AND ap.activo = 1
          AND ap.fechaPago >= @fechaIniFiltro
          AND ap.fechaPago <  @fechaFinFiltro
          AND ap.idEntidad = @idEntidad
          AND (@idSucursal IS NULL OR ap.idSucursal = @idSucursal)
        GROUP BY
            ap.folioAgenda,
            ap.idEntidad
    ),
    PesoAgenda AS
    (
        SELECT
            ags.folioAgenda,
            ags.idEntidad,
            SUM(CAST(ISNULL(ags.precioFinal, 0) AS DECIMAL(18,2))) AS totalAgenda
        FROM proc_agendaDetalleServicio ags
        WHERE 
            ags.idEntidad = @idEntidad
            AND (@idSucursal IS NULL OR ags.idSucursal = @idSucursal)
        GROUP BY
            ags.folioAgenda,
            ags.idEntidad
    )
    INSERT INTO @ProductosBase
    (
        idProductoServicio,
        producto,
        categoria,
        cantidad,
        ventaTotal,
        costoTotal,
        origen
    )
    SELECT
        c.id AS idProductoServicio,
        c.descripcion AS producto,
        ISNULL(d.descripcion, 'Sin categoría') AS categoria,

        CAST(
            ISNULL(pag.totalPagado, 0) / NULLIF(pa.totalAgenda, 0)
        AS DECIMAL(18,4)) AS cantidad,

        CAST(
            ISNULL(ags.precioFinal, 0) *
            (ISNULL(pag.totalPagado, 0) / NULLIF(pa.totalAgenda, 0))
        AS DECIMAL(18,2)) AS ventaTotal,

        CAST(
            ISNULL(prec.Costo, 0) *
            (ISNULL(pag.totalPagado, 0) / NULLIF(pa.totalAgenda, 0))
        AS DECIMAL(18,2)) AS costoTotal,

        'AGENDA' AS origen
    FROM PagosAgenda pag
    INNER JOIN PesoAgenda pa
        ON  pa.folioAgenda = pag.folioAgenda
        AND pa.idEntidad = pag.idEntidad
    INNER JOIN proc_agendaDetalleServicio ags
        ON  ags.folioAgenda = pag.folioAgenda
        AND ags.idEntidad = pag.idEntidad
        AND (@idSucursal IS NULL OR ags.idSucursal = @idSucursal)
    INNER JOIN cat_productosServicios c
        ON  c.id = ags.idProductoServicio
        AND c.idEntidad = ags.idEntidad
    LEFT JOIN cat_tiposProductosServicios d
        ON  d.id = c.idTipoProductoServicio
        AND d.idEntidad = c.idEntidad
    OUTER APPLY
    (
        SELECT TOP (1)
            CAST(p.Costo AS DECIMAL(18,2)) AS Costo
        FROM cat_precios p
        WHERE p.idProductoServicio = ags.idProductoServicio
          AND p.idEntidad = ags.idEntidad
        ORDER BY
            CASE 
                WHEN p.precioPrimera = ags.precioFinal THEN 0 
                ELSE 1 
            END
    ) prec
    WHERE ISNULL(pa.totalAgenda, 0) > 0;

    ------------------------------------------------------------
    -- RESULT SET 1: PRODUCTO MÁS VENDIDO
    ------------------------------------------------------------
    SELECT TOP 1
        producto AS descripcion,
        CAST(SUM(cantidad) AS DECIMAL(12,2)) AS total,
        producto + ' ' +
        CAST(CAST(SUM(cantidad) AS DECIMAL(12,2)) AS VARCHAR(20)) AS UnidadesVendidas
    FROM @ProductosBase
    GROUP BY
        producto
    ORDER BY
        total DESC;

    ------------------------------------------------------------
    -- RESULT SET 2: PRODUCTO CON MAYOR INGRESO
    -- Se mantiene alias GananciaTotal / Ganancia para no romper front.
    ------------------------------------------------------------
    SELECT TOP 1
        producto AS descripcion,
        CAST(SUM(ventaTotal) AS DECIMAL(12,2)) AS GananciaTotal,
        producto + ' $' +
        CAST(CAST(SUM(ventaTotal) AS DECIMAL(12,2)) AS VARCHAR(20)) AS Ganancia
    FROM @ProductosBase
    GROUP BY
        producto
    ORDER BY
        GananciaTotal DESC;

    ------------------------------------------------------------
    -- RESULT SET 3: TOP 10 MÁS VENDIDO
    ------------------------------------------------------------
    SELECT TOP 10
        producto AS descripcion,
        CAST(SUM(cantidad) AS DECIMAL(12,2)) AS UnidadesVendidas
    FROM @ProductosBase
    GROUP BY
        producto
    ORDER BY
        UnidadesVendidas DESC;

    ------------------------------------------------------------
    -- RESULT SET 4: TOP 10 MENOS VENDIDO
    ------------------------------------------------------------
    SELECT TOP 10
        producto AS descripcion,
        CAST(SUM(cantidad) AS DECIMAL(12,2)) AS UnidadesVendidas
    FROM @ProductosBase
    GROUP BY
        producto
    ORDER BY
        UnidadesVendidas ASC;

    ------------------------------------------------------------
    -- RESULT SET 5: TOTAL POR CATEGORÍA
    ------------------------------------------------------------
    SELECT
        categoria,
        CAST(SUM(cantidad) AS DECIMAL(12,2)) AS total
    FROM @ProductosBase
    GROUP BY
        categoria
    ORDER BY
        total DESC;

    ------------------------------------------------------------
    -- RESULT SET 6: RENTABILIDAD DEL PRODUCTO
    ------------------------------------------------------------
    ;WITH RentabilidadProducto AS
    (
        SELECT
            idProductoServicio,
            producto,
            SUM(cantidad) AS unidadesVendidas,
            SUM(ventaTotal) AS ventaTotal,
            SUM(costoTotal) AS costoTotal,
            SUM(ventaTotal) - SUM(costoTotal) AS utilidadTotal
        FROM @ProductosBase
        GROUP BY
            idProductoServicio,
            producto
    )
    SELECT
        idProductoServicio,
        producto,

        CAST(unidadesVendidas AS DECIMAL(12,2)) AS unidadesVendidas,

        '$' + CAST(CAST(ventaTotal AS DECIMAL(12,2)) AS VARCHAR(25)) AS pagoTotal,

        CAST(costoTotal AS DECIMAL(12,2)) AS costoTotal,

        CAST(utilidadTotal AS DECIMAL(12,2)) AS utilidadTotal,

        CAST(
            ROUND(
                utilidadTotal / NULLIF(ventaTotal, 0) * 100.0,
            2)
        AS DECIMAL(12,2)) AS Margen,

        CAST(
            ROUND(
                utilidadTotal / NULLIF(costoTotal, 0) * 100.0,
            2)
        AS DECIMAL(12,2)) AS Rentabilidad

    FROM RentabilidadProducto
    ORDER BY
        Margen DESC;

END;

Go

ALTER PROC [dbo].[sp_se_corteTienda]
(
--Declare
    @idEntidad INT,
    @idUsuarioIniciaCorte INT = NULL,
    @fechaInicio DATETIME = NULL,
    @fechaFin DATETIME = NULL,
    @idSucursal int = null
)
AS
BEGIN
    SET NOCOUNT ON;
    --Select @idEntidad = 10007 , @fechaInicio = '20260619', @fechaFin = '20260619 23:59:59', @idUsuarioIniciaCorte = 80
    ;WITH CorteBase AS
    (
        SELECT
            a.folioCorteTienda,
            b.idEstatusCorte,
            b.folioCorteCaja,
            b.idUsuarioIniciaCorte,
            ISNULL(pers.nombre, '') + ' ' + 
            ISNULL(pers.apellidoPaterno, '') + ' ' + 
            ISNULL(pers.apellidoMaterno, '') AS Nombre,
            b.saldoInicial AS SaldoInicialCaja,
            a.saldoInicial AS SaldoInicialTienda,
            b.fechaInicio AS FechaInicioCaja,
            b.fechaFin AS FechaFinCaja,
            ISNULL(b.idCaja, 0) AS caja,
            ISNULL(b.saldoFinal, 0) AS saldoFinalCaja,
            ISNULL(b.comentarios, 0) AS comentarios,
            a.idEntidad
        FROM proc_corteTienda a
        LEFT JOIN proc_corteCaja b
            ON  a.folioCorteTienda = b.folioCorteTienda
            AND a.idEntidad = b.idEntidad
             AND (@idSucursal IS NULL OR b.idSucursal = @idSucursal)
        LEFT JOIN sys_usuarios us
            ON us.id = b.idUsuarioIniciaCorte
        LEFT JOIN cat_personas pers
            ON pers.id = us.idPersona
        WHERE a.idEntidad = @idEntidad
          AND (@idSucursal IS NULL OR a.idSucursal = @idSucursal)
          AND (
                @idUsuarioIniciaCorte IS NULL
                OR b.idUsuarioIniciaCorte = @idUsuarioIniciaCorte
              )
          AND (
                @fechaInicio IS NULL
                OR b.fechaInicio >= @fechaInicio
              )
          AND (
                @fechaFin IS NULL
                OR b.fechaInicio < DATEADD(DAY, 1, CAST(@fechaFin AS DATE))
              )
    ),

    ------------------------------------------------------------
    -- MOVIMIENTOS POS / TICKETS
    ------------------------------------------------------------
    MovimientosPOS AS
    (
        SELECT
            ticketH.folioCorteTienda,
            ticketH.folioCorteCaja,
            ticketH.idEntidad,
            ISNULL(ticketH.folioEntradaSalida, 0) AS folioEntradaSalida,
            ISNULL(CAST(ticketH.montoTotalTicket AS DECIMAL(18,2)), 0) AS montoTotalTicket,
            ISNULL(CAST(ticketP.montoPago AS DECIMAL(18,2)), 0) AS montoPago,
            ISNULL(catPago.descripcion, 'NA') AS formaPago,
            ISNULL(catPago.id, 0) AS idFormaPago
        FROM proc_entradasSalidas ticketH
        LEFT JOIN proc_entradasSalidaPago ticketP
            ON  ticketP.folioEntradaSalida = ticketH.folioEntradaSalida
            AND ticketP.idEntidad = ticketH.idEntidad
        LEFT JOIN cat_tiposPago catPago
            ON catPago.id = ticketP.idTipoPago
        WHERE ticketH.idEntidad = @idEntidad
          AND ticketH.idEstadoTicket = 3
          AND (@idSucursal IS NULL OR ticketH.idSucursal = @idSucursal)
    ),

    ------------------------------------------------------------
    -- MOVIMIENTOS AGENDA / PAGOS APLICADOS
    ------------------------------------------------------------
    MovimientosAgenda AS
    (
        SELECT
            ap.folioCorteTienda,
            ap.folioCorteCaja,
            ap.idEntidad,
            0 AS folioEntradaSalida,
            ISNULL(CAST(ap.montoTotal AS DECIMAL(18,2)), 0) AS montoTotalTicket,
            ISNULL(CAST(apd.montoPago AS DECIMAL(18,2)), 0) AS montoPago,
            ISNULL(catPago.descripcion, 'NA') AS formaPago,
            ISNULL(catPago.id, 0) AS idFormaPago
        FROM proc_agendaPago ap
        INNER JOIN proc_agendaPagoDetalle apd
            ON  apd.folioAgendaPago = ap.folioAgendaPago
            AND apd.idEntidad = ap.idEntidad
        INNER JOIN cat_estatusPagoAgenda est
            ON  est.idEstatusPagoAgenda = ap.idEstatusPagoAgenda
            AND est.idEntidad = ap.idEntidad
            AND est.clave = 'APLICADO'
        LEFT JOIN cat_tiposPago catPago
            ON catPago.id = apd.idTipoPago
        WHERE ap.idEntidad = @idEntidad
          AND ap.activo = 1
          AND apd.activo = 1
          AND (@idSucursal IS NULL OR ap.idSucursal = @idSucursal)
    ),

    ------------------------------------------------------------
    -- MOVIMIENTOS UNIFICADOS
    ------------------------------------------------------------
    Movimientos AS
    (
        SELECT
            folioCorteTienda,
            folioCorteCaja,
            idEntidad,
            folioEntradaSalida,
            montoTotalTicket,
            montoPago,
            formaPago,
            idFormaPago
        FROM MovimientosPOS

        UNION ALL

        SELECT
            folioCorteTienda,
            folioCorteCaja,
            idEntidad,
            folioEntradaSalida,
            montoTotalTicket,
            montoPago,
            formaPago,
            idFormaPago
        FROM MovimientosAgenda
    )

    ------------------------------------------------------------
    -- RESULTADO FINAL
    ------------------------------------------------------------
    SELECT
        cb.folioCorteTienda,
        cb.idEstatusCorte,
        cb.folioCorteCaja,
        cb.idUsuarioIniciaCorte,
        cb.Nombre,
        cb.SaldoInicialCaja,
        cb.SaldoInicialTienda,
        cb.FechaInicioCaja,
        cb.FechaFinCaja,
        ISNULL(mv.folioEntradaSalida, 0) AS folioEntradaSalida,
        ISNULL(mv.montoTotalTicket, 0) AS montoTotalTicket,
        ISNULL(mv.montoPago, 0) AS montoPago,
        ISNULL(mv.formaPago, 'NA') AS formaPago,
        ISNULL(mv.idFormaPago, 0) AS idFormaPago,
        cb.caja,
        cb.saldoFinalCaja,
        cb.comentarios
    FROM CorteBase cb
    LEFT JOIN Movimientos mv
        ON  mv.folioCorteTienda = cb.folioCorteTienda
        AND mv.folioCorteCaja = cb.folioCorteCaja
        AND mv.idEntidad = cb.idEntidad
    ORDER BY
        cb.idEstatusCorte,
        cb.FechaInicioCaja DESC;

END;

Go


ALTER PROCEDURE [dbo].[sp_se_productosServicio]    
(    
    @id int = 0,    
    @idEntidad int = 0,    
    @isAdmin bit = 0,    
    @idTipoProductoServicio int = 0    ,
    @idSucursal int = null
)    
AS    
BEGIN    
 --Set  @isAdmin  = 1    
 --Declare @filas_afectadas int    
    
 SELECT    
  ps.id    
  ,ps.folioProductoServicio as folio    
  ,ps.descripcion    
  ,ISNULL(SUM(inv.cantidadExistente),0) as existencia    
  ,pre.precioPrimera as Precio    
  ,ISNULL(pre.Costo,0) as costo    
  ,tps.descripcion as tipoProductoServicio    
  ,tps.id as idTipoProductoServicio    
  ,ps.recurrente    
  ,ISNULL(rec.id,0) AS idRecurso    
  ,''/*ISNULL(CONVERT(varchar(max), rec.recurso), '')*/ AS recurso    
        ,ISNULL(rec.imagen ,'') As imagen    
        ,ISNULL(rec.urlImagen ,'') As urlImagen    
  ,ps.comentarios    
  ,ps.activo    
  ,ps.idEntidad    
  ,ISNULL(ps.fechaModificacion,ps.fechaAlta) As fechaModificacion    
  ,ISNULL(ps.idUsuarioModifica , ps.idUsuarioAlta) As idUsuarioModifica    
  ,ps.fechaAlta    
  ,ps.idUsuarioAlta    
  ,ISNULL(ps.calificacion,0) AS calificacion    
  ,ISNULL(ps.popular,0) as popular    
  ,ISNULL(CAST(ps.requiereSerie AS BIT), 0) AS requiereSerie    
  ,ISNULL(CAST(ps.requiereFechaCaducidad AS BIT), 0) AS requiereFechaCaducidad    
  ,ISNULL(CAST(ps.requiereLote AS BIT), 0) AS requiereLote    
  ,ISNULL(ps.idUnidadMedidaCompra, 0) AS idUnidadMedidaCompra    
  ,ISNULL(ps.idUnidadMedidaVenta , 0) AS idUnidadMedidaVenta    
  ,ISNULL(ps.stockMin, 0) AS stockMin    
  ,ISNULL(ps.stockMax, 0) AS stockMax    
  ,ISNULL(ps.idUnidadMedidaBase,0) as idUnidadMedidaBase    
  ,ISNULL(ps.requiereNumeracion,0) as requiereNumeracion    
  ,um.id as idUMBase  
  ,um.descripcion as UMBase  
  ,um.abreviatura as abreviaturaUMBase  
  ,Cast(ISNULL(ps.esComodin,0) AS bit) As esComodin  
  ,Cast(ISNULL(ps.esServicio,0) AS bit) As esServicio  
  ,Cast(ISNULL(ps.mostrarEnAgenda,0) AS bit) As mostrarEnAgenda  
  ,Cast(ISNULL(ps.duracionBaseMin,0) As decimal(10,4)) As duracionBaseMin  
 INTO    
  #tabla_temporal    
 FROM    
  cat_productosServicios ps    
  left join cat_recursos rec    
   on ps.id = rec.idRegistro    
   and idTabla = 1 /*Tabla de producto servicio*/    
  Join cat_precios pre    
   On ps.id = pre.idProductoServicio    
  Join cat_tiposProductosServicios tps    
   On ps.idTipoProductoServicio = tps.id    
   and ps.idEntidad = tps.idEntidad    
    
  Left Join inv_inventario inv    
   On inv.idProductoServicio = ps.id    
   AND inv.idEntidad = ps.idEntidad
   AND (@idSucursal IS NULL OR inv.idSucursal = @idSucursal)
  JOIN cat_unidadesMedida um  
    On um.id = ps.idUnidadMedidaBase  
 WHERE    
 (@id = 0 OR ps.id = @id)    
 AND ps.idEntidad = @idEntidad AND ps.activo = 1    
 AND (@idTipoProductoServicio = 0 OR ps.idTipoProductoServicio = @idTipoProductoServicio)    

 Group By    
  ps.id    
  ,ps.folioProductoServicio    
  ,ps.descripcion    
  ,pre.precioPrimera     
  ,pre.Costo     
  ,tps.descripcion     
  ,tps.id     
  ,ps.recurrente    
  ,ISNULL(rec.id,0)     
  ,ISNULL(CONVERT(varchar(max), rec.recurso), '')     
        ,ISNULL(rec.imagen ,'')     
        ,ISNULL(rec.urlImagen ,'')     
  ,ps.comentarios    
  ,ps.activo    
  ,ps.idEntidad    
  ,ISNULL(ps.fechaModificacion,ps.fechaAlta)    
  ,ISNULL(ps.idUsuarioModifica , ps.idUsuarioAlta)    
  ,ps.fechaAlta    
  ,ps.idUsuarioAlta    
  ,ISNULL(ps.calificacion,0)     
  ,ISNULL(ps.popular,0)     
  ,ps.requiereSerie    
  ,ps.requiereFechaCaducidad    
  ,ps.requiereLote    
  ,idUnidadMedidaCompra    
  ,idUnidadMedidaVenta    
  ,stockMin    
  ,stockMax    
  ,ps.idUnidadMedidaBase    
  ,ps.requiereNumeracion    
  ,um.id   
  ,um.descripcion  
  ,um.abreviatura  
  ,ISNULL(ps.esComodin,0)   
  ,ISNULL(ps.esServicio,0)   
  ,ISNULL(ps.mostrarEnAgenda,0)    
  ,ISNULL(ps.duracionBaseMin,0)   

    Select * From #tabla_temporal order by existencia desc     
    
    SELECT     
        invd.id,    
        ps.descripcion AS producto,    
        invd.idProductoServicio,    
        ISNULL(invd.serie,'') as serie,    
        ISNULL(invd.lote,'') as lote,    
        invd.fechaExpira,    
        ISNULL(invd.numeracion,0) as numeracion,    
        invd.cantidadExistente,    
        prec.Costo As costoUnitario,    
        invd.precioVenta,    
        invd.fechaUltimoMovimiento,    
        invd.activo    
    FROM inv_inventarioDet invd    
    JOIN cat_productosServicios ps     
        ON invd.idProductoServicio = ps.id    
        AND ps.idEntidad = invd.idEntidad
        and invd.idEntidad = @idEntidad    
        and invd.cantidadExistente > 0    
    JOIN cat_precios prec
        ON ps.id = prec.idProductoServicio
        And ps.idEntidad = prec.idEntidad
    WHERE     
        (@id = 0 OR ps.id = @id)    
        AND ps.idEntidad = @idEntidad 
        AND ps.activo = 1   
        AND (@idSucursal IS NULL OR invd.idSucursal = @idSucursal)
        
    Delete #tabla_temporal    
END;   