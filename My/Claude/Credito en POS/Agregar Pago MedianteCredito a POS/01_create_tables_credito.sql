-- ============================================================================
-- MODULO: CREDITO / FIADO EN POS
-- Fase: CREATE TABLES
-- Orden de ejecucion (respetar, hay dependencias logicas):
--   1) cat_tipoMovimientoCredito     (catalogo, sin dependencias nuevas)
--   2) cat_configuracionCredito      (catalogo, sin dependencias nuevas)
--   3) ALTER cat_personas            (extension de cliente existente)
--   4) proc_movimientosCredito       (nucleo / ledger, referencia FK logicas a 1,2,3 y a tablas existentes)
--   5) proc_movimientosCreditoPago   (detalle de formas de pago de un Abono/Liquidacion, hija de 4)
--   6) proc_creditoLimiteHistorial   (auditoria, referencia FK logica a cat_personas)
--
-- Nota de diseno: siguiendo el patron ya usado en el proyecto (ver sp_ui_agendaReprogramacion),
-- la integridad referencial se valida en los Stored Procedures (SELECT + RAISERROR), por lo que
-- aqui NO se agregan constraints FOREIGN KEY explicitos, igual que en cat_tiposPago /
-- proc_movimientosInventarios. Las relaciones logicas quedan documentadas en comentarios.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1) CATALOGO: cat_tipoMovimientoCredito
-- Tipos de movimiento que afectan el saldo de credito de un cliente.
-- signo: +1 aumenta saldo, -1 disminuye saldo, NULL = variable (lo define el signo
-- del monto capturado en el momento, aplica solo a AJUSTE).
-- ----------------------------------------------------------------------------
CREATE TABLE [dbo].[cat_tipoMovimientoCredito](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[clave] [varchar](30) NOT NULL,
	[descripcion] [varchar](150) NOT NULL,
	[signo] [smallint] NULL,
	[comentarios] [varchar](450) NULL,
	[activo] [bit] NULL,
	[idEntidad] [int] NOT NULL,
	[fechaModificacion] [datetime] NULL,
	[idUsuarioModifica] [int] NULL,
	[fechaAlta] [datetime] NOT NULL,
	[idUsuarioAlta] [int] NOT NULL,
 CONSTRAINT [PK_cat_tipoMovimientoCredito] PRIMARY KEY CLUSTERED
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[cat_tipoMovimientoCredito] ADD CONSTRAINT [CK_cat_tipoMovimientoCredito_signo]
	CHECK ([signo] IS NULL OR [signo] IN (1,-1))
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_cat_tipoMovimientoCredito_clave] ON [dbo].[cat_tipoMovimientoCredito]
(
	[clave] ASC,
	[idEntidad] ASC
)
GO

-- Seed: una fila por cada Entidad activa existente. idUsuarioAlta=1 asume usuario sistema;
-- ajustar al id real del usuario/proceso de sistema de este ambiente antes de ejecutar.
INSERT INTO [dbo].[cat_tipoMovimientoCredito] ([clave],[descripcion],[signo],[activo],[idEntidad],[fechaAlta],[idUsuarioAlta])
SELECT 'CARGO',         'Cargo (venta a credito)',                    1, 1, e.[id], dbo.fn_GetDateMX(), 1 FROM [dbo].[sys_entidades] e WHERE ISNULL(e.[activo],1) = 1
UNION ALL
SELECT 'ABONO',         'Abono (pago parcial de saldo)',             -1, 1, e.[id], dbo.fn_GetDateMX(), 1 FROM [dbo].[sys_entidades] e WHERE ISNULL(e.[activo],1) = 1
UNION ALL
SELECT 'LIQUIDACION',   'Liquidacion (pago total del saldo)',        -1, 1, e.[id], dbo.fn_GetDateMX(), 1 FROM [dbo].[sys_entidades] e WHERE ISNULL(e.[activo],1) = 1
UNION ALL
SELECT 'AJUSTE',        'Ajuste manual (condonacion / correccion)', NULL, 1, e.[id], dbo.fn_GetDateMX(), 1 FROM [dbo].[sys_entidades] e WHERE ISNULL(e.[activo],1) = 1
UNION ALL
SELECT 'REVERSA_CARGO', 'Reversa de cargo (cancelacion/devolucion)', -1, 1, e.[id], dbo.fn_GetDateMX(), 1 FROM [dbo].[sys_entidades] e WHERE ISNULL(e.[activo],1) = 1
GO


-- ----------------------------------------------------------------------------
-- 2) CATALOGO: cat_configuracionCredito
-- Configuracion de recargo por credito, dias de vencimiento y limite default de
-- alta express, versionada por Entidad (no se edita: se cierra vigenteHasta y se
-- inserta una fila nueva).
-- ----------------------------------------------------------------------------
CREATE TABLE [dbo].[cat_configuracionCredito](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[tipoValorRecargo] [varchar](20) NOT NULL,
	[nivelAplicacion] [varchar](20) NOT NULL,
	[valorRecargo] [decimal](18, 4) NOT NULL,
	[diasVencimientoCargo] [int] NOT NULL,
	[limiteCreditoDefaultExpress] [decimal](18, 2) NOT NULL,
	[vigenteDesde] [datetime] NOT NULL,
	[vigenteHasta] [datetime] NULL,
	[comentarios] [varchar](450) NULL,
	[activo] [bit] NULL,
	[idEntidad] [int] NOT NULL,
	[fechaModificacion] [datetime] NULL,
	[idUsuarioModifica] [int] NULL,
	[fechaAlta] [datetime] NOT NULL,
	[idUsuarioAlta] [int] NOT NULL,
 CONSTRAINT [PK_cat_configuracionCredito] PRIMARY KEY CLUSTERED
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[cat_configuracionCredito] ADD CONSTRAINT [CK_cat_configuracionCredito_tipoValorRecargo]
	CHECK ([tipoValorRecargo] IN ('Fijo','Porcentaje'))
GO

ALTER TABLE [dbo].[cat_configuracionCredito] ADD CONSTRAINT [CK_cat_configuracionCredito_nivelAplicacion]
	CHECK ([nivelAplicacion] IN ('Producto','Carrito'))
GO

-- Regla de negocio "una sola combinacion activa a la vez" aplicada a nivel de dato:
-- solo puede existir UNA fila con vigenteHasta NULL por Entidad.
CREATE UNIQUE NONCLUSTERED INDEX [UQ_cat_configuracionCredito_activaPorEntidad] ON [dbo].[cat_configuracionCredito]
(
	[idEntidad] ASC
)
WHERE [vigenteHasta] IS NULL
GO


-- ----------------------------------------------------------------------------
-- 3) ALTER: extension de cat_personas (cliente) con datos de credito
-- ----------------------------------------------------------------------------
ALTER TABLE [dbo].[cat_personas] ADD
	[creditoHabilitado] [bit] NULL,
	[limiteCredito] [decimal](18, 2) NULL,
	[saldoActual] [decimal](18, 2) NULL,
	[fechaUltimoMovimientoCredito] [datetime] NULL
GO

-- Backfill: filas existentes quedan con credito deshabilitado y saldo en cero.
UPDATE [dbo].[cat_personas]
   SET [creditoHabilitado] = 0,
       [saldoActual] = 0
 WHERE [creditoHabilitado] IS NULL
GO


-- ----------------------------------------------------------------------------
-- 4) NUCLEO: proc_movimientosCredito (ledger de credito)
-- Cada fila es un evento que afecta el saldo de un cliente (Cargo/Abono/
-- Liquidacion/Ajuste/Reversa). PK compuesta igual al patron de
-- proc_movimientosInventarios (folio + idEntidad + idSucursal).
--
-- Relaciones logicas (validadas por SP, sin FK fisica):
--   idPersona                      -> cat_personas.id
--   idTipoMovimientoCredito        -> cat_tipoMovimientoCredito.id
--   idEntidad                      -> sys_entidades.id
--   idSucursal                     -> cat_sucursales.idSucursal   (origen del movimiento)
--   folioEntradaSalidaRelacionado  -> proc_entradasSalidas.folioEntradaSalida  (solo Cargo/Reversa)
--   folioMovimientoCreditoOrigen   -> proc_movimientosCredito.folioMovimientoCredito (self, solo Reversa)
--
-- El desglose de formas de pago de un Abono/Liquidacion (permite pago combinado,
-- ej. efectivo + tarjeta) vive en la tabla hija proc_movimientosCreditoPago, NO en
-- esta tabla. SUM(montoPago) de los hijos debe igualar el [monto] de este renglon;
-- esa validacion la hace el SP InsertAbonoCredito (siguiente fase), no un
-- constraint de BD.
-- ----------------------------------------------------------------------------
CREATE TABLE [dbo].[proc_movimientosCredito](
	[folioMovimientoCredito] [int] NOT NULL,
	[idPersona] [int] NOT NULL,
	[idTipoMovimientoCredito] [int] NOT NULL,
	[monto] [decimal](18, 2) NOT NULL,
	[saldoAnterior] [decimal](18, 2) NOT NULL,
	[saldoNuevo] [decimal](18, 2) NOT NULL,
	[folioEntradaSalidaRelacionado] [int] NULL,
	[fechaVencimiento] [datetime] NULL,
	[motivo] [varchar](450) NULL,
	[folioMovimientoCreditoOrigen] [int] NULL,
	[comentarios] [varchar](450) NULL,
	[activo] [bit] NULL,
	[idEntidad] [int] NOT NULL,
	[idSucursal] [int] NOT NULL,
	[fechaModificacion] [datetime] NULL,
	[idUsuarioModifica] [int] NULL,
	[fechaAlta] [datetime] NOT NULL,
	[idUsuarioAlta] [int] NOT NULL,
 CONSTRAINT [PK_proc_movimientosCredito] PRIMARY KEY CLUSTERED
(
	[folioMovimientoCredito] ASC,
	[idEntidad] ASC,
	[idSucursal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Historial/saldo por cliente (pantalla de ficha de cliente y calculo de saldoActual)
CREATE NONCLUSTERED INDEX [IX_proc_movimientosCredito_idPersona] ON [dbo].[proc_movimientosCredito]
(
	[idPersona] ASC,
	[idEntidad] ASC,
	[fechaAlta] ASC
)
GO

-- Dashboard de cartera vencida (solo aplica a filas de tipo Cargo con fecha de vencimiento)
CREATE NONCLUSTERED INDEX [IX_proc_movimientosCredito_fechaVencimiento] ON [dbo].[proc_movimientosCredito]
(
	[idEntidad] ASC,
	[fechaVencimiento] ASC
)
WHERE [fechaVencimiento] IS NOT NULL
GO

-- Busqueda del Cargo original al cancelar/devolver una venta (para generar la Reversa)
CREATE NONCLUSTERED INDEX [IX_proc_movimientosCredito_folioEntradaSalida] ON [dbo].[proc_movimientosCredito]
(
	[folioEntradaSalidaRelacionado] ASC,
	[idEntidad] ASC
)
WHERE [folioEntradaSalidaRelacionado] IS NOT NULL
GO


-- ----------------------------------------------------------------------------
-- 5) DETALLE: proc_movimientosCreditoPago
-- Formas de pago de un Abono/Liquidacion (hija de proc_movimientosCredito),
-- mismo patron multi-pago que proc_entradasSalidaPago usa para ventas. Un Cargo,
-- Ajuste o Reversa NO genera filas aqui (no son un pago recibido).
-- ----------------------------------------------------------------------------
CREATE TABLE [dbo].[proc_movimientosCreditoPago](
	[folioMovimientoCredito] [int] NOT NULL,
	[idTipoPago] [int] NOT NULL,
	[montoPago] [decimal](18, 2) NULL,
	[numeroAutorizacion] [varchar](250) NOT NULL,
	[comentarios] [varchar](450) NULL,
	[activo] [bit] NULL,
	[idEntidad] [int] NOT NULL,
	[idSucursal] [int] NOT NULL,
	[fechaModificacion] [datetime] NULL,
	[idUsuarioModifica] [int] NULL,
	[fechaAlta] [datetime] NOT NULL,
	[idUsuarioAlta] [int] NOT NULL,
 CONSTRAINT [PK_proc_movimientosCreditoPago] PRIMARY KEY CLUSTERED
(
	[folioMovimientoCredito] ASC,
	[idTipoPago] ASC,
	[idEntidad] ASC,
	[idSucursal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


-- ----------------------------------------------------------------------------
-- 6) AUDITORIA: proc_creditoLimiteHistorial
-- Log insert-only de cambios de limite de credito (rol superior). Separado del
-- ledger de movimientos porque es configuracion, no dinero.
-- ----------------------------------------------------------------------------
CREATE TABLE [dbo].[proc_creditoLimiteHistorial](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idPersona] [int] NOT NULL,
	[limiteAnterior] [decimal](18, 2) NOT NULL,
	[limiteNuevo] [decimal](18, 2) NOT NULL,
	[motivo] [varchar](450) NOT NULL,
	[idEntidad] [int] NOT NULL,
	[idSucursal] [int] NOT NULL,
	[fechaAlta] [datetime] NOT NULL,
	[idUsuarioAlta] [int] NOT NULL,
 CONSTRAINT [PK_proc_creditoLimiteHistorial] PRIMARY KEY CLUSTERED
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_proc_creditoLimiteHistorial_idPersona] ON [dbo].[proc_creditoLimiteHistorial]
(
	[idPersona] ASC,
	[idEntidad] ASC
)
GO
