ALTER PROC sp_se_kardex_movimientos    
	@idEntidad int,
	@fechaInicio datetime = '20250101',
	@fechaFin datetime = '20990101'
As    
Begin    
     
	Select     
		h.folioMovimientoInventario,    
		cat.descripcion as tipoMovimiento,    
		d.idProductoServicio,    
		CASE    
			WHEN d.numeracion >0 Then CAST(d.numeracion   AS VARCHAR(5))    
			ELSE '' END    
		AS numeracion,    
		CAST(d.serie        AS VARCHAR(50)) as serie,    
		CAST(d.lote         AS VARCHAR(20)) as lote,    
		CASE     
			WHEN d.fechaVencimiento > '20000101'     
			THEN CONVERT(VARCHAR(10), d.fechaVencimiento, 23)    
		ELSE ''End    
		AS fechaVencimiento,    
		h.fechaAlta,    
		ps.descripcion As nombreProducto,  
		d.cantidad As CantidadMovimiento,    
		cat.afectacion,  
		ISNULL(SUM(cat.afectacion * d.cantidad) OVER (  
		PARTITION BY d.idProductoServicio, d.idEntidad  
		ORDER BY h.fechaAlta, h.folioMovimientoInventario  
		ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING   
		),   
		0) AS ExistenciaAntesMovimiento,    
		SUM(cat.afectacion * d.cantidad) OVER (    
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
		d.fechaVencimiento    ,
		ps.folioProductoServicio
	Order by    
		h.fechaAlta    
End

