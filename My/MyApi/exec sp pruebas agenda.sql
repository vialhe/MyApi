DEFINE VARIABLES
DECLARE @idEntidad int = 10007;
DECLARE @idUsuario int = 1;
DECLARE @folioCliente int = 1121;
DECLARE @idSucursal int = 1;
DECLARE @idProductoServicio int = 2650;
DECLARE @folioEmpleado int = 1132;
DECLARE @idTipoPago int = 1; --efectivo
DECLARE @idOrigenAgenda int = (
    SELECT TOP 1 idOrigenAgenda
    FROM cat_origenAgenda
    WHERE clave = 'POS' AND idEntidad = @idEntidad
);
DECLARE @idRolPrincipal int = (
    SELECT TOP 1 idRolParticipacionServicio
    FROM cat_rolParticipacionServicio
    WHERE clave = 'PRINCIPAL' AND idEntidad = @idEntidad
);
DECLARE @idTipoMovimientoPagoAnticipo int = (
    SELECT TOP 1 idTipoMovimientoPagoAgenda
    FROM cat_tipoMovimientoPagoAgenda 
    WHERE clave = 'LIQUIDACION' AND idEntidad = @idEntidad
);
DECLARE @idEstatusEnProcesoDetalle int = (
    SELECT TOP 1 idEstatusAgendaDetalleServicio
    FROM cat_estatusAgendaDetalleServicio
    WHERE clave = 'ENPROCESO' AND idEntidad = @idEntidad
);
DECLARE @idEstatusConcluidoDetalle int = (
    SELECT TOP 1 idEstatusAgendaDetalleServicio
    FROM cat_estatusAgendaDetalleServicio
    WHERE clave = 'CONCLUIDO' AND idEntidad = @idEntidad
);
DECLARE @idEstatusConcluidaAgenda int = (
    SELECT TOP 1 idEstatusAgenda
    FROM cat_estatusAgenda
    WHERE clave = 'CONCLUIDA' AND idEntidad = @idEntidad
);

Select 
	@idRolPrincipal,
	@idTipoMovimientoPagoAnticipo,
	@idEstatusEnProcesoDetalle,
	@idEstatusConcluidoDetalle,
	@idEstatusConcluidaAgenda

 --ALTA DE HORARIO EMPLEADO
EXEC dbo.sp_ui_empleadoHorario
    @folioEmpleadoHorario = 0,
    @folioEmpleado = @folioEmpleado,
    @diaSemana = 4,
    @horaEntrada = '2026-04-09 09:00:00',
    @horaSalida = '2026-04-09 18:00:00',
    @comentarios = 'Horario jueves',
    @activo = 1,
    @idEntidad = @idEntidad,
    @idUsuarioAlta = @idUsuario


 --ALTA BLOQUEO DE HORARIO EMPLEADO	
EXEC dbo.sp_ui_empleadoBloqueoHorario
    @folioEmpleadoBloqueoHorario = 0,
    @folioEmpleado = @folioEmpleado,
    @fecha = '2026-04-09',
    @horaInicio = '2026-04-09 14:00:00',
    @horaFin = '2026-04-09 15:00:00',
    @idTipoBloqueoHorario = 1, --
    @motivo = 'Comida',
    @comentarios = 'Bloqueo de comida',
    @activo = 1,
    @idEntidad = @idEntidad,
    @idUsuarioAlta = @idUsuario;

 --CONSULTAR HORARIOS DISPONIBLES PARA EL SERVICIO
EXEC dbo.sp_se_horariosDisponiblesServicio
    @idProductoServicio = @idProductoServicio,
    @fecha = '2026-04-09',
    @idEntidad = @idEntidad,
    @folioEmpleado = @folioEmpleado,
    @intervaloMin = 60;

	--CREAR AGENDA
EXEC dbo.sp_ui_agenda
    @folioAgenda = 0,
    @folioCliente = @folioCliente,
    @idSucursal = @idSucursal,
    @fechaCita = '2026-04-09 10:00:00',
    @horaInicioProgramada = '2026-04-09 10:00:00',
    @horaFinProgramada = '2026-04-09 11:00:00',
    @idOrigenAgenda = @idOrigenAgenda,
    @requiereConfirmacion = 1,
    @observacionesInternas = 'Cliente nueva cita',
    @comentarios = 'Alta de agenda de prueba',
    @activo = 1,
    @idEntidad = @idEntidad,
    @idUsuarioAlta = @idUsuario;

	--CREAR AGENDA DETALLE SERVICIO
EXEC dbo.sp_ui_agendaDetalleServicio
    @folioAgendaDetalleServicio = 0,
    @folioAgenda = 1,
    @idProductoServicio = @idProductoServicio,
    @precioFinal = 350.00,
    @descuento = 0,
    @cantidad = 1,
    @ordenServicio = 1,
    @horaInicioProgramada = '2026-04-09 10:00:00',
    @horaFinProgramada = '2026-04-09 11:00:00',
    @comentarios = 'Servicio principal',
    @activo = 1,
    @idEntidad = @idEntidad,
    @idUsuarioAlta = @idUsuario;

	--ASIGNAR PERSONAEMPLEADO AL SERVICIO
EXEC dbo.sp_ui_agendaDetalleServicioEmpleado
    @folioAgendaDetalleServicioEmpleado = 0,
    @folioAgendaDetalleServicio = 1,
    @folioEmpleado = @folioEmpleado,
    @idRolParticipacionServicio = @idRolPrincipal,
    @porcentajeParticipacion = 100,
    @comisionCalculada = 0,
    @horaInicioReal = NULL,
    @horaFinReal = NULL,
    @comentarios = 'Empleado principal',
    @activo = 1,
    @idEntidad = @idEntidad,
    @idUsuarioAlta = @idUsuario;

	-- CONFIRMAR AGENDA
	EXEC dbo.sp_ui_confirmarAgenda
    @folioAgenda = 1,
    @comentarios = 'Confirmada por mostrador',
    @idEntidad = @idEntidad,
    @idUsuarioAlta = @idUsuario;

	-- REGISTRAR ANTICIPO --PAGOS OPCIONALES PRRO
	EXEC dbo.sp_ui_agendaPago
    @folioAgenda = 1,
    @idTipoMovimientoPagoAgenda = @idTipoMovimientoPagoAnticipo,
    @idTipoPago = @idTipoPago,
    @montoPago = 100.00,
    @numeroAutorizacion = NULL,
    @referenciaOperacion = NULL,
    @referenciaExterna = 'ANT-0001',
    @comentarios = 'Anticipo inicial',
    @idEntidad = @idEntidad,
    @idUsuarioAlta = @idUsuario;

	-- PONER SERVICIO EN PROCESO
	EXEC dbo.sp_ui_agendaCambioEstatusDetalleServicio
    @folioAgendaDetalleServicio = 1,
    @idEstatusAgendaDetalleServicioNuevo = @idEstatusEnProcesoDetalle,
    @descripcionMovimiento = 'Inicio del servicio',
    @comentarios = 'Se comenzó atención',
    @idEntidad = @idEntidad,
    @idUsuarioAlta = @idUsuario;

	-- CONCLUIR SERVICIO
	EXEC dbo.sp_ui_agendaCambioEstatusDetalleServicio
    @folioAgendaDetalleServicio = 1,
    @idEstatusAgendaDetalleServicioNuevo = @idEstatusConcluidoDetalle,
    @descripcionMovimiento = 'Servicio concluido',
    @comentarios = 'Se terminó correctamente',
    @idEntidad = @idEntidad,
    @idUsuarioAlta = @idUsuario;

	--CONCLUIR AGENDA
	EXEC dbo.sp_ui_agendaCambioEstatus
    @folioAgenda = 1,
    @idEstatusAgendaNuevo = @idEstatusConcluidaAgenda,
    @descripcionMovimiento = 'Agenda concluida',
    @comentarios = 'Todos los servicios terminados',
    @idEntidad = @idEntidad,
    @idUsuarioAlta = @idUsuario;

	-- REPROGRAMAR AGENDA
	EXEC dbo.sp_ui_agendaReprogramacion
    @folioAgenda = 1,
    @fechaHoraNuevaInicio = '2026-04-09 12:00:00',
    @fechaHoraNuevaFin = '2026-04-09 13:00:00',
    @motivo = 'Cliente pidió mover horario',
    @comentarios = 'Reprogramación manual',
    @idEntidad = @idEntidad,
    @idUsuarioAlta = @idUsuario;

	---- CANCELAR DETALLE SERVICIO
	EXEC dbo.sp_ui_cancelarDetalleServicio
    @folioAgendaDetalleServicio = 1,
    @motivoCancelacion = 'Cliente ya no quiso el servicio',
    @idEntidad = @idEntidad,
    @idUsuarioAlta = @idUsuario;

	------ CANCELAR AGENDA COMPLETA
	EXEC dbo.sp_ui_cancelarAgenda
    @folioAgenda = 1,
    @motivoCancelacion = 'Cliente canceló la cita',
    @cancelarDetalles = 1,
    @idEntidad = @idEntidad,
    @idUsuarioAlta = @idUsuario;


	--OBTENER AGENDA
	EXEC dbo.sp_se_agendaDetalleCompleto
    @folioAgenda = 3,
    @idEntidad = 10007;


	Select * From proc_empleadoHorario