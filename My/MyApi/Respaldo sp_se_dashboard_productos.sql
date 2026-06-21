ALTER PROCEDURE [dbo].[sp_se_dashboard_productos]  
(  
--Declare  
 @fechaIni datetime ,  
 @fechaFin datetime ,  
 @idEntidad int  
)  
As  
Begin  
 --Select   
 -- @fechaIni='20250827 00:00',   
 -- @fechaFin='20250827 23:59',  
 -- @idEntidad= 9999  
 Declare @total decimal(10,2)  
 Declare @cantidad decimal(10,2)  
  
 --  
 -- Producto mas vendido  
 --  
   
 Select  
 top 1  
  c.descripcion ,  
  Cast(sum(b.cantidad) AS decimal(12,2)) As total,  
  c.descripcion +' ' +  
  CAST( Cast(sum(b.cantidad) AS decimal(12,2)) as varchar(20)) As UnidadesVendidas  
 From   
  proc_entradasSalidas a  
  join proc_entradasSalidasDetalles b  
   On a.folioEntradaSalida = b.folioEntradaSalida  
   And a.idEntidad = b.idEntidad  
  join cat_productosServicios c  
   On c.id = b.idProductoServicio  
 Where  
  a.idEstadoTicket = 3  
  And a.fechaAlta between @fechaIni and @fechaFin 
  And a.idEntidad = @idEntidad
 Group By  
  c.descripcion  
 Order by  
  total desc  
 --  
 -- Producto mayor ganancia  
 --  
 Select  
 top 1  
  c.descripcion ,  
  Cast(SUM(b.cantidad*b.precioFinal) AS decimal(12,2))  As GananciaTotal,  
  c.descripcion +' $'+  
  CAST(Cast(SUM(b.cantidad*b.precioFinal) AS decimal(12,2)) AS Varchar(20)) As Ganancia  
 From   
  proc_entradasSalidas a  
  join proc_entradasSalidasDetalles b  
   On a.folioEntradaSalida = b.folioEntradaSalida  
   And a.idEntidad = b.idEntidad  
  join cat_productosServicios c  
   On c.id = b.idProductoServicio  
 Where  
  a.idEstadoTicket = 3  
  And a.fechaAlta between @fechaIni and @fechaFin   
  And a.idEntidad = @idEntidad
 Group by  
  c.descripcion  
 Order by  
  GananciaTotal desc  
 --  
 -- Top 10 más vendido  
 --  
 Select  
 top 10  
  c.descripcion,  
  sum(b.cantidad) as UnidadesVendidas  
 From   
  proc_entradasSalidas a  
  join proc_entradasSalidasDetalles b  
   On a.folioEntradaSalida = b.folioEntradaSalida  
   And a.idEntidad = b.idEntidad  
  join cat_productosServicios c  
   On c.id = b.idProductoServicio  
 Where  
  a.idEstadoTicket = 3  
  And a.fechaAlta between @fechaIni and @fechaFin   
  And a.idEntidad = @idEntidad
 Group By  
  c.descripcion  
 Order by  
  UnidadesVendidas desc  
 --  
 -- Top 10 menos vendido  
 --  
 Select  
 top 10  
  c.descripcion,  
  sum(b.cantidad) as UnidadesVendidas  
 From   
  proc_entradasSalidas a  
  join proc_entradasSalidasDetalles b  
   On a.folioEntradaSalida = b.folioEntradaSalida  
   And a.idEntidad = b.idEntidad  
  join cat_productosServicios c  
   On c.id = b.idProductoServicio  
 Where  
  a.idEstadoTicket = 3  
  And a.fechaAlta between @fechaIni and @fechaFin   
  And a.idEntidad= @idEntidad
 Group By  
  c.descripcion  
 Order by  
  UnidadesVendidas asc  
 --  
 -- Total por categoria  
 --  
 Select  
  d.descripcion AS categoria,  
  Sum(b.cantidad) as total  
 From   
  proc_entradasSalidas a  
  join proc_entradasSalidasDetalles b  
   On a.folioEntradaSalida = b.folioEntradaSalida  
   And a.idEntidad = b.idEntidad  
  join cat_productosServicios c  
   On c.id = b.idProductoServicio  
  join  cat_tiposProductosServicios d  
   On c.idTipoProductoServicio = d.id  
   and c.idEntidad = d.idEntidad  
 Where  
  a.idEstadoTicket = 3  
  And a.fechaAlta between @fechaIni and @fechaFin  
  And a.idEntidad = @idEntidad
 Group by d.descripcion   
 Order by total desc  
    
 --    
-- Rentabilidad del producto    
--    
;WITH PreciosProducto AS
(
    SELECT
        idEntidad,
        idProductoServicio,
        precioPrimera,
        MAX(Costo) AS Costo
    FROM cat_precios
    WHERE idEntidad = @idEntidad
    GROUP BY
        idEntidad,
        idProductoServicio,
        precioPrimera
),
RentabilidadProducto AS
(
    SELECT
        c.id AS idProductoServicio,
        c.descripcion AS producto,

        SUM(b.cantidad) AS unidadesVendidas,
      SUM(b.cantidad * b.precioFinal) AS ventaTotal,
        SUM(b.cantidad * e.Costo) AS costoTotal,
        SUM((b.cantidad * b.precioFinal) - (b.cantidad * e.Costo)) AS utilidadTotal
    FROM proc_entradasSalidas a
    JOIN proc_entradasSalidasDetalles b
        ON a.folioEntradaSalida = b.folioEntradaSalida
       AND a.idEntidad = b.idEntidad

    JOIN cat_productosServicios c
        ON c.id = b.idProductoServicio
       AND c.idEntidad = b.idEntidad

    JOIN PreciosProducto e
        ON e.idProductoServicio = b.idProductoServicio
       AND e.idEntidad = b.idEntidad
       AND e.precioPrimera = b.precio

    WHERE a.idEstadoTicket = 3
      AND a.fechaAlta BETWEEN @fechaIni AND @fechaFin
      AND a.idEntidad = @idEntidad

    GROUP BY
        c.id,
        c.descripcion
)
SELECT
    idProductoServicio,
    producto,

    CAST(unidadesVendidas AS decimal(12,2)) AS unidadesVendidas,
    '$'+Cast(CAST(ventaTotal AS decimal(12,2)) As varchar(25)) AS pagoTotal, -- Aqui debe de ser ventaTotal pero para no romper front se deja asi
    CAST(costoTotal AS decimal(12,2)) AS costoTotal,
    CAST(utilidadTotal AS decimal(12,2)) AS utilidadTotal,

    CAST(
        ROUND(
            utilidadTotal / NULLIF(ventaTotal, 0) * 100.0,
        2)
    AS decimal(12,2)) AS Margen,

    CAST(
        ROUND(
            utilidadTotal / NULLIF(costoTotal, 0) * 100.0,
        2)
    AS decimal(12,2)) AS Rentabilidad

FROM RentabilidadProducto
ORDER BY Margen DESC;
  
  
END 
