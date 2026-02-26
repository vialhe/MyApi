
Select 'Peluche Promedio' As Producto, 120 As Costo UNION ALL
Select 'Taza', 51 UNION ALL
Select 'Chocolates', 35 UNION ALL
Select 'Cuadro Marco', 14.5 UNION ALL
Select 'Corazon', 21 UNION ALL
Select 'Llavero', 12 UNION ALL
Select 'Paleta', 3 UNION ALL
Select 'Oso de rosas', 180 UNION ALL
Select 'Osos de bolsa', 105 UNION ALL
Select 'Porta taza', 7 UNION ALL
Select 'Maquillaje', 30 


Select 
	a.descripcion as Producto,
	b.precioPrimera as Precio,
	b.Costo,
	b.precioPrimera - b.Costo as Diferencia,
	CASE 
        WHEN b.Costo = 0 THEN '0.0%'
        ELSE 
            CONCAT(
                CAST(
                    ROUND(((b.precioPrimera - b.Costo) * 100.0) / b.Costo, 1)
                    AS DECIMAL(5,1)
                ),
                '%'
            )
    END AS PorcentajeGanancia,
	ISNULL(inv.cantidadExistente,0) As cantidadExistente

From 
	cat_productosServicios a
	join cat_precios b
		On b.idProductoServicio = a.id
		And b.idEntidad = a.idEntidad
	left join inv_inventario inv
		On inv.idProductoServicio = a.id
where	
	a.idEntidad =10006
Order by
	Diferencia