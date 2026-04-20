Select * From cat_personas where id = 1132 and idEntidad = 10007
Select * From cat_tiposPersonas WHERE idEntidad = 10007 and id = 30
Select * From cat_tipoBloqueoHorario
Select * From proc_empleadoHorario
Select * From proc_empleadoBloqueoHorario
Select * From cat_productosServicios where id = 2650 
Select * From proc_agenda
Select * From proc_agendaDetalleServicio
Select * From proc_agendaBitacora
Select * From cat_origenAgenda 


--Update cat_productosServicios set duracionBaseMin = 90,mostrarEnAgenda = 1, esServicio = 1 where id = 2650 
--Select * From sys_entidades

--exec sp_ui_empleado
--	@id = 0
--	,@nombre	 = 'Julion'
--	,@apellidoP = 'AlvareZ'
--	,@apellidoM = ''
--	,@numeroTelefono = '5556967640'
--	,@correo = 'julion@gmail.com'
--	,@comentarios = ''
--	,@activo = 1
--	,@idEntidad = 10007
--	,@idUsuarioModifica = 1
--	,@fechaNacimiento = '20011010'


--Update cat_origenAgenda						set idEntidad = 10007
--Update cat_rolParticipacionServicio			set idEntidad = 10007
--Update cat_tipoMovimientoPagoAgenda			set idEntidad = 10007
--Update cat_estatusAgendaDetalleServicio		set idEntidad = 10007
--Update cat_estatusAgendaDetalleServicio		set idEntidad = 10007
--Update cat_estatusAgenda					set idEntidad = 10007
----Update cat_tipoMovimientoAgenda				set idEntidad = 10007
--Update cat_tipoBloqueoHorario				set idEntidad = 10007
--Update cat_estatusPagoAgenda				set idEntidad = 10007

--Delete From proc_agendaDetalleServicio
--Delete From proc_agenda
--Truncate table proc_agendaDetalleServicio
--Truncate table proc_agenda
--truncate table proc_agendaDetalleServicioEmpleado
--truncate table proc_agendaBitacora
--Truncate table  cat_estatusAgendaDetalleServicio
--truncate table proc_agendaDetalleServicioEmpleado
--truncate table proc_agendaReprogramacion

sp_se_catalogos
cat_origenAgenda

EXEC dbo.sp_se_horariosDisponiblesServicio
    @idProductoServicio = 2650,
    @fecha = '2026-04-18',
    @idEntidad = 10007,
    @folioEmpleado = 1132,
    @intervaloMin = 30;

--update proc_empleadoHorario set diaSemana = 6 ,comentarios = ''
--Select  DATEPART(WEEKDAY, '20260419');  
Select* From proc_empleadoHorario
Select* From proc_empleadoBloqueoHorario
Select* From proc_agenda
Select* From proc_agendaDetalleServicio
Select* From proc_agendaDetalleServicioEmpleado
Select* From proc_agendaPago
Select* From proc_agendaPagoDetalle
Select* From proc_agendaBitacora
Select* From proc_agendaReprogramacion
EXEC dbo.sp_se_agendaDetalleCompleto    @folioAgenda = 2,    @idEntidad = 10007

Delete proc_empleadoHorario
Delete proc_empleadoBloqueoHorario
Delete proc_agenda
Delete proc_agendaDetalleServicio
Delete proc_agendaDetalleServicioEmpleado
Delete proc_agendaPago
Delete proc_agendaPagoDetalle
Delete proc_agendaBitacora
Delete proc_agendaReprogramacion

--Truncate table proc_empleadoHorario
--Truncate table proc_empleadoBloqueoHorario
--Truncate table proc_agendaDetalleServicioEmpleado
--Truncate table proc_agendaPagoDetalle
--Truncate table proc_agendaBitacora
--Truncate table proc_agendaReprogramacion
--Truncate table proc_agendaPago
--Truncate table proc_agendaDetalleServicio
--Truncate table proc_agenda

DBCC CHECKIDENT ('proc_empleadoHorario', RESEED, 0);
DBCC CHECKIDENT ('proc_empleadoBloqueoHorario', RESEED, 0);
DBCC CHECKIDENT ('proc_agendaDetalleServicioEmpleado', RESEED, 0);
DBCC CHECKIDENT ('proc_agendaPagoDetalle', RESEED, 0);
DBCC CHECKIDENT ('proc_agendaBitacora', RESEED, 0);
DBCC CHECKIDENT ('proc_agendaReprogramacion', RESEED, 0);
DBCC CHECKIDENT ('proc_agendaPago', RESEED, 0);
DBCC CHECKIDENT ('proc_agendaDetalleServicio', RESEED, 0);
DBCC CHECKIDENT ('proc_agenda', RESEED, 0);


--Insert sys_folios (descripcion,comentarios,activo,idEntidad,fechaAlta,idUsuarioAlta)
--Select 'Folio Agenda', '',1,1,GETDATE(),1


DECLARE @idEntidad int = 10007;
DECLARE @folioEmpleado int = 1132;
DECLARE @fechaIni date = '2026-04-14';
DECLARE @fechaFin date = '2026-04-20';

SELECT
    a.folioAgenda,
    ds.folioAgendaDetalleServicio,
    dse.folioAgendaDetalleServicioEmpleado,
    dse.folioEmpleado,
    a.fechaCita,
    a.horaInicioProgramada AS horaInicioAgenda,
    a.horaFinProgramada AS horaFinAgenda,
    ds.horaInicioProgramada AS horaInicioDetalle,
    ds.horaFinProgramada AS horaFinDetalle,
    ds.cancelado,
    a.activo AS agendaActiva,
    ds.activo AS detalleActivo,
    dse.activo AS detalleEmpleadoActivo
FROM dbo.proc_agendaDetalleServicioEmpleado dse
INNER JOIN dbo.proc_agendaDetalleServicio ds
    ON ds.folioAgendaDetalleServicio = dse.folioAgendaDetalleServicio
   AND ds.idEntidad = dse.idEntidad
INNER JOIN dbo.proc_agenda a
    ON a.folioAgenda = ds.folioAgenda
   AND a.idEntidad = ds.idEntidad
WHERE dse.folioEmpleado = @folioEmpleado
  AND dse.idEntidad = @idEntidad
  AND CONVERT(date, a.fechaCita) between @fechaIni and @fechaFin
ORDER BY ISNULL(ds.horaInicioProgramada, a.horaInicioProgramada);



--Select * From proc_empleadoHorario
--Select * From proc_empleadoBloqueoHorario