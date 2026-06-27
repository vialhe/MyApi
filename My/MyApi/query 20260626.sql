Select * From proc_corteCaja   Where idEntidad = 10007
Select * From proc_corteTienda Where idEntidad = 10007 
Select * From proc_entradasSalidas where idEntidad = 10007 and fechaAlta > '20260626'
Select * From proc_entradasSalidasDetalles where idEntidad = 10007 and fechaAlta > '20260626'
Select * From proc_entradasSalidaPago where idEntidad = 10007 and fechaAlta > '20260626'
Select * From proc_movimientosInventarios where idEntidad = 10007 and fechaAlta > '20260626'
Select * From proc_movimientosInventariosDetalles  where idEntidad = 10007 and fechaAlta > '20260626'
Select * from inv_inventario   	Where idEntidad = 10007	And idProductoServicio = 2571
Select * from inv_inventarioDet Where idEntidad = 10007 And idProductoServicio = 2571

ALTER PROC sp_se_kardex_movimientos          
 @idEntidad int,      
 @fechaInicio datetime = '20250101',      
 @fechaFin datetime = '20990101'      
As          
Begin          
           
 -- 1. Calculamos el saldo histórico antes de la fecha de inicio    
 ;WITH SaldoInicialCTE AS (    
    SELECT     
        d.idProductoServicio,    
        ISNULL(SUM(cat.afectacion * d.cantidadBase), 0) as CantidadInicial    
    FROM proc_movimientosInventarios h    
    JOIN proc_movimientosInventariosDetalles d     
        ON h.folioMovimientoInventario = d.folioMovimientoInventario     
        AND h.idEntidad = d.idEntidad    
    JOIN cat_tiposMovmientosInventario cat     
        ON cat.id = h.idTipoMovimientoInventario    
    WHERE     
        h.idEntidad = @idEntidad     
        AND h.fechaAlta < @fechaInicio -- IMPORTANTE: Todo lo anterior al rango    
    GROUP BY d.idProductoServicio    
 )    
    
 -- 2. Consulta Principal    
 Select            
  h.folioMovimientoInventario,          
  cat.descripcion as tipoMovimiento,          
  d.idProductoServicio,          
  CASE          
   WHEN d.numeracion > 0 Then CAST(d.numeracion   AS VARCHAR(5))          
   ELSE '' END          
  AS numeracion,          
  CAST(d.serie         AS VARCHAR(50)) as serie,          
  CAST(d.lote          AS VARCHAR(20)) as lote,          
  CASE            
   WHEN d.fechaVencimiento > '20000101'            
   THEN CONVERT(VARCHAR(10), d.fechaVencimiento, 23)          
  ELSE ''End          
  AS fechaVencimiento,          
  h.fechaAlta,          
  ps.descripcion As nombreProducto,        
  d.cantidadBase,
  d.cantidad As CantidadMovimiento,          
  umbase.abreviatura As abreviaturaUMBase,  
  ummov.abreviatura,  
  cat.afectacion,        
    
  -- 3. Ajuste: Saldo Inicial + Acumulado Anterior    
  ISNULL(si.CantidadInicial, 0) +     
  ISNULL(SUM(cat.afectacion * d.cantidad) OVER (        
  PARTITION BY d.idProductoServicio, d.idEntidad        
  ORDER BY h.fechaAlta, h.folioMovimientoInventario        
  ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING         
  ),         
  0) AS ExistenciaAntesMovimiento,          
      
  -- 4. Ajuste: Saldo Inicial + Acumulado Actual    
  ISNULL(si.CantidadInicial, 0) +    
  SUM(cat.afectacion * d.cantidadBase) OVER (          
  PARTITION BY d.idProductoServicio, d.idEntidad          
  ORDER BY h.fechaAlta, h.folioMovimientoInventario          
  ROWS UNBOUNDED PRECEDING          
  ) AS ExistenciaDespuesMovimiento,        
      
  inv.cantidadExistente As CantidaActual,      
  ps.folioProductoServicio as folio      
 From            
  proc_movimientosInventarios h          
  join proc_movimientosInventariosDetalles d          
   On h.folioMovimientoInventario = d.folioMovimientoInventario          
   and h.identidad = d.identidad          
  join inv_inventario inv          
   On inv.idProductoServicio = d.idProductoServicio          
   and inv.idEntidad = d.idEntidad          
  join inv_inventarioDet invd          
   On invd.idProductoServicio = inv.idProductoServicio          
   and invd.idEntidad =  inv.idEntidad          
  join cat_tiposMovmientosInventario cat          
   On cat.id = h.idTipoMovimientoInventario          
  join cat_productosServicios ps          
   On ps.id = d.idProductoServicio     
  -- Join con la CTE de Saldo Inicial    
  left join SaldoInicialCTE si   
 ON si.idProductoServicio = d.idProductoServicio     
  join cat_unidadesMedida umbase  
 ON umbase.id = ps.idUnidadMedidaBase  
  join cat_unidadesMedida ummov  
 On d.idUnidadMedida = ummov.id  
 Where            
  h.idEntidad = @idEntidad          
  and h.fechaAlta between @fechaInicio and @fechaFin      
 Group By            
  h.folioMovimientoInventario,          
  cat.descripcion,          
  h.fechaAlta,          
  ps.descripcion,          
  d.cantidad,          
  inv.cantidadExistente,          
  d.idProductoServicio,          
  d.idEntidad,          
  cat.afectacion,          
  d.serie,          
  d.lote,          
  d.numeracion,          
  d.fechaVencimiento,        
  ps.folioProductoServicio,    
  si.CantidadInicial, -- Agregado al Group By    
  umbase.abreviatura,  
  ummov.abreviatura  ,
  d.cantidadBase
 Order by          
  h.fechaAlta          
End
