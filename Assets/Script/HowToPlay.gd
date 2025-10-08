# HowToPlay.gd
extends Control

# Referencias a nodos
@onready var background = $Background  # TextureRect para el fondo
@onready var current_page = $CurrentPage
@onready var left_button = $Navigation/LeftButton
@onready var right_button = $Navigation/RightButton
@onready var page_indicator = $Navigation/PageIndicator
@onready var regresar_button = $Navigation/RegresarButton

# Configuración de páginas por idioma y tema
var paginas_config = {
	"es_light": [
		"res://Assets/Sprites/UI/Como Jugar/shield_right_es_light.png",
		"res://Assets/Sprites/UI/Como Jugar/shield_left_es_light.png",
		"res://Assets/Sprites/UI/Como Jugar/shield_up_es_light.png",
		"res://Assets/Sprites/UI/Como Jugar/shield_up_up_es_light.png"
	],
	"es_dark": [
		"res://Assets/Sprites/UI/Como Jugar/shield_right_es_dark.png",
		"res://Assets/Sprites/UI/Como Jugar/shield_left_es_dark.png",
		"res://Assets/Sprites/UI/Como Jugar/shield_up_es_dark.png",
		"res://Assets/Sprites/UI/Como Jugar/shield_up_up_es_dark.png"
	],
	"en_light": [
		"res://Assets/Sprites/UI/Como Jugar/shield_right_en_light.png",
		"res://Assets/Sprites/UI/Como Jugar/shield_left_en_light.png",
		"res://Assets/Sprites/UI/Como Jugar/shield_up_en_light.png",
		"res://Assets/Sprites/UI/Como Jugar/shield_up_up_en_light.png"
	],
	"en_dark": [
		"res://Assets/Sprites/UI/Como Jugar/shield_right_en_dark.png",
		"res://Assets/Sprites/UI/Como Jugar/shield_left_en_dark.png",
		"res://Assets/Sprites/UI/Como Jugar/shield_up_en_dark.png",
		"res://Assets/Sprites/UI/Como Jugar/shield_up_up_en_dark.png"
	]
}

# Texturas para el fondo (solo modo claro/oscuro)
var texturas_fondo = {
	"light": "res://Assets/Sprites/UI/Como Jugar/background_light.png",
	"dark": "res://Assets/Sprites/UI/Como Jugar/background_dark.png"
}

var texturas_botones_navegacion = {
	"light": {
		"left": "res://Assets/Sprites/UI/Botones/Modo Claro/izquierda.png",
		"right": "res://Assets/Sprites/UI/Botones/Modo Claro/derecha.png"
	},
	"dark": {
		"left": "res://Assets/Sprites/UI/Botones/Modo Oscuro/izquierda.png",
		"right": "res://Assets/Sprites/UI/Botones/Modo Oscuro/derecha.png"
	}
}

var texturas_boton_regresar = {
	"light": "res://Assets/Sprites/UI/Botones/Modo Claro/regresar.png",
	"dark": "res://Assets/Sprites/UI/Botones/Modo Oscuro/regresar.png"
}

var pagina_actual = 0
var total_paginas = 4

func _ready():
	# Conectar señales
	left_button.pressed.connect(_on_left_pressed)
	right_button.pressed.connect(_on_right_pressed)
	regresar_button.pressed.connect(_on_regresar_pressed)
	
	# Conectar a cambios de configuración
	ConfigManager.color_mode_changed.connect(_on_config_changed)
	ConfigManager.language_changed.connect(_on_config_changed)
	
	# Aplicar configuración actual
	_aplicar_configuracion()
	
	# Cargar primera página
	_actualizar_pagina()

func _aplicar_configuracion():
	var modo = ConfigManager.get_color_mode()
	var idioma = ConfigManager.get_language()
	
	print("🎨 HowToPlay: Aplicando configuración - Idioma: ", idioma, ", Modo: ", modo)
	
	# Aplicar fondo (solo modo)
	_aplicar_fondo(modo)
	
	# Aplicar botones de navegación (solo modo)
	_aplicar_botones_navegacion(modo)
	
	# Aplicar botón regresar (solo modo)
	_aplicar_boton_regresar(modo)

func _aplicar_fondo(modo: String):
	if texturas_fondo.has(modo):
		var texture_path = texturas_fondo[modo]
		var texture = load(texture_path)
		if texture:
			background.texture = texture
			print("✅ Fondo aplicado: ", texture_path)
		else:
			print("❌ Error cargando fondo: ", texture_path)
	else:
		print("❌ Modo no encontrado para fondo: ", modo)

func _aplicar_botones_navegacion(modo: String):
	if texturas_botones_navegacion.has(modo):
		var texturas_modo = texturas_botones_navegacion[modo]
		
		# Aplicar texturas a botones de navegación
		_aplicar_textura_boton(left_button, texturas_modo, "left")
		_aplicar_textura_boton(right_button, texturas_modo, "right")
		
		print("✅ Botones de navegación aplicados - Modo: ", modo)
	else:
		print("❌ Modo no encontrado para botones de navegación: ", modo)

func _aplicar_boton_regresar(modo: String):
	if texturas_boton_regresar.has(modo):
		var texture_path = texturas_boton_regresar[modo]
		var texture = load(texture_path)
		if texture:
			regresar_button.texture_normal = texture
			print("✅ Botón regresar aplicado: ", texture_path)
		else:
			print("❌ Error cargando botón regresar: ", texture_path)
	else:
		print("❌ Modo no encontrado para botón regresar: ", modo)

func _aplicar_textura_boton(boton: TextureButton, texturas: Dictionary, clave: String):
	if boton and texturas.has(clave):
		var texture_path = texturas[clave]
		var texture = load(texture_path)
		if texture:
			boton.texture_normal = texture
		else:
			print("❌ Error cargando textura: ", texture_path, " para botón: ", clave)

func _get_paginas_actuales():
	var idioma = ConfigManager.get_language()
	var tema = ConfigManager.get_color_mode()
	var clave = "%s_%s" % [idioma, tema]
	
	if paginas_config.has(clave):
		return paginas_config[clave]
	else:
		# Fallback a español light
		print("⚠️  No se encontraron páginas para: ", clave, ", usando español light")
		return paginas_config["es_light"]

func _actualizar_pagina():
	var paginas_actuales = _get_paginas_actuales()
	
	# Cargar la textura de la página actual
	if pagina_actual < paginas_actuales.size():
		var texture_path = paginas_actuales[pagina_actual]
		var texture = load(texture_path)
		if texture:
			current_page.texture = texture
			print("📄 Página cargada: ", texture_path)
		else:
			print("❌ Error cargando textura: ", texture_path)
	
	# Actualizar visibilidad de botones
	left_button.visible = (pagina_actual > 0)
	right_button.visible = (pagina_actual < total_paginas - 1)
	
	# Actualizar indicador de página
	page_indicator.text = "%d/%d" % [pagina_actual + 1, total_paginas]
	
	print("🔢 Página actual: ", pagina_actual + 1, " de ", total_paginas)

func _on_left_pressed():
	if pagina_actual > 0:
		pagina_actual -= 1
		_actualizar_pagina()
		print("⬅️ Navegando a página: ", pagina_actual + 1)

func _on_right_pressed():
	if pagina_actual < total_paginas - 1:
		pagina_actual += 1
		_actualizar_pagina()
		print("➡️ Navegando a página: ", pagina_actual + 1)

func _on_regresar_pressed():
	print("🔙 Regresando al menú principal")
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/MainMenu.tscn")

func _on_config_changed(_value):
	print("🔄 HowToPlay: Configuración cambiada - actualizando interfaz")
	_aplicar_configuracion()
	# Recargar la página actual con el nuevo idioma/tema
	_actualizar_pagina()
