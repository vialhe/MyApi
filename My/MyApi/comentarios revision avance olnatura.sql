Login:
	-- imagenes cambiantes con efecto de desvanecido <-- Se configuran en perosnalizacion de login
Personalizacion de Login
	-- Modo dinamico y modo estatico
	-- En modo estatico se va a elegir la imagen de arriba por defecto pero se puede elegir otra.
	-- Gestion de imagenes de imagenes para cargar y eliminar.
	-- Dentro de cada imagen agregar boton de eliminar imagen y boton de ojito para ocultar/mostrar.
	-- Drag and drop para ordenar imagenes, pedir confirmación cuando se mueva una imagen de orden.
	-- limitar a 4 imagenes como maximo.
	-- El drag and drop para cargar imagenes debe desactivarse cuando se tenga el maximo de imaganes e informar que primero debe de borar 1 para cargar otra.
Barra de navegacion:
	-- Lado izquierdo colapsable con modulos de Nosotros, Comunicados y Noticias, Organigrama, Crud Empleado,Vacaciones,expediente digital, otros crud requeridos.
Nosotros
	-- Carrusel banner prinicipal hasta arriba, el texto sobre los banners se puede personalizar, el carrusel pueden ser maximo 4 imagenes.
	-- Texto de "Ver más" siempre redirecciona  acimunicados y noticias. Boton estará sobre el carrusel principal.
	-- El Carrusel de imagenes principal se difunmiara para darle realce al texto.
	-- Maximo 4 secciones con titulo, body, checks(opcional) editables, carrusel de imagenes limitado a 4 cantidad. El texto debe de ser limitado y checks limitado.
	-- El diseño de la secciones es imagen a la izquierda con texto ala dercha con tituloy contenido y jugar intercambiando el texto con la imagenes para que no todas las imagenes a la izquierda.
	-- Texto Justificado.
Personalizacion de Nosotros:
	-- Edición de banners principal y titulo, limtado a 4 imagenes.
	-- Secciones 1 - 4 editables imagenes con 4 max, texto y body editables.
	-- Las secciones deben de tener scroll para que no crezcan y mantengan el diseño
Comunicados y Noticias.
	-- Banner y textos prinical aplican para notificiones y comunicados favoritos.
	-- Modal para mostar informacion del banner elegido, con imagen.
	-- Filtrado por mes y año. Por defecto mes y año actual
	-- Filtrado por tipo de comunicado o notifca con chips. Por defecto en "todos"
	-- Cards de las noticias con imagen,fecha , tipo, al dar click abre el modal.
	-- Scroll lateral en modal para evitar que crezca.
	-- Si eres admin y estas noticias y comunicados y al abrir el modal te aprecerá un "engrane" para poder editar la notica -> Personalizacion de de comunicados y noticias.
Perzonalizacion Comunicados y Noticias.
	-- Formulario para titulo , categoria(combo),Descripcion breve , descripcion larga, programacion publicacion, carga 1 imagen solamente.
	-- Agregar campo de "favorito" que son las que serian para el banner top, o hasta arriba como relevantes.
	-- Parte inferior listado de notificaciones y comunicados ya cargados.
	-- Agrega campo de vigencia para noticias banners, si no poner fecha fin dejarlo hasta que lo quite el usuario.
Organigrama:
	-- Los usuarios empleados base solo pueden ver si linea, solo puede ver n niveles arriba.
	-- Los usuarios empleados jefe solo pueden ver su linea, solo puede ver n niveles arriba y todos los que descienden de el.
	-- Aqui van los KPI de la persona logeada, KPI de su evaluación PDTE DEFINICION REAL.
CRUD de departamentos: descripcion, comentarios, id
CRUD de Puestos: descripcion, comentarios, id
CRUD de turnos: descripcion, comentarios, id
CRUD DE tipos de noticias y comunicados: descripcion, comentarios, id
MODULO de usuarios y perfiles de acceso.<-- ESTE CREO QUE NO EXISTIRÁ PORQUE SE VAN A ELEGIR DESDE EL CRUD DE EMPLEADOS
	-- Elige empleado
	-- Define el rol del empleado para definir que modulos verá.
	-- PDTE DEFINICION DE ROLES, PERO YO CREO QUE SERA BASICO, RH, ADMINITRADOR.
CRUD de empleado:
-- CREATE:
	-- Formulario de empleado: 
		--Numero Empleado(sugerir el ultimo numero de empleado o permitit modificarlo.),
		--Nombre completo, CURP, RFC, Telefono, Correo electronico Personal(opcional), Genero,  
		--numero de nomina, agregar turno
	-- Asignar rol del usuario del empleado (Basico, RH, Admin)
	-- Seccion de detalle del puesto del empleado: Departamento, Puesto/posicion,  Reporta a(jefe directo), fecha de ingreso
	-- Credenciales de acceso: asignar numero de empleado usuario y contraseña.
	-- boton para enviar acceso al empreado: Se debe de enviar al correo solo si se ingresó, sino RH lo pasará en un papelito xd
	-- Permitir cargar los documentos del empleado, esto para que RH lo pueda hacer si le empleado no puede.
-- EDICION: 
	-- lo mismo que la alta pero para editar
-- DELETE :
	--solo cambia el estatus del empleado activo a inactivo
-- READ: 
	--un listado de empleados filtrando por estatus y fecha de ingreso, correo o nombr, departamento
Admin Evaluacion: < --- ESTO AUN NO ESTA DEFINIDO FALTA CONFIRMAR CON CLIENTE
	-- Carga de evaluacion con titulo, texto, valor y porentaje
	-- Asignación de evalucion a empleados o grupos de empleados.
	--competencias
	-- ponderaciones
	-- reportes
Evaluacion:< --- ESTO AUN NO ESTA DEFINIDO FALTA CONFIRMAR CON CLIENTE
	-- Auto Evaluacion
	-- Evaluacion del jefe directo.
Vacaciones:
	-- Card de dias totales, dias tomales, dias restantes.
	-- Historico: muestra dias tomados, solicitudes rechazadas y dias asingados, dias conjeados.
	-- Filtro de estatus aprobado, pendiente, filtro de año, mes
	-- El gerente del arae es quien aprueba vacaciones y tomar como referencia el organigrama.
	-- Una vez que se autorizaron las vacaciones permtir al empleado imprimir la hoja que llevará a RH o su jefe inmediato.
	-- ¿como vamos asignar los dias? se se asignan automaticamente vamos a tener que incluir la antiguedad y agregar la ley federal o incluso politicas interas. sino un modulo pequeño para asignar dias.
Solicitud de vacaciones:
	-- Formulario con: fecha inicio, fecha fin, dias cambiados(cambios por dias festivos o cambios),dias a disfrutar deben de ser calculados en realcion a fechas, fecha reincorporacion que se calcula con le fecha de termino, 
	-- observaciones: campo que muestra la respuesta o comentario del gerente o de quien autoriza.
	-- Seccion de firmasde : el solicitante, jefe inmediato y RH. <--usar librerias para que firmen con le telefono o tactil o mouse pad.
	-- Asignar permisos de firmado, solo puede firmar quien este permitido firmar ahi.
Autorizadores de vacaciones:
	-- Listado de solitudes de vacaciones acmodados por estatus
	-- opcion de firmar para autorizar o bien, comentar la solicitud.
Permisos de ausentismo por accidentes:
	-- mismo que lo de solicitud de vacaciones pero ahora se notifica al area de enfermeria.
Admin para Expediente digital:
	-- El departamento RH define que documentos se requieren.
	-- El departamento puede ver mediante un preview los documentos cargados por el empleado.
	-- El departamento RH confirma que el documento esta correctamente cargado.
	-- El departamento RH rechaza el documento cargado.
Expediente digital:
	-- Card con foto, puesto, departamento, fecha ingreso.
	-- Seccion de carga de documento.
	--tipos de documentos
Footer:
-- Aviso privacidad fijo
-- Iconos de redireccion a red social: Tiktok, Facebook, Instagram.
