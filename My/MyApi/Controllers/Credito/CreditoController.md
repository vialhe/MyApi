# API Crédito — Documentación para integración con Front

Base URL: `/Credito` (controller `CreditoController`, ruta `[controller]`)
Todos los endpoints son **POST**, reciben el body como **JSON** (`Content-Type: application/json`) y ninguno usa parámetros de ruta ni query string — todo va en el body.

## Formato de respuesta (general)

Todos los endpoints regresan **HTTP 200** con un JSON tipo:

**Éxito:**
```json
{
  "Code": true,
  "Mensaje": "Success",
  "Data": [ { ... }, { ... } ]
}
```
`Data` es un arreglo de filas (diccionario columna → valor). Los valores `NULL` de SQL se omiten de cada objeto (no aparece la key). En `get-dashboard` la key no es `Data` sino el nombre de cada tabla (ver ese endpoint).

**Error de negocio / validación del Stored Procedure** (excepción capturada, sigue siendo HTTP 200):
```json
{
  "Code": false,
  "Mensaje": "Ex: <mensaje de la validación o del RAISERROR>"
}
```
Aquí **no** viene la key `Data`. El front debe checar `Code` antes de leer `Data`.

**Body nulo o vacío** (falla la validación `if (data == null)` del controller): **HTTP 400 BadRequest** con texto plano, no el JSON envelope de arriba. Ej: `"Los datos no pueden ser nulos."`, `"El carrito no puede ser nulo o vacio."`, `"Debe capturar al menos una forma de pago."`.

Campos típicos presentes en casi todos los requests: `idEntidad` (empresa/entidad), `idSucursal` (sucursal donde ocurre la operación), `idUsuarioAlta` (usuario que ejecuta la acción, para auditoría).

---

## A) Configuración

### `POST /Credito/configuracion-get`
Obtiene la configuración de crédito **vigente** (una sola activa por entidad) de una Entidad.

**Request**
```json
{ "idEntidad": 1 }
```

**Respuesta `Data[]`** (0 o 1 fila; 0 filas si la Entidad nunca configuró crédito):
| Campo | Tipo | Notas |
|---|---|---|
| id | int | |
| tipoValorRecargo | string | `"Fijo"` \| `"Porcentaje"` |
| nivelAplicacion | string | `"Producto"` \| `"Carrito"` |
| valorRecargo | decimal | |
| diasVencimientoCargo | int | |
| limiteCreditoDefaultExpress | decimal | límite que se usa si al habilitar crédito a un cliente no se manda `limiteCredito` |
| vigenteDesde | datetime | |
| vigenteHasta | datetime? | siempre `null` en la fila activa |
| comentarios | string? | |
| activo | bool | |
| idEntidad | int | |

### `POST /Credito/configuracion-guardar`
Crea una nueva configuración (versiona: cierra la anterior con `vigenteHasta` y da de alta la nueva). No hay "editar in place".

**Request**
```json
{
  "idEntidad": 1,
  "tipoValorRecargo": "Porcentaje",
  "nivelAplicacion": "Carrito",
  "valorRecargo": 5.0,
  "diasVencimientoCargo": 30,
  "limiteCreditoDefaultExpress": 2000.00,
  "idUsuarioAlta": 10
}
```
Validaciones del SP (si fallan → `Code:false`): `tipoValorRecargo` solo `Fijo`/`Porcentaje`, `nivelAplicacion` solo `Producto`/`Carrito`, y `valorRecargo`, `diasVencimientoCargo`, `limiteCreditoDefaultExpress` no pueden ser negativos.

**Respuesta `Data[]`**: la fila recién creada, mismas columnas que `configuracion-get`.

---

## B) Cliente / Límite

### `POST /Credito/cliente-habilitar`
Habilita o deshabilita el crédito de un cliente y opcionalmente fija su límite.

**Request**
```json
{
  "idPersona": 123,
  "creditoHabilitado": true,
  "limiteCredito": 3000.00,
  "idEntidad": 1,
  "idUsuarioAlta": 10
}
```
- `limiteCredito` es opcional (`null`/omitirlo). Si `creditoHabilitado=true` y no se manda, se usa `limiteCreditoDefaultExpress` de la configuración activa (falla si no hay configuración).
- Deshabilitar (`creditoHabilitado:false`) **no** valida que el saldo esté en cero — solo bloquea nuevos cargos a futuro; el cliente sigue pudiendo abonar.

**Respuesta `Data[]`** (1 fila):
| Campo | Tipo |
|---|---|
| id | int |
| creditoHabilitado | bool |
| limiteCredito | decimal |
| saldoActual | decimal |

### `POST /Credito/limite-actualizar`
Cambia el límite de crédito de un cliente ya existente. Registra el cambio en un historial de auditoría (no se expone por API).

**Request**
```json
{
  "idPersona": 123,
  "limiteNuevo": 5000.00,
  "motivo": "Cliente con buen historial de pago",
  "idEntidad": 1,
  "idSucursal": 1,
  "idUsuarioAlta": 10
}
```
`motivo` es **obligatorio** (no vacío) y `limiteNuevo` no puede ser negativo.

**Respuesta `Data[]`** (1 fila): `id`, `limiteCredito`, `saldoActual`.

---

## C) Núcleo transaccional

### `POST /Credito/calcular-recargo`
Solo **calcula**, no inserta nada. Se usa para mostrarle al cajero el total con recargo antes de confirmar la venta a crédito.

**Request**
```json
{
  "idEntidad": 1,
  "carrito": [
    { "idProductoServicio": 55, "cantidad": 2, "precio": 100.00 },
    { "idProductoServicio": 60, "cantidad": 1, "precio": 250.00 }
  ]
}
```
`carrito` no puede ser nulo ni vacío (400 si lo es).

**Respuesta `Data[]`** (1 fila; 0 filas si la Entidad no tiene configuración activa):
| Campo | Tipo | Descripción |
|---|---|---|
| totalSinRecargo | decimal | `sum(cantidad*precio)` |
| montoRecargo | decimal | calculado según `tipoValorRecargo`/`nivelAplicacion` de la configuración |
| totalConRecargo | decimal | `totalSinRecargo + montoRecargo` |

### `POST /Credito/insert-cargo`
Inserta un cargo de crédito ligado a una venta. **Nota importante:** hoy es un endpoint independiente; según comentario en el propio código, la orquestación automática con el flujo de venta (`SaleController.SalePut`) todavía está pendiente de definir — por ahora el front (o quien orqueste) debe llamarlo explícitamente después de registrar el pago tipo Crédito en la venta.

**Request**
```json
{
  "folioEntradaSalida": 4521,
  "idPersona": 123,
  "montoConRecargo": 462.00,
  "idEntidad": 1,
  "idSucursal": 1,
  "idUsuarioAlta": 10
}
```
Reglas del SP (si fallan → `Code:false` con el motivo): `montoConRecargo` > 0; no debe existir ya un cargo para ese `folioEntradaSalida`; el cliente debe existir y tener `creditoHabilitado=1`; `montoConRecargo` no puede exceder el saldo disponible (`limiteCredito - saldoActual`); debe existir configuración activa para la Entidad.

**Respuesta `Data[]`** (1 fila, el movimiento insertado — mismas columnas en todos los endpoints que tocan el ledger, ver tabla común abajo).

### `POST /Credito/insert-abono`
Registra un pago (abono parcial o liquidación total), puede ser con varias formas de pago combinadas.

**Request**
```json
{
  "idPersona": 123,
  "pagos": [
    { "idTipoPago": 1, "montoPago": 200.00, "numeroAutorizacion": "" },
    { "idTipoPago": 3, "montoPago": 100.00, "numeroAutorizacion": "AUTH-8891" }
  ],
  "esLiquidacion": false,
  "idEntidad": 1,
  "idSucursal": 1,
  "idUsuarioAlta": 10
}
```
`pagos` no puede ser nulo/vacío (400). Reglas del SP: cada `idTipoPago` debe existir para la Entidad; la suma de `montoPago` debe ser > 0; si `esLiquidacion:true` la suma debe ser **exactamente igual** al saldo actual del cliente; en cualquier caso la suma no puede superar el saldo actual.

**Respuesta `Data[]`** (1 fila, el movimiento de Abono/Liquidación insertado). El detalle de formas de pago se guarda internamente pero **no** se regresa en la respuesta.

### `POST /Credito/insert-ajuste`
Ajuste manual del saldo (condonación o corrección), sin pasar por venta ni pago.

**Request**
```json
{
  "idPersona": 123,
  "monto": -150.00,
  "motivo": "Condonacion por error de cobro",
  "idEntidad": 1,
  "idSucursal": 1,
  "idUsuarioAlta": 10
}
```
`monto` positivo aumenta el saldo (como un cargo), negativo lo disminuye (como un descuento/condonación); no puede ser `0`. `motivo` es obligatorio. El ajuste no puede dejar el saldo en negativo.

**Respuesta `Data[]`** (1 fila, el movimiento de Ajuste insertado).

### `POST /Credito/reversa-cargo`
Reversa un cargo de crédito previamente insertado, por folio de venta.

**Request**
```json
{
  "folioEntradaSalida": 4521,
  "idEntidad": 1,
  "idSucursal": 1,
  "idUsuarioAlta": 10
}
```
Debe existir un Cargo previo con ese `folioEntradaSalida`; no se puede revertir dos veces el mismo cargo.

**Nota de flujo:** en operación normal, esta reversa se dispara **sola** desde el SP de inventario cuando se cancela un ticket (movimiento de inventario 1004) — este endpoint es solo la vía manual para casos donde se necesite forzarla desde el API.

**Respuesta `Data[]`** (1 fila, el movimiento REVERSA_CARGO insertado).

---

### Columnas comunes del "movimiento" (`insert-cargo`, `insert-abono`, `insert-ajuste`, `reversa-cargo`)

Estos 4 endpoints regresan la misma fila del ledger de crédito:

| Campo | Tipo | Notas |
|---|---|---|
| folioMovimientoCredito | int | folio consecutivo por Entidad+Sucursal |
| idPersona | int | |
| idTipoMovimientoCredito | int | id interno del tipo (CARGO/ABONO/LIQUIDACION/AJUSTE/REVERSA_CARGO) |
| monto | decimal | siempre en positivo, sin importar si aumenta o disminuye saldo |
| saldoAnterior | decimal | |
| saldoNuevo | decimal | |
| folioEntradaSalidaRelacionado | int? | solo Cargo/Reversa |
| fechaVencimiento | datetime? | solo Cargo |
| motivo | string? | solo Ajuste/Límite |
| folioMovimientoCreditoOrigen | int? | solo Reversa (apunta al Cargo revertido) |
| comentarios | string? | |
| activo | bool | |
| idEntidad | int | |
| idSucursal | int | |
| fechaAlta | datetime | |
| idUsuarioAlta | int | |

---

## D) Consulta / Lectura

### `POST /Credito/get-saldo-cliente`
**Request**
```json
{ "idPersona": 123, "idEntidad": 1 }
```
**Caso especial:** si el cliente no existe, la respuesta es `{ "Code": false, "Mensaje": "Cliente no encontrado" }` (sin `Data`), con HTTP 200 — no es un 404.

**Respuesta `Data[]`** (1 fila si existe):
| Campo | Tipo |
|---|---|
| idPersona | int |
| nombre, apellidoPaterno, apellidoMaterno | string |
| creditoHabilitado | bool |
| limiteCredito | decimal |
| saldoActual | decimal |
| saldoDisponible | decimal | `limiteCredito - saldoActual` |
| fechaUltimoMovimientoCredito | datetime? |

### `POST /Credito/get-historial-cliente`
**Request**
```json
{
  "idPersona": 123,
  "idEntidad": 1,
  "fechaInicio": "2026-01-01",
  "fechaFin": "2026-07-07",
  "clave": null,
  "pagina": 1,
  "tamanoPagina": 50
}
```
Todos excepto `idPersona`/`idEntidad` son opcionales. `clave` filtra por tipo de movimiento: `"CARGO"`, `"ABONO"`, `"LIQUIDACION"`, `"AJUSTE"`, `"REVERSA_CARGO"`. Paginado con `pagina`/`tamanoPagina` (default 1/50), ordenado por fecha descendente.

**Respuesta `Data[]`**:
| Campo | Tipo |
|---|---|
| folioMovimientoCredito | int |
| idSucursal | int |
| tipoMovimiento | string | clave (`CARGO`, `ABONO`, etc.) |
| tipoMovimientoDescripcion | string |
| monto, saldoAnterior, saldoNuevo | decimal |
| folioEntradaSalidaRelacionado | int? |
| fechaVencimiento | datetime? |
| motivo | string? |
| folioMovimientoCreditoOrigen | int? |
| fechaAlta | datetime |
| idUsuarioAlta | int |

### `POST /Credito/get-historial-global`
Igual que el anterior pero sin filtrar por cliente — para una pantalla de "todos los movimientos de crédito de la Entidad".

**Request**
```json
{
  "idEntidad": 1,
  "idSucursal": null,
  "idUsuarioAlta": null,
  "clave": null,
  "fechaInicio": null,
  "fechaFin": null,
  "pagina": 1,
  "tamanoPagina": 50
}
```
Todos opcionales excepto `idEntidad`.

**Respuesta `Data[]`**: mismas columnas que `get-historial-cliente` más `idPersona`, `nombre`, `apellidoPaterno`, `apellidoMaterno`.

### `POST /Credito/get-listado-clientes`
Pantalla de listado de clientes con crédito (para catálogo/búsqueda).

**Request**
```json
{ "idEntidad": 1 }
```
Incluye clientes con `creditoHabilitado=1` **o** con `saldoActual > 0` (aunque ya se les haya deshabilitado, para que no se "pierdan" de la vista mientras deban algo).

**Respuesta `Data[]`**:
| Campo | Tipo | Notas |
|---|---|---|
| idPersona | int |
| nombre, apellidoPaterno, apellidoMaterno, numeroTelefono | string |
| limiteCredito | decimal |
| saldoActual | decimal |
| porcentajeUso | decimal | `saldoActual / limiteCredito`, 0 a 1 |
| fechaUltimoMovimientoCredito | datetime? |
| estado | string | `"Deshabilitado"` \| `"Al dia"` \| `"Vencido"` |

### `POST /Credito/get-dashboard`
**Único endpoint que no regresa `Data`** — regresa 3 llaves nombradas por tabla:

**Request**
```json
{ "idEntidad": 1, "fechaInicio": "2026-07-01", "fechaFin": "2026-07-07" }
```

**Respuesta**
```json
{
  "Code": true,
  "Mensaje": "Success",
  "totalCartera": [ { "totalCartera": 125000.00 } ],
  "otorgadoVsCobrado": [
    { "tipoMovimiento": "CARGO", "total": 30000.00, "numMovimientos": 12 },
    { "tipoMovimiento": "ABONO", "total": 18000.00, "numMovimientos": 9 }
  ],
  "topRezago": [
    {
      "idPersona": 123, "nombre": "...", "apellidoPaterno": "...", "apellidoMaterno": "...",
      "numeroTelefono": "...", "saldoPendiente": 4500.00,
      "fechaVencimientoMasAntigua": "2026-05-10", "diasAtraso": 58, "prioridadCobro": 261000.00
    }
  ]
}
```
- `totalCartera`: 1 fila, suma global de `saldoActual` de todos los clientes con crédito de la Entidad (no depende del rango de fechas).
- `otorgadoVsCobrado`: una fila por tipo de movimiento (`CARGO`/`ABONO`/`LIQUIDACION`/`AJUSTE`/`REVERSA_CARGO`) que tuvo actividad **dentro** del rango `fechaInicio`–`fechaFin`. Si un tipo no tuvo movimientos en el rango, simplemente no aparece la fila.
- `topRezago`: hasta 50 clientes con cartera vencida (cargos con `fechaVencimiento` ya pasada y saldo pendiente > 0), ordenados por `prioridadCobro` (`saldoPendiente × diasAtraso`) descendente — no depende del rango de fechas, es "a hoy".

---

## Resumen rápido

| # | Endpoint | Método | Propósito |
|---|---|---|---|
| 1 | `configuracion-get` | POST | Leer configuración activa |
| 2 | `configuracion-guardar` | POST | Crear/versionar configuración |
| 3 | `cliente-habilitar` | POST | Habilitar/deshabilitar crédito |
| 4 | `limite-actualizar` | POST | Cambiar límite de un cliente |
| 5 | `calcular-recargo` | POST | Cotizar recargo de un carrito (sin insertar) |
| 6 | `insert-cargo` | POST | Registrar cargo por venta a crédito |
| 7 | `insert-abono` | POST | Registrar pago/liquidación |
| 8 | `insert-ajuste` | POST | Ajuste manual de saldo |
| 9 | `reversa-cargo` | POST | Revertir un cargo (cancelación manual) |
| 10 | `get-saldo-cliente` | POST | Saldo y disponible de un cliente |
| 11 | `get-historial-cliente` | POST | Movimientos de un cliente (paginado) |
| 12 | `get-historial-global` | POST | Movimientos de toda la Entidad (paginado) |
| 13 | `get-listado-clientes` | POST | Catálogo de clientes con crédito |
| 14 | `get-dashboard` | POST | KPIs: cartera total, otorgado vs cobrado, top rezago |
