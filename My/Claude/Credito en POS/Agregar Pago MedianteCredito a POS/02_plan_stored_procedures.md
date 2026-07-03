# Plan de Stored Procedures — Módulo de Crédito/Fiado en POS

Referencia: `01_create_tables_credito.sql` (ya ejecutado), `PLAN-CREDITO-FIADO.md`, `Estructuras Tabla.md`.

Todos los SP transaccionales siguen el patrón ya usado en el proyecto (`sp_ui_agendaReprogramacion`): `SET NOCOUNT ON`, `SET XACT_ABORT ON`, `BEGIN TRY / BEGIN TRAN ... COMMIT`, `BEGIN CATCH / ROLLBACK + RAISERROR`, validaciones explícitas con `RAISERROR` antes de tocar datos, y `WITH (UPDLOCK, HOLDLOCK)` al leer `cat_personas` para evitar condiciones de carrera cuando dos movimientos del mismo cliente llegan casi al mismo tiempo (ej. dos cajas cobrando al mismo cliente).

---

## A. Configuración

### 1. `sp_ui_creditoConfiguracionGet`
- **Tipo:** consulta.
- **Params:** `@idEntidad`.
- **Hace:** `SELECT` de la fila de `cat_configuracionCredito` con `vigenteHasta IS NULL` para esa Entidad.
- **Lo usan:** POS (para calcular recargo al seleccionar "Crédito"), pantalla de configuración (precargar valores actuales), alta express (límite default).

### 2. `sp_ui_creditoConfiguracionGuardar`
- **Tipo:** transaccional.
- **Params:** `@idEntidad, @tipoValorRecargo, @nivelAplicacion, @valorRecargo, @diasVencimientoCargo, @limiteCreditoDefaultExpress, @idUsuarioAlta`.
- **Hace:** valida los valores permitidos (mismos que los `CHECK` de la tabla); `UPDATE` de la fila activa actual (`vigenteHasta = fn_GetDateMX()`); `INSERT` de la fila nueva (`vigenteDesde = fn_GetDateMX()`, `vigenteHasta = NULL`). El índice único filtrado ya creado es la red de seguridad si algo se ejecuta dos veces en paralelo.

---

## B. Cliente / crédito habilitado / límite

### 3. `sp_ui_creditoClienteHabilitar`
- **Tipo:** transaccional.
- **Params:** `@idPersona, @creditoHabilitado (bit), @limiteCredito (nullable), @idUsuarioAlta`.
- **Hace:** activa/desactiva `creditoHabilitado`. Si es alta y no viene `@limiteCredito`, toma el `limiteCreditoDefaultExpress` de la configuración activa. Si se desactiva con `saldoActual > 0`, bloquea con `RAISERROR` (no se puede deshabilitar crédito con saldo pendiente) — **a confirmar**.

### 4. `sp_ui_creditoLimiteActualizar`
- **Tipo:** transaccional.
- **Params:** `@idPersona, @limiteNuevo, @motivo, @idEntidad, @idSucursal, @idUsuarioAlta`.
- **Hace:** rol superior ya validado en la API antes de llamar. Lee `limiteCredito` actual, `INSERT` en `proc_creditoLimiteHistorial` (anterior/nuevo/motivo), `UPDATE cat_personas.limiteCredito`.

**Nota:** el alta "express" del cliente (nombre, teléfono, `idTipoPersona = Cliente`) no necesita SP nuevo — se resuelve extendiendo el insert-cliente existente con los 2 campos de crédito, tal como propone el plan original (reutilizar `PersonService`/`insert-cliente`).

---

## C. Núcleo transaccional (los más delicados)

### 5. `fn_creditoCalcularRecargo` (función, no SP)
- **Params:** `@idEntidad`, tabla del carrito (TVP: producto, cantidad, precio).
- **Hace:** aplica la configuración activa (Fijo/Porcentaje × Producto/Carrito) y regresa el monto de recargo total + el total "a crédito" del carrito.
- **Lo usan:** POS (resumen antes de confirmar) y `sp_ui_creditoInsertCargo` (monto final a cargar).

### 6. `sp_ui_creditoInsertCargo`
- **Params:** `@folioEntradaSalida, @idPersona, @montoConRecargo, @idEntidad, @idSucursal, @idUsuarioAlta`.
- **Pasos:** (1) lee `saldoActual`/`limiteCredito`/`creditoHabilitado` del cliente con `UPDLOCK`; (2) valida habilitado; (3) valida `saldoActual + monto <= limiteCredito`, si no `RAISERROR` con el faltante; (4) `fechaVencimiento = fn_GetDateMX() + diasVencimientoCargo` de la config activa; (5) genera `folioMovimientoCredito` (MAX+1 por `idEntidad+idSucursal`, igual que folios de inventario); (6) `INSERT` en `proc_movimientosCredito` tipo `CARGO`; (7) `UPDATE cat_personas.saldoActual` y `fechaUltimoMovimientoCredito`.
- **Enganche con la venta (confirmado):** `sp_in_entradasSalidas`, `sp_in_entradasSalidasDetalles` y `sp_in_EntradasSalidaPago` se llaman por separado desde la API dentro de una sola transacción ADO.NET — no hay `EXEC` anidado entre ellos. `sp_ui_creditoInsertCargo` sigue el mismo patrón: la API lo llama como paso adicional, dentro de esa misma transacción, justo después de insertar en `proc_entradasSalidaPago` la fila con `idTipoPago` = Crédito. Ningún SP de venta existente se modifica.

### 7. `sp_ui_creditoInsertAbono`
- **Params:** `@idPersona, @pagos (TVP: idTipoPago, montoPago, numeroAutorizacion), @esLiquidacion (bit), @idEntidad, @idSucursal, @idUsuarioAlta`.
- **Pasos:** (1) lee `saldoActual` con `UPDLOCK`; (2) `monto = SUM(montoPago)` de la TVP; (3) si `@esLiquidacion = 1`, fuerza `monto = saldoActual` exacto (ignora lo capturado, o valida que coincida); (4) valida `monto <= saldoActual` (no se permite abonar de más, regla ya confirmada en el plan); (5) genera folio, `INSERT` en `proc_movimientosCredito` (tipo `ABONO` o `LIQUIDACION`); (6) `INSERT` de N filas en `proc_movimientosCreditoPago`; (7) `UPDATE saldoActual`.

### 8. `sp_ui_creditoInsertAjuste`
- **Params:** `@idPersona, @monto (+/-), @motivo (obligatorio), @idEntidad, @idSucursal, @idUsuarioAlta`.
- **Pasos:** rol superior validado en API antes de llamar. Lee saldo con `UPDLOCK`, valida que `saldoActual + monto` no quede negativo, `INSERT` tipo `AJUSTE`, `UPDATE saldoActual`.

### 9. `sp_ui_creditoReversaCargo`
- **Params:** `@folioEntradaSalida, @idEntidad, @idSucursal, @idUsuarioAlta` (sin monto — reversa siempre total; ver nota de alcance abajo).
- **Pasos:** (1) busca el `CARGO` original por `folioEntradaSalidaRelacionado` (`RAISERROR` si no existe o ya fue revertido); (2) `INSERT` tipo `REVERSA_CARGO` por el monto completo del Cargo, con `folioMovimientoCreditoOrigen` apuntando a él; (3) `UPDATE saldoActual` (resta) con `UPDLOCK`.
- **Alcance (confirmado):** no existe devolución parcial visible en el flujo actual — cancelar un ticket siempre marca `idEstadoTicket = 4` completo, sin monto ni producto específico. Por eso la reversa de crédito tampoco maneja montos parciales.
- **Enganche con la cancelación (confirmado):** se modifica `sp_in_movimentosInventarios`, dentro del bloque `IF(@idTipoMovimientoInventario = 1004)` que ya existe (justo después del `UPDATE proc_entradasSalidas SET idEstadoTicket = 4`). Se agrega:
  ```sql
  IF EXISTS (
      SELECT 1 FROM proc_movimientosCredito mc
      INNER JOIN cat_tipoMovimientoCredito tm ON tm.id = mc.idTipoMovimientoCredito AND tm.idEntidad = mc.idEntidad
      WHERE mc.folioEntradaSalidaRelacionado = @idDocumentoReferencia
        AND mc.idEntidad = @idEntidad
        AND tm.clave = 'CARGO'
  )
  BEGIN
      EXEC dbo.sp_ui_creditoReversaCargo
          @folioEntradaSalida = @idDocumentoReferencia,
          @idEntidad = @idEntidad,
          @idSucursal = @idSucursal,
          @idUsuarioAlta = @idUsuarioModifica;
  END
  ```
  Es aditivo: tickets pagados en efectivo/tarjeta no tienen fila `CARGO` relacionada, así que el `EXISTS` es falso y el comportamiento actual no cambia para ellos. La transacción ambiente que ya abre la API para este SP (evidenciada por el `ROLLBACK TRANSACTION` sin `BEGIN TRAN` propio en el `CATCH`) cubre también esta reversa: si falla, se revierte todo junto.

---

## D. Consulta / lectura

### 10. `sp_ui_creditoGetSaldoCliente`
`@idPersona` → `limiteCredito, saldoActual, saldoDisponible, creditoHabilitado, fechaUltimoMovimientoCredito`. Lo usa el POS antes de confirmar venta a crédito y la ficha de cliente.

### 11. `sp_ui_creditoGetHistorialCliente`
`@idPersona` + filtros (rango de fecha, tipo de movimiento) + paginación. Incluye `JOIN` a `proc_movimientosCreditoPago` cuando el movimiento es Abono/Liquidación.

### 12. `sp_ui_creditoGetHistorialGlobal`
Filtros por `idEntidad, idSucursal, idUsuarioAlta` (cajero), tipo, rango de fecha, paginación. Para auditoría/exportable.

### 13. `sp_ui_creditoGetListadoClientes`
`@idEntidad` → clientes con crédito habilitado: nombre, límite, saldo, `%uso = saldoActual/limiteCredito`, último movimiento, estado (Al día/Vencido, calculado con la regla FIFO).

### 14. `sp_ui_creditoGetDashboard`
`@idEntidad` + rango de fechas → total en cartera (`SUM saldoActual`), otorgado vs. cobrado en el rango (`SUM monto` por tipo), clientes con mayor rezago (aplica FIFO con funciones de ventana sobre `proc_movimientosCredito` para saber cuánto de cada Cargo sigue sin cubrir y hace cuántos días venció), recomendación de cobro (orden por días de atraso × saldo pendiente).

---

## Decisiones de integración confirmadas (2026-07-03)

1. **Cargo ↔ Venta:** orquestado por la API (mismo patrón que `sp_in_entradasSalidas` + `sp_in_entradasSalidasDetalles` + `sp_in_EntradasSalidaPago`, que ya se llaman por separado dentro de una transacción ADO.NET). No se modifica ningún SP de venta existente.
2. **Reversa ↔ Cancelación:** se modifica `sp_in_movimentosInventarios` (aditivo) para que, cuando `@idTipoMovimientoInventario = 1004` y exista un `CARGO` relacionado, dispare `EXEC sp_ui_creditoReversaCargo` automáticamente. Ver detalle en la sección del SP 9.
3. **Devoluciones parciales:** no existen en el flujo actual (`sp_in_movimentosInventarios` cancela el ticket completo, sin monto ni producto). `sp_ui_creditoReversaCargo` se diseña solo para reversa total.

## SPs existentes referenciados (no se tocan, salvo el punto 2 de arriba)

- `sp_in_entradasSalidas` — encabezado de venta.
- `sp_in_entradasSalidasDetalles` — detalle de productos.
- `sp_in_EntradasSalidaPago` — forma(s) de pago de la venta (aquí se inserta la fila con `idTipoPago` = Crédito).
- `sp_in_movimentosInventarios` — **sí se modifica** (aditivo) para disparar la reversa automática en cancelaciones (tipo 1004).
