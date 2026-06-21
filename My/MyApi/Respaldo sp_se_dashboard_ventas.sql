ALTER PROCEDURE [dbo].[sp_se_dashboard_ventas]      
(      
  @fechaIni datetime ,      
  @fechaFin datetime ,      
  @idEntidad int,      
  @idEstadoTicket int = 3      
)      
As      
Begin      
       
 Declare @total decimal(10,2)      
 Declare @cantidad decimal(10,2)      
      
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
 -- SUM TOTAL TICKETS NETO ///FALTAA CALCULAAAR      
 --      
 Select      
  Cast((0.84 * ISNULL(SUM(esh.montoTotalTicket),0)) AS decimal(10,2)) as TotalNeto       
 From       
  proc_entradasSalidas esh      
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
      
 DECLARE @inicioHoy datetime = DateAdd(HOUR,6,Cast(CAST(dbo.fn_GetDateMX() AS date) As Datetime));      
 DECLARE @finExcl datetime = DATEADD(HOUR, 23, Cast(CAST(dbo.fn_GetDateMX() AS date) As datetime));      
 exec sp_se_dashboardDinamicSales @inicioHoy, @finExcl, @idEntidad      
      
 --      
 -- TOTAL POR CAJERO      
 --      
 Select      
  b.nombre,      
  SUM(Cast(esh.montoTotalTicket As decimal(12,2))) As Total,      
  Count(b.nombre) as Cantidad      
 From       
  proc_entradasSalidas esh      
  join sys_usuarios b      
   On b.id = esh.idUsuarioAlta      
  join cat_personas c      
   On c.id = b.idPersona      
 Where      
  idEstadoTicket = @idEstadoTicket      
  And esh.fechaAlta between @fechaIni and @fechaFin       
  And esh.idEntidad  = @idEntidad    
 Group by     
  b.nombre      
       
 --Select      
 -- esh.folioEntradaSalida,      
 -- esh.fechaAlta,      
 -- a.descripcion,      
 -- esh.idTipoEntradaSalida,      
 -- esh.montoTotalTicket,      
 -- esh.pagoTotal,      
 -- esh.suCambio,      
 -- esp.idTipoPago,      
 -- b.descripcion,      
 -- esp.montoPago      
 --From       
 -- proc_entradasSalidas esh      
 -- join proc_entradasSalidaPago esp      
 --  On esh.folioEntradaSalida = esp.folioEntradaSalida      
 --  and esh.idEntidad = esp.idEntidad    
 -- join cat_estadosEntradaSalida a      
 --  On a.id = esh.idEstadoTicket      
 -- join cat_tiposPago b      
 --  On b.id = esp.idTipoPago      
 --Where      
 -- idEstadoTicket = 3      
 -- And esh.fechaAlta between @fechaIni and @fechaFin       
 --Order by      
 -- esh.folioEntradaSalida      
END
