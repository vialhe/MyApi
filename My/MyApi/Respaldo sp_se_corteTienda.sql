ALTER PROC [dbo].[sp_se_corteTienda]  
--Declare
 @idEntidad int ,
 @idUsuarioIniciaCorte int = null, --<-- nuevo paramtro 
 @fechaInicio DATETIME = NULL,
 @fechaFin DATETIME = NULL
As  
Begin  
  
-- DECLARE @existeTickets INT = (  
--        SELECT COUNT(*)  
--        FROM proc_entradasSalidas  
--        WHERE idEntidad = @idEntidad  
--        AND idEstadoTicket = 3  
--    );  

--Select @existeTickets

 SELECT   
  a.folioCorteTienda,  
  b.idEstatusCorte,  
  b.folioCorteCaja,  
  b.idUsuarioIniciaCorte,  
  pers.nombre + ' '+pers.apellidoPaterno +' '+ pers.apellidoMaterno As Nombre ,  
  b.saldoInicial as SaldoInicialCaja,  
  a.saldoInicial as SaldoInicialTienda,  
  b.fechaInicio as FechaInicioCaja,  
  b.fechaFin as FechaFinCaja,  
  ISNULL(ticketH.folioEntradaSalida,0) As folioEntradaSalida,  
  ISNULL(ticketH.montoTotalTicket,0) As montoTotalTicket,  
  ISNULL(ticketP.montoPago,0) As montoPago,  
  ISNULL(catPago.descripcion,'NA') As formaPago,  
  ISNULL(catPago.id,0) As idFormaPago,  
  ISNULL(b.idCaja,0) As caja,  
  ISNULL(b.saldoFinal,0)  As saldoFinalCaja,  
  ISNULL(b.comentarios,0) As comentarios  
 From  
  proc_corteTienda a  
  LEFT JOIN proc_corteCaja b  
   On a.folioCorteTienda = b.folioCorteTienda  
   And a.idEntidad =  b.idEntidad  
     
  Left Join proc_entradasSalidas ticketH  
   On ticketH.folioCorteCaja = b.folioCorteCaja  
   And ticketH.folioCorteTienda = b.folioCorteTienda  
   And ticketH.idEntidad = b.idEntidad  
   And ticketH.idEstadoTicket = 3
  Left Join proc_entradasSalidaPago ticketP  
   On ticketP.folioEntradaSalida = ticketH.folioEntradaSalida  
   And ticketP.idEntidad = ticketH.idEntidad  
  Left Join cat_tiposPago catPago  
   On catPago.id = ticketP.idTipoPago  
  
  Left Join sys_usuarios us  
   On us.id = b.idUsuarioIniciaCorte  
  Left Join cat_personas pers  
   On pers.id = us.idPersona  
 WHERE  
    a.idEntidad = @idEntidad   
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
  
 ORDER BY  
  b.idEstatusCorte , b.fechaAlta desc  
End
