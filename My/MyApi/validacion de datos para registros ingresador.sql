DECLARE @idEntidad int = 10007;

SELECT
    x.folioEmpleado,
    x.folioAgenda AS agenda1,
    x.folioAgendaDetalleServicio AS detalle1,
    x.horaInicio,
    x.horaFin,
    y.folioAgenda AS agenda2,
    y.folioAgendaDetalleServicio AS detalle2,
    y.horaInicio AS horaInicio2,
    y.horaFin AS horaFin2
FROM
(
    SELECT
        dse.folioEmpleado,
        a.folioAgenda,
        ds.folioAgendaDetalleServicio,
        ISNULL(ds.horaInicioProgramada,a.horaInicioProgramada) AS horaInicio,
        ISNULL(ds.horaFinProgramada,a.horaFinProgramada) AS horaFin,
        ds.idEntidad
    FROM dbo.proc_agendaDetalleServicioEmpleado dse
    INNER JOIN dbo.proc_agendaDetalleServicio ds
        ON ds.folioAgendaDetalleServicio = dse.folioAgendaDetalleServicio
       AND ds.idEntidad = dse.idEntidad
    INNER JOIN dbo.proc_agenda a
        ON a.folioAgenda = ds.folioAgenda
       AND a.idEntidad = ds.idEntidad
    WHERE dse.idEntidad = @idEntidad
      AND ISNULL(dse.activo,1) = 1
      AND ISNULL(ds.activo,1) = 1
      AND ISNULL(a.activo,1) = 1
      AND ISNULL(ds.cancelado,0) = 0
) x
INNER JOIN
(
    SELECT
        dse.folioEmpleado,
        a.folioAgenda,
        ds.folioAgendaDetalleServicio,
        ISNULL(ds.horaInicioProgramada,a.horaInicioProgramada) AS horaInicio,
        ISNULL(ds.horaFinProgramada,a.horaFinProgramada) AS horaFin,
        ds.idEntidad
    FROM dbo.proc_agendaDetalleServicioEmpleado dse
    INNER JOIN dbo.proc_agendaDetalleServicio ds
        ON ds.folioAgendaDetalleServicio = dse.folioAgendaDetalleServicio
       AND ds.idEntidad = dse.idEntidad
    INNER JOIN dbo.proc_agenda a
        ON a.folioAgenda = ds.folioAgenda
       AND a.idEntidad = ds.idEntidad
    WHERE dse.idEntidad = @idEntidad
      AND ISNULL(dse.activo,1) = 1
      AND ISNULL(ds.activo,1) = 1
      AND ISNULL(a.activo,1) = 1
      AND ISNULL(ds.cancelado,0) = 0
) y
    ON x.folioEmpleado = y.folioEmpleado
   AND x.idEntidad = y.idEntidad
   AND x.folioAgendaDetalleServicio < y.folioAgendaDetalleServicio
   AND x.horaInicio < y.horaFin
   AND x.horaFin > y.horaInicio
ORDER BY x.folioEmpleado, x.horaInicio;



-- --------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------
GO
DECLARE @idEntidad int = 10007;

SELECT
    a.folioAgenda,
    ds.folioAgendaDetalleServicio,
    a.horaInicioProgramada AS horaInicioAgenda,
    a.horaFinProgramada AS horaFinAgenda,
    ds.horaInicioProgramada AS horaInicioDetalle,
    ds.horaFinProgramada AS horaFinDetalle
FROM dbo.proc_agenda a
INNER JOIN dbo.proc_agendaDetalleServicio ds
    ON ds.folioAgenda = a.folioAgenda
   AND ds.idEntidad = a.idEntidad
WHERE a.idEntidad = @idEntidad
  AND ISNULL(a.activo,1) = 1
  AND ISNULL(ds.activo,1) = 1
  AND
  (
      ds.horaInicioProgramada < a.horaInicioProgramada
      OR ds.horaFinProgramada > a.horaFinProgramada
      OR ds.horaFinProgramada <= ds.horaInicioProgramada
  )
ORDER BY a.folioAgenda, ds.folioAgendaDetalleServicio;


-- --------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------
go
DECLARE @idEntidad int = 10007;

SELECT
    a.folioAgenda,
    a.totalCotizado AS totalCotizadoAgenda,
    ISNULL(d.totalDetallesActivos,0) AS totalDetallesActivos,
    a.totalPagado AS totalPagadoAgenda,
    ISNULL(p.totalPagosActivos,0) AS totalPagosActivos
FROM dbo.proc_agenda a
OUTER APPLY
(
    SELECT SUM(ISNULL(ds.precioFinal,0) * ISNULL(ds.cantidad,1)) AS totalDetallesActivos
    FROM dbo.proc_agendaDetalleServicio ds
    WHERE ds.folioAgenda = a.folioAgenda
      AND ds.idEntidad = a.idEntidad
      AND ISNULL(ds.activo,1) = 1
      AND ISNULL(ds.cancelado,0) = 0
) d
OUTER APPLY
(
    SELECT SUM(ISNULL(ap.montoTotal,0)) AS totalPagosActivos
    FROM dbo.proc_agendaPago ap
    WHERE ap.folioAgenda = a.folioAgenda
      AND ap.idEntidad = a.idEntidad
      AND ISNULL(ap.activo,1) = 1
) p
WHERE a.idEntidad = @idEntidad
  AND ISNULL(a.activo,1) = 1
  AND
  (
      ISNULL(a.totalCotizado,0) <> ISNULL(d.totalDetallesActivos,0)
      OR ISNULL(a.totalPagado,0) <> ISNULL(p.totalPagosActivos,0)
  )
ORDER BY a.folioAgenda;

-- --------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------
go
DECLARE @idEntidad int = 10007;

SELECT
    a.folioAgenda,
    COUNT(b.folioAgendaBitacora) AS movimientosBitacora
FROM dbo.proc_agenda a
LEFT JOIN dbo.proc_agendaBitacora b
    ON b.folioAgenda = a.folioAgenda
   AND b.idEntidad = a.idEntidad
   AND ISNULL(b.activo,1) = 1
WHERE a.idEntidad = @idEntidad
  AND ISNULL(a.activo,1) = 1
GROUP BY a.folioAgenda
HAVING COUNT(b.folioAgendaBitacora) = 0
ORDER BY a.folioAgenda;