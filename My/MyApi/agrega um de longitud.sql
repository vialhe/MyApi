Select 
	* 
From 
	tbl_App_Usuario a
	join tbl_Persona b
		ON a.iIdFolioPersona = b.iIdFolioPersona
	join tbl_Memb_Membresia c
		On a.iIdFolioPersona = c.iIdFolioPersona

Select 
	us.sUsuario ,
	dbo.FG_Desencriptar(us.sPassword) as contraseña,
	dbo.encr
	pers.*
From 
	tbl_Usuario us
	join tbl_Persona pers
		On us.iIdFolioPersona = pers.iIdFolioPersona
Where
	--us.iIdUsuario IN (1073)
	us.sUsuario = 'vhernandez'
		 

Insert into tbl_Config_ConfiguracionH
Select * From psnevo.evolution_pro.dbo.tbl_Config_ConfiguracionH where iIdConfiguracion = 329
Insert into tbl_Config_ConfiguracionD
Update tbl_Config_ConfiguracionD set Valor = 1 where iIdConfiguracion = 329

Create Proc sp_se_activoGeneraciónMembresiaAutomatica
As
Begin
	Select 
		Cast(Cast(ISNULL(Valor, 0) As int) As bit) As activo
	From 
		tbl_Config_ConfiguracionD	
	Where
		iIdConfiguracion = 329
		And iIdCentro = 1001
END

exec p