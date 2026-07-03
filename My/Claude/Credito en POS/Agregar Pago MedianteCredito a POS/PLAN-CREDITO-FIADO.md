# Plan de Integración: Crédito / Fiado en POS

## 0. Decisiones ya tomadas (base del diseño)

| Decisión | Resolución |
|---|---|
| Alcance del saldo/límite de crédito | **Consolidado por Entidad** (idEntidad). Un cliente tiene un solo saldo y un solo límite, sin importar en qué sucursal compró. |
| Modelo de recargo por venta a crédito | **Configurable en dos dimensiones**: tipo de valor (`Fijo` ó `Porcentaje`) × nivel de aplicación (`Por producto unitario` ó `Sobre el total del carrito`). Una sola combinación activa a la vez (ej. "Porcentaje sobre carrito" o "Fijo por producto"), pero el usuario puede cambiarla cuando quiera. |
| Interés moratorio por atraso | **No en MVP.** El diseño de tablas deja espacio para agregarlo después (catálogo de tipos de movimiento abierto) sin romper nada. |
| Autorización | **Cualquier cajero** puede vender a crédito mientras el cliente tenga saldo disponible. Modificar el **límite máximo** o **condonar/ajustar saldo** requiere rol superior (gerente/admin), validado por permisos existentes (`permission.service.ts`). |

Estas decisiones determinan el esqueleto de tablas de la Fase SQL (sección 6).

---

## 1. Objetivo

Integrar "crédito/fiado" como una forma de pago más dentro del POS, ligada siempre a un cliente, con:
- Límite de crédito máximo configurable por cliente.
- Recargo configurable sobre el precio cuando se vende a crédito.
- Alta rápida de cliente ("express") sin salir del flujo de cobro.
- Abonos y liquidaciones de saldo.
- Historial de movimientos por cliente.
- Un módulo de seguimiento/cobranza a nivel negocio (dashboard, cartera vencida, recomendaciones de cobro).

Este módulo debe sentirse como una extensión natural del POS actual (mismos patrones de `AlertService`, `LoadingService`, componentes standalone, Tailwind, `idSucursal` para trazabilidad de dónde se originó cada movimiento aunque el saldo sea global).

---

## 2. Entidades de negocio (vista conceptual, antes de nombrar tablas)

1. **Cliente con crédito habilitado** — extensión del cliente actual (`Profile/insert-cliente`), no una entidad nueva de persona. Se le agrega: `creditoHabilitado`, `limiteCredito`, `saldoActual` (derivado o cacheado), `fechaUltimoMovimiento`.
2. **Configuración de recargo por crédito** — un registro activo por Entidad: `tipoRecargo` (Fijo | Porcentaje), `valor`, vigente desde qué fecha. Se versiona (no se borra, se desactiva y se crea uno nuevo) para no romper el histórico de ventas ya hechas con la regla anterior.
3. **Movimiento de crédito** — el corazón del módulo. Cada evento que afecta el saldo de un cliente:
   - `Cargo` (venta a crédito) → aumenta saldo.
   - `Abono` (pago parcial) → disminuye saldo.
   - `Liquidación` (pago total del saldo pendiente) → disminuye saldo a 0.
   - `Ajuste` (condonación / corrección manual, requiere rol superior) → aumenta o disminuye, con motivo obligatorio.
   - (Futuro) `Interés moratorio`.
4. **Venta a crédito** — la venta normal (`InsertSale`) con un `idFormaPago` = Crédito, que además genera automáticamente un Movimiento de tipo `Cargo` ligado al `folioVenta`.
5. **Pago/Abono de crédito** — no es una venta, es un movimiento independiente que puede registrarse desde POS o desde el módulo de Créditos, con su propia forma de pago (efectivo, tarjeta, transferencia — reutiliza el catálogo `PaymentMethods` existente).

---

## 3. Reglas de negocio clave

### 3.1 Elegibilidad y límite
- Solo clientes con `creditoHabilitado = true` aparecen como opción de crédito en el POS.
- `saldoDisponible = limiteCredito - saldoActual`. Si el total del carrito (ya con recargo aplicado) > `saldoDisponible`, el POS bloquea el cobro a crédito y muestra el faltante ("Le faltan $X de límite disponible").
- No hay aprobación intermedia: si alcanza el límite, se cobra; si no, se bloquea (según tu decisión de autorización).

### 3.2 Recargo por crédito
- Se calcula **al momento de seleccionar "Crédito" como forma de pago**, no antes. El carrito muestra precio normal; al cambiar a crédito, se recalculan los totales con el recargo vigente y se muestra claramente "Precio a crédito" vs. "Precio de contado" para transparencia con el cliente.
- La regla activa combina **tipo de valor** (`Fijo` o `Porcentaje`) con **nivel de aplicación** (`Por producto` o `Sobre carrito`):
  - `Fijo` + `Por producto`: se suma el monto configurado por cada unidad vendida (por pieza, no por línea, para que escale con la cantidad).
  - `Porcentaje` + `Por producto`: cada unidad sube ese % sobre su propio precio (útil si quieres que productos caros absorban más recargo que los baratos).
  - `Fijo` + `Sobre carrito`: se suma un monto único al total, sin importar cuántos productos lleve.
  - `Porcentaje` + `Sobre carrito`: se aplica el % sobre el total del carrito ya con descuentos aplicados (definir si es antes o después de otros descuentos existentes — recomendación: después, para no apilar sobre precios ya promocionales de forma confusa).
- El ticket/comprobante debe indicar que el precio incluye recargo por crédito, para evitar reclamos.

### 3.3 Cliente Express desde POS
- Modal ligero con los campos mínimos indispensables para poder facturarle a crédito: nombre, apellido paterno, teléfono, y opcionalmente correo. **No** pide dirección/CP/colonia (a diferencia del alta completa en Personas).
- Al guardar, automáticamente:
  - Se crea como Persona con `idTipoPersona = Cliente`.
  - Se marca `creditoHabilitado = true` con un `limiteCredito` por defecto configurable (ej. $500), que el negocio puede definir como parámetro global.
  - Regresa al carrito con el cliente ya seleccionado, sin recargar pantalla.
- Debe quedar disponible después un botón "Completar datos del cliente" que lo mande al alta completa de Personas sin perder lo ya capturado.

### 3.4 Abonos y liquidación
- Un abono puede registrarse:
  - Desde POS, como un "cobro rápido de crédito" independiente de una venta (útil cuando el cliente solo viene a pagar, no a comprar).
  - Desde el módulo de Créditos, en la ficha del cliente.
- Un abono siempre requiere: cliente, monto, forma de pago (reutiliza catálogo existente), referencia si no es efectivo (mismo patrón que ya usan en pagos de citas).
- "Liquidar" es un atajo de UI que precarga el monto = saldo actual exacto.
- Igual que el flujo de citas, no permitir capturar un abono mayor al saldo pendiente.

### 3.5 Ventas a crédito y cancelaciones/devoluciones
- Si se cancela o hace devolución de una venta que fue a crédito, el sistema debe generar automáticamente un movimiento de reversa (`Ajuste` o un tipo `Reversa de cargo`) que reduzca el saldo del cliente correspondiente. **Esto hay que resolverlo en la Fase SQL** porque afecta la integridad del saldo — no puede quedar como ajuste manual porque el cajero se olvidaría.

---

## 4. Pantallas necesarias

### 4.1 Dentro del POS (flujo de cobro existente)
1. **Selector de forma de pago**: agregar "Crédito" junto a Efectivo/Tarjeta (mismo componente de selección que ya tienen).
2. **Selector/buscador de cliente para crédito**: aparece solo cuando se elige "Crédito". Busca por nombre/teléfono sobre clientes con crédito habilitado. Si no existe, botón "Cliente nuevo (express)".
3. **Modal de alta rápida de cliente (express)** — descrito en 3.3.
4. **Resumen de crédito antes de confirmar**: muestra límite, saldo actual, saldo disponible, total de la venta con recargo, saldo que quedará después de la venta. Esto evita sorpresas al cliente y al cajero.
5. **Modal de cobro rápido de abono** (cliente solo viene a pagar, sin carrito de productos) — accesible desde el mismo módulo de ventas o desde un botón "Cobrar crédito" en el sidebar.

### 4.2 Ficha de Cliente (dentro de Personas o dentro de Créditos — ver 4.4)
6. **Pestaña/sección "Crédito"** en la ficha del cliente: límite actual, saldo actual, estado (Al día / Vencido / Bloqueado manualmente), botón para editar límite (rol superior), botón para dar de alta/baja el crédito habilitado.
7. **Historial de movimientos del cliente**: tabla filtrable por rango de fecha y tipo de movimiento (Cargo/Abono/Liquidación/Ajuste), con totales del periodo. Reutiliza el patrón de `ngx-pagination` que ya usan en otras listas.

### 4.3 Configuración (dentro de un panel de administración/settings, no en POS)
8. **Configuración de recargo por crédito**: pantalla simple para elegir tipo (Fijo/Porcentaje) y valor, con vista previa de cómo afecta a un ticket ejemplo antes de guardar. Guarda histórico de versiones (no editable retroactivamente).
9. **Límite de crédito por defecto para clientes express**: parámetro simple, mismo panel.

### 4.4 Módulo nuevo: "Créditos" (nivel negocio, fuera del flujo de cobro)
Esto sí conviene que sea un módulo independiente en el sidebar (no meterlo dentro de POS ni dentro de Personas), porque su usuario típico es el dueño/gerente revisando cartera, no el cajero cobrando.

10. **Dashboard de Créditos**:
    - Total en cartera (suma de saldos activos).
    - Clientes con mayor rezago (días de atraso, si se define una fecha de vencimiento por cargo — ver nota abajo).
    - Clientes puntuales / mejores pagadores.
    - Créditos otorgados vs. cobrados en un rango de fechas (gráfica, usando Chart.js como el resto del sistema).
    - "Recomendación de cobro": lista priorizada de a quién y cuánto cobrar (por antigüedad de saldo y monto — puede iniciar como una regla simple: ordenar por días sin abono × saldo, sin IA todavía).
11. **Listado general de clientes con crédito**: tabla con nombre, límite, saldo, % de uso del límite, último movimiento, estado. Accesos directos a "Registrar abono" y "Ver historial" por fila.
12. **Historial global de movimientos** (todas las cuentas, no una sola): para auditoría, exportable, filtrable por sucursal de origen, cajero, tipo de movimiento y rango de fecha.
13. **Pantalla de ajustes manuales** (rol superior): condonar/corregir saldo con motivo obligatorio — queda registrado en el historial igual que cualquier movimiento, pero con marca visible de "ajuste manual" y el usuario que lo hizo.

**Nota importante que falta resolver:** para poder calcular "rezago" y dar de alta un dashboard de cobranza útil, necesitas una **fecha de vencimiento por cargo** (ej. "a 15 días" o "fin de quincena"), no solo un saldo acumulado sin fecha. Sin esto, "clientes con resago mayor" no se puede calcular de forma objetiva. Sugerencia: al configurar el recargo por crédito, agregar también "días de vencimiento por defecto" (ej. 15 días desde la venta), aplicado a cada Cargo individual. Esto es una pieza que faltaba en tu planteamiento original y hay que decidirla antes de la Fase SQL.

---

## 5. Cosas que faltaba considerar (para resolver antes o durante SQL)

1. **Fecha de vencimiento por cargo** (mencionado arriba) — sin ella no hay antigüedad de saldos real.
2. **Reversa de saldo en cancelaciones/devoluciones** (3.5) — debe ser automática, no manual.
3. **IVA/impuestos sobre el recargo** — ¿el recargo por crédito lleva IVA igual que el producto, o es un cargo aparte sin impuesto? Afecta el cálculo del ticket fiscal.
4. **Bloqueo de nuevos créditos si hay atraso**, aunque tenga saldo disponible dentro del límite (ej. cliente con un cargo vencido hace 60 días no debería poder seguir acumulando). Es una regla de negocio adicional al simple chequeo de límite — decidir si aplica desde MVP o fase 2.
5. **Notificaciones/recordatorios de cobro** (WhatsApp/SMS/correo) — mencionaste "cuánto y cuándo me recomienda cobrar"; el dashboard puede sugerirlo, pero el envío real de recordatorios es una integración aparte (fase 3, no bloquea el MVP).
6. **Impresión de ticket a crédito**: debe mostrar saldo anterior, cargo de hoy, saldo nuevo, y quizás fecha límite de pago — información que el cliente se lleva físicamente.
7. **Auditoría de cambios de límite**: quién subió el límite de un cliente y cuándo, separado del historial de movimientos de saldo (es un log de configuración, no un movimiento de dinero).
8. **Multi-forma de pago en un abono**: ¿se permite abonar con efectivo + tarjeta combinados, igual que ya hacen en una venta normal? Recomendación: sí, reutilizar el mismo componente de `payments[]` que ya existe en `sales.component.ts`.
9. **Reporte fiscal/contable**: si más adelante facturan, un cargo a crédito y su abono posterior son dos eventos distintos en el tiempo — hay que tener claro cuándo se reconoce el ingreso (esto es más un tema contable a validar con quien lleve la contabilidad del negocio, pero vale la pena anotarlo ahora).
10. **Clientes duplicados desde alta express**: si el cajero da de alta un cliente "express" con el mismo teléfono que ya existe, debe advertir y ofrecer usar el existente en vez de crear duplicado.

---

## 6. Impacto en Fase SQL (solo como guía, no como script final)

Grupos de tablas a diseñar (nombres tentativos, se ajustan en la sesión de SQL):

- **Extensión de Cliente**: columnas de crédito sobre la tabla de clientes existente (`creditoHabilitado`, `limiteCredito`, `saldoActual` cacheado — recalculable desde movimientos para evitar drift, o recalculado por trigger/SP).
- **ConfiguracionRecargoCredito**: histórico versionado por Entidad (tipoValor [Fijo|Porcentaje], nivelAplicacion [Producto|Carrito], valor, diasVencimiento, vigenteDesde, vigenteHasta, activo).
- **MovimientoCredito**: idCliente, idEntidad, idSucursal (origen, para trazabilidad aunque el saldo sea global), tipoMovimiento (catálogo: Cargo/Abono/Liquidación/Ajuste/[futuro Interés]), monto, folioVentaRelacionado (nullable), fechaVencimiento (solo aplica a Cargo), idFormaPago (solo aplica a Abono/Liquidación), referencia, motivo (solo Ajuste), idUsuarioRegistro, fechaRegistro.
- **Catálogo TipoMovimientoCredito**: para no hardcodear strings, igual que ya hacen con otros catálogos (EstatusAgenda, TiposBloqueo, etc.).
- Reutilizar el catálogo `PaymentMethods` existente en vez de crear uno nuevo para formas de pago de abonos.
- Reutilizar tabla de permisos/roles existente para el permiso "Modificar límite de crédito" / "Realizar ajuste de saldo".

---

## 7. Arquitectura Angular propuesta (siguiendo tu patrón actual)

### Services (siguiendo el estilo de `agenda.service.ts` / `horario.service.ts`)
- `core/services/credito.service.ts` → GetClientesCredito, GetMovimientosCredito, RegistrarCargo (uso interno, normalmente automático desde la venta), RegistrarAbono, RegistrarLiquidacion, RegistrarAjuste, GetDashboardCredito.
- `core/services/credito-config.service.ts` → GetConfiguracionRecargo, GuardarConfiguracionRecargo, GetLimiteDefaultExpress.
- Reutilizar `PersonService` para el alta express (mismo `InsertCustomer`, con los campos mínimos y `creditoHabilitado` en el payload).

### Componentes
```
features/sales/components/sales/           (existente, se extiende)
 ├─ credito-cliente-selector/        (buscador + botón alta express, modal)
 ├─ credito-cliente-express-modal/   (alta rápida)
 └─ credito-resumen-cobro/           (resumen antes de confirmar venta a crédito)

features/credito/                    (módulo nuevo, como agenda/horarios)
 ├─ credito.module.ts / credito-routing.module.ts
 ├─ components/
 │   ├─ credito-dashboard/
 │   ├─ credito-listado-clientes/
 │   ├─ credito-detalle-cliente/       (límite, saldo, historial, ajustar)
 │   ├─ credito-registrar-abono-modal/
 │   ├─ credito-historial-global/
 │   └─ credito-config/                (recargo + límite default express)
```

### Sidebar
- Nueva entrada "Créditos" (mismo patrón que `expandAgenda`), visible según permiso.

### Puntos de integración con código existente
- `sales.component.ts`: agregar "Crédito" a `PaymentMethods` (si viene del catálogo del backend, solo hay que dar de alta el registro; si el flujo de crédito requiere UI distinta —selector de cliente, resumen—, interceptar `selectPayment()` cuando `paymentMethod.descripcion === 'Crédito'` para desviar al sub-flujo antes de permitir confirmar venta.
- `CSalePay` (armado en `sales.component.ts:777`): agregar el idmethod de crédito y el `idCliente` asociado al payload de venta.
- `sucursalContext.service.ts`: se sigue usando para registrar `idSucursal` de origen en cada `MovimientoCredito`, aunque el saldo sea consolidado por entidad.
- Reutilizar el patrón de `payments[]` + `pagosCita[]` ya existente en `sales.component.ts` para armar el componente de abono con múltiples formas de pago.

---

## 8. Fases de implementación sugeridas

**Fase 1 — MVP funcional**
- Extensión de cliente con crédito habilitado + límite.
- Configuración de recargo (fijo o %) y días de vencimiento por defecto.
- Alta express desde POS.
- Venta a crédito con recargo aplicado y bloqueo por límite.
- Registro de abonos y liquidación (desde ficha de cliente, sin dashboard todavía).
- Historial de movimientos por cliente.
- Reversa automática de saldo en cancelación de venta a crédito.

**Fase 2 — Seguimiento y control**
- Módulo Créditos completo: dashboard, listado general, historial global.
- Antigüedad de saldos / cartera vencida usando fecha de vencimiento por cargo.
- Ajustes manuales con permisos y auditoría.
- Reporte exportable de créditos por rango de fechas.

**Fase 3 — Cobranza proactiva**
- Recomendaciones de cobro más elaboradas (prioridad por monto × días de atraso, o modelo simple de scoring).
- Recordatorios automáticos (WhatsApp/SMS/correo).
- Bloqueo automático por atraso (no solo por límite).
- Interés moratorio (si se decide activarlo).

---

## 9. Siguiente paso

Con este plan como referencia, la sesión de SQL debe salir con al menos:
1. Definición final de columnas en Cliente para crédito.
2. Tabla `ConfiguracionRecargoCredito` versionada.
3. Tabla `MovimientoCredito` + catálogo `TipoMovimientoCredito`.
4. SPs: `InsertCargoCredito` (se invoca junto con `InsertSale`, dentro de la misma transacción para no dejar venta sin cargo o viceversa), `InsertAbonoCredito`, `InsertAjusteCredito`, `GetSaldoCliente`, `GetDashboardCredito`, `GetHistorialCredito`.
5. Definir explícitamente el punto 5.2 (reversa automática en cancelaciones) como parte del SP de cancelación de venta existente, no como proceso aparte.
