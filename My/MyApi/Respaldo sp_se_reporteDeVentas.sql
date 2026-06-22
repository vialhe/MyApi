Alter PROC [dbo].[sp_se_reporteDeVentas]  
 @fechaInicio datetime,  
 @fechaFin datetime,  
 @idEntidad int ,
 @idUsuario int = null
  
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
