Select 
	*
From 
	cat_productosServicios a
	join cat_tiposProductosServicios b
		ON b.id = a.idTipoProductoServicio
		And a.idEntidad = b.idEntidad
	join cat_recursos c
		ON a.id = c.idRegistro
		And a.idEntidad = c.idEntidad
	join cat_precios precios
		On precios.idProductoServicio = a.id
		And precios.idEntidad = a.idEntidad
	join cat_unidadesMedida umbase
		ON umbase.id = a.idUnidadMedidaBase
		And umbase.idEntidad = a.idEntidad
	join cat_unidadesMedida umventa
		ON umventa.id = a.idUnidadMedidaVenta
		And umventa.idEntidad = a.idEntidad
	join cat_unidadesMedida umcompra
		ON umcompra.id = a.idUnidadMedidaCompra
		And umcompra.idEntidad = a.idEntidad
where 
	a.idEntidad = 10007
	