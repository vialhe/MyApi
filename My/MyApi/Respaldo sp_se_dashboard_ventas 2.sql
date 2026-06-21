ALTER PROCEDURE [dbo].[sp_se_dashboard_ventas]        
(        
--Declare  
  @fechaIni datetime ,        
  @fechaFin datetime ,        
  @idEntidad int,        
  @idEstadoTicket int = 3        
)        
As        
Begin        
      
--Select @fechaIni = '20260618', @fechaFin = '20260618',@idEntidad = 10007  
      
 Declare @total decimal(10,2)        
 Declare @cantidad decimal(10,2)        
 Declare @estatusPagoAgenda int  
 Select @estatusPagoAgenda = idEstatusPagoAgenda From cat_estatusPagoAgenda Where idEntidad = @idEntidad And clave = 'APLICADO'  
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
 --        
 -- SUM TOTAL TICKETS        
 --        
  Select        
  @total=SUM(esh.montoTotalTicket)          
  From         
  proc_entradasSalidas esh        
  Where        
  idEstadoTicket = @idEstadoTicket        
  And esh.fechaAlta between @fechaIni and @fechaFin         
  and esh.idEntidad = @idEntidad      
      
 Select ISNULL(@total,0) As Total        
 UNION ALL        
 Select        
  ISNULL(SUM( esp.montoPago),0) as Total_        
 From         
  proc_entradasSalidas esh        
  join proc_entradasSalidaPago esp        
  On esh.folioEntradaSalida = esp.folioEntradaSalida        
  and esh.idEntidad = esp.idEntidad        
 Where        
  idEstadoTicket = @idEstadoTicket        
  And esh.fechaAlta between @fechaIni and @fechaFin         
  And esh.idEntidad = @idEntidad      
 --        
 -- SUM TOTAL TICKETS NETO (COSTO)  
 --        
 Select        
  Cast(ISNULL(SUM(Case When ISNULL(esd.costo,0) > 0 Then esd.costo Else prec.Costo End),0) AS decimal(10,2)) as TotalNeto         
 From         
  proc_entradasSalidas esh  
  join proc_entradasSalidasDetalles esd  
    ON esh.folioEntradaSalida = esd.folioEntradaSalida  
    And esh.idEntidad = esd.idEntidad  
  join cat_precios prec  
    On prec.idProductoServicio = esd.idProductoServicio  
    And prec.idEntidad = esd.idEntidad  
 Where        
  idEstadoTicket = @idEstadoTicket        
  And esh.fechaAlta between @fechaIni and @fechaFin         
  And esh.idEntidad = @idEntidad      
        
 --        
 -- CANTIDAD TICKETS        
 --        
 Select        
  @cantidad=Count(esh.folioEntradaSalida)        
 From         
  proc_entradasSalidas esh         
 Where        
 idEstadoTicket = @idEstadoTicket        
 And esh.fechaAlta between @fechaIni and @fechaFin         
 And esh.idEntidad = @idEntidad      
      
 Select Cast((ISNULL(@total / @cantidad,0))AS decimal(10,2))  As Prom        
 Select @cantidad as Cantidad        
        
        
        
 Select        
  Cast(SUM(esp.montoPago) As decimal(10,2)) As Total,        
  b.descripcion        
 From         
  proc_entradasSalidas esh        
  join proc_entradasSalidaPago esp        
   On esh.folioEntradaSalida = esp.folioEntradaSalida        
   and esh.idEntidad = esp.idEntidad        
  join cat_estadosEntradaSalida a        
   On a.id = esh.idEstadoTicket        
  join cat_tiposPago b        
   On b.id = esp.idTipoPago        
 Where        
  idEstadoTicket = 3        
  And esh.fechaAlta between @fechaIni and @fechaFin         
  And esh.idEntidad = @idEntidad      
 Group By        
 b.descripcion        
        
 exec sp_se_dashboardDinamicSales @fechaIni, @fechaFin, @idEntidad        
        
 --DECLARE @inicioHoy datetime = DateAdd(HOUR,6,Cast(CAST(dbo.fn_GetDateMX() AS date) As Datetime));        
 --DECLARE @finExcl datetime = DATEADD(HOUR, 23, Cast(CAST(dbo.fn_GetDateMX() AS date) As datetime));        
 DECLARE @hoy date = CAST(dbo.fn_GetDateMX() AS date);  
 DECLARE @inicioHoy datetime = CAST(@hoy AS datetime);   
 DECLARE @finExcl datetime = DATEADD(DAY, 1, CAST(@hoy AS datetime));  
 exec sp_se_dashboardDinamicSales @inicioHoy, @finExcl, @idEntidad        
        
  
 ------------------------------------------------------------
    -- TOTAL POR CAJERO / VENTAS
    ------------------------------------------------------------
    INSERT INTO @tbl
    (
        orden,
        nombre,
        total,
        cantidad,
        tipo
    )
    SELECT
        1 AS orden,
        LTRIM(RTRIM(
            ISNULL(c.nombre, '') + ' ' +
            ISNULL(c.apellidoPaterno, '') + ' ' +
            ISNULL(c.apellidoMaterno, '')
        )) AS nombre,
        SUM(CAST(esh.montoTotalTicket AS DECIMAL(18,2))) AS total,
        COUNT(*) AS cantidad,
        'Venta' AS tipo
    FROM proc_entradasSalidas esh
    INNER JOIN sys_usuarios b
        ON b.id = esh.idUsuarioAlta
    INNER JOIN cat_personas c
        ON c.id = b.idPersona
    WHERE esh.idEstadoTicket = @idEstadoTicket
      AND esh.fechaAlta >= @fechaIniFiltro
      AND esh.fechaAlta <  @fechaFinFiltro
      AND esh.idEntidad = @idEntidad
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
            folioAgenda,
            idEntidad,
            SUM(CAST(montoTotal AS DECIMAL(18,2))) AS totalPagado
        FROM proc_agendaPago
        WHERE idEstatusPagoAgenda = @estatusPagoAgenda
          AND fechaPago >= @fechaIniFiltro
          AND fechaPago <  @fechaFinFiltro
          AND idEntidad = @idEntidad
        GROUP BY 
            folioAgenda, 
            idEntidad
    ),
    PesoTotalPorAgenda AS 
    (
        SELECT
            folioAgenda,
            idEntidad,
            SUM(CAST(ISNULL(precioFinal, 0) AS DECIMAL(18,2))) AS pesoTotal
        FROM proc_agendaDetalleServicio
        WHERE idEntidad = @idEntidad
        GROUP BY 
            folioAgenda, 
            idEntidad
    )
    INSERT INTO @tbl
    (
        orden,
        nombre,
        total,
        cantidad,
        tipo
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
        ) AS total,
        COUNT(DISTINCT ags.folioAgenda) AS cantidad,
        'Agenda' AS tipo
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
    -- RESULTADO FINAL UNIFICADO
    ------------------------------------------------------------
    SELECT
        nombre,
        Total,
        Cantidad,
        Tipo
    FROM @tbl
    ORDER BY
        orden,
        total DESC,
        nombre;

END;
