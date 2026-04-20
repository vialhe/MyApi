Select TOP 1 * From cat_origenAgenda
Select TOP 1 * From cat_rolParticipacionServicio
Select TOP 1 * From cat_tipoMovimientoPagoAgenda
Select TOP 1 * From cat_estatusAgendaDetalleServicio
Select TOP 1 * From cat_estatusAgenda
Select TOP 1 * From cat_tipoBloqueoHorario
Select TOP 1 * From cat_tipoMovimientoAgenda

EXEC sp_rename 'dbo.cat_origenAgenda.idOrigenAgenda', 'id', 'COLUMN';
EXEC sp_rename 'dbo.cat_rolParticipacionServicio.idRolParticipacionServicio', 'id', 'COLUMN';
EXEC sp_rename 'dbo.cat_tipoMovimientoPagoAgenda.idTipoMovimientoPagoAgenda', 'id', 'COLUMN';
EXEC sp_rename 'dbo.cat_estatusAgendaDetalleServicio.idEstatusAgendaDetalleServicio', 'id', 'COLUMN';
EXEC sp_rename 'dbo.cat_estatusAgenda.idEstatusAgenda', 'id', 'COLUMN';
EXEC sp_rename 'dbo.cat_tipoBloqueoHorario.idTipoBloqueoHorario', 'id', 'COLUMN';
EXEC sp_rename 'dbo.cat_tipoMovimientoAgenda.idTipoMovimientoAgenda', 'id', 'COLUMN';

--Select * From cat_origenAgenda_resp 
--Select * From cat_rolParticipacionServicio_resp 
--Select * From cat_tipoMovimientoPagoAgenda_resp 
--Select * From cat_estatusAgendaDetalleServicio_resp 
--Select * From cat_estatusAgenda_resp 
--Select * From cat_tipoBloqueoHorario_resp 
--Select * From cat_tipoMovimientoAgenda_resp




SELECT 
    o.type_desc,
    s.name AS esquema,
    o.name AS objeto
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE m.definition LIKE '%idOrigenAgenda%'
   OR m.definition LIKE '%idRolParticipacionServicio%'
   OR m.definition LIKE '%idTipoMovimientoPagoAgenda%'
   OR m.definition LIKE '%idEstatusAgendaDetalleServicio%'
   OR m.definition LIKE '%idEstatusAgenda%'
   OR m.definition LIKE '%idTipoBloqueoHorario%'
   OR m.definition LIKE '%idTipoMovimientoAgenda%';
   


SELECT 
    fk.name AS fk_name,
    OBJECT_NAME(fkc.parent_object_id) AS tabla_hija,
    c1.name AS columna_hija,
    OBJECT_NAME(fkc.referenced_object_id) AS tabla_padre,
    c2.name AS columna_padre
FROM sys.foreign_key_columns fkc
JOIN sys.foreign_keys fk 
    ON fk.object_id = fkc.constraint_object_id
JOIN sys.columns c1 
    ON c1.object_id = fkc.parent_object_id 
   AND c1.column_id = fkc.parent_column_id
JOIN sys.columns c2 
    ON c2.object_id = fkc.referenced_object_id 
   AND c2.column_id = fkc.referenced_column_id
WHERE OBJECT_NAME(fkc.referenced_object_id) IN (
    'cat_origenAgenda',
    'cat_rolParticipacionServicio',
    'cat_tipoMovimientoPagoAgenda',
    'cat_estatusAgendaDetalleServicio',
    'cat_estatusAgenda',
    'cat_tipoMovimientoAgenda',
    'cat_tipoBloqueoHorario'
);