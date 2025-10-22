# OptionsMenu.gd
extends Control

# Referencias a los nodos
@onready var background = $TextureRect
@onready var idioma_espanol = $idioma_español
@onready var idioma_ingles = $idioma_ingles
@onready var modo_oscuro = $modo_oscuro
@onready var modo_claro = $modo_claro
@onready var sonido_on = $sonido_on
@onready var sonido_off = $sonido_off
@onready var regresar = $regresar

# Solo checks para idioma
@onready var check_espanol = $idioma_español/CheckMark
@onready var check_ingles = $idioma_ingles/CheckMark

# Texturas para modo claro y oscuro CON IDIOMA
var texturas_fondo = {
	"es_light": "res://Assets/Sprites/UI/Configuracion/config_es_light.png",
	"es_dark": "res://Assets/Sprites/UI/Configuracion/config_es_dark.png",
	"en_light": "res://Assets/Sprites/UI/Configuracion/config_en_light.png",
	"en_dark": "res://Assets/Sprites/UI/Configuracion/config_en_dark.png"
}

var texturas_botones = {
	"light": {
		"regresar": "res://Assets/Sprites/UI/Botones/Modo Claro/regresar.png",
		"modo_claro": "res://Assets/Sprites/UI/Botones/Modo Claro/modo_claro.png",
		"modo_oscuro": "res://Assets/Sprites/UI/Botones/Modo Claro/modo_oscuro.png",
		"sonido_on": "res://Assets/Sprites/UI/Botones/Modo Claro/sonido_on.png",
		"sonido_off": "res://Assets/Sprites/UI/Botones/Modo Claro/sonido_off.png"
	},
	"dark": {
		"regresar": "res://Assets/Sprites/UI/Botones/Modo Oscuro/regresar.png",
		"modo_claro": "res://Assets/Sprites/UI/Botones/Modo Oscuro/modo_claro.png",
		"modo_oscuro": "res://Assets/Sprites/UI/Botones/Modo Oscuro/modo_oscuro.png",
		"sonido_on": "res://Assets/Sprites/UI/Botones/Modo Oscuro/sound_on.png",
		"sonido_off": "res://Assets/Sprites/UI/Botones/Modo Oscuro/sound_off.png"
	}
}

# Botones de idioma con versiones en ambos idiomas y modos
var texturas_botones_idioma = {
	"es_light": {
		"idioma_espanol": "res://Assets/Sprites/UI/Configuracion/es_español_light.png",
		"idioma_ingles": "res://Assets/Sprites/UI/Configuracion/es_ingles_light.png"
	},
	"es_dark": {
		"idioma_espanol": "res://Assets/Sprites/UI/Configuracion/es_español_dark.png",
		"idioma_ingles": "res://Assets/Sprites/UI/Configuracion/es_ingles_dark.png"
	},
	"en_light": {
		"idioma_espanol": "res://Assets/Sprites/UI/Configuracion/en_español_light.png",
		"idioma_ingles": "res://Assets/Sprites/UI/Configuracion/en_ingles_light.png"
	},
	"en_dark": {
		"idioma_espanol": "res://Assets/Sprites/UI/Configuracion/en_español_dark.png",
		"idioma_ingles": "res://Assets/Sprites/UI/Configuracion/en_ingles_dark.png"
	}
}

var texturas_checks = {
	"light": "res://Assets/Sprites/UI/Configuracion/check_light.png",
	"dark": "res://Assets/Sprites/UI/Configuracion/check_dark.png"
}

func _ready():
	# Conectar señales
	_conectar_senales()
	
	# Conectar a cambios de configuración
	ConfigManager.color_mode_changed.connect(_on_config_changed)
	ConfigManager.language_changed.connect(_on_config_changed)
	ConfigManager.sound_volume_changed.connect(_on_sound_volume_changed)
	
	# Aplicar configuración actual
	_aplicar_configuracion()
	
	# Inicializar estado visual
	_actualizar_botones_idioma()
	_actualizar_estado_modo()
	_actualizar_estado_sonido()

func _conectar_senales():
	# Botones de idioma
	if not idioma_espanol.pressed.is_connected(_on_idioma_espanol_pressed):
		idioma_espanol.pressed.connect(_on_idioma_espanol_pressed)
	if not idioma_ingles.pressed.is_connected(_on_idioma_ingles_pressed):
		idioma_ingles.pressed.connect(_on_idioma_ingles_pressed)
	
	# Botones de modo
	if not modo_oscuro.pressed.is_connected(_on_modo_oscuro_pressed):
		modo_oscuro.pressed.connect(_on_modo_oscuro_pressed)
	if not modo_claro.pressed.is_connected(_on_modo_claro_pressed):
		modo_claro.pressed.connect(_on_modo_claro_pressed)
	
	# Botones de sonido
	if not sonido_on.pressed.is_connected(_on_sonido_on_pressed):
		sonido_on.pressed.connect(_on_sonido_on_pressed)
	if not sonido_off.pressed.is_connected(_on_sonido_off_pressed):
		sonido_off.pressed.connect(_on_sonido_off_pressed)
	
	# Botón regresar
	if not regresar.pressed.is_connected(_on_regresar_pressed):
		regresar.pressed.connect(_on_regresar_pressed)
	
	# Conectar señales de hover para efecto contrario
	_conectar_hover_senales()

func _conectar_hover_senales():
	# Conectar hover a todos los botones regulares
	_conectar_hover_boton(regresar, "regresar")
	_conectar_hover_boton(modo_claro, "modo_claro")
	_conectar_hover_boton(modo_oscuro, "modo_oscuro")
	_conectar_hover_boton(sonido_on, "sonido_on")
	_conectar_hover_boton(sonido_off, "sonido_off")
	
	# Conectar hover a botones de idioma
	_conectar_hover_boton_idioma(idioma_espanol, "idioma_espanol")
	_conectar_hover_boton_idioma(idioma_ingles, "idioma_ingles")

func _conectar_hover_boton(boton: TextureButton, clave_boton: String):
	if boton:
		if not boton.mouse_entered.is_connected(_on_boton_mouse_entered.bind(boton, clave_boton)):
			boton.mouse_entered.connect(_on_boton_mouse_entered.bind(boton, clave_boton))
		if not boton.mouse_exited.is_connected(_on_boton_mouse_exited.bind(boton, clave_boton)):
			boton.mouse_exited.connect(_on_boton_mouse_exited.bind(boton, clave_boton))

func _conectar_hover_boton_idioma(boton: TextureButton, clave_boton: String):
	if boton:
		if not boton.mouse_entered.is_connected(_on_boton_idioma_mouse_entered.bind(boton, clave_boton)):
			boton.mouse_entered.connect(_on_boton_idioma_mouse_entered.bind(boton, clave_boton))
		if not boton.mouse_exited.is_connected(_on_boton_idioma_mouse_exited.bind(boton, clave_boton)):
			boton.mouse_exited.connect(_on_boton_idioma_mouse_exited.bind(boton, clave_boton))

func _on_boton_mouse_entered(boton: TextureButton, clave_boton: String):
	_aplicar_hover_contrario(boton, clave_boton)

func _on_boton_mouse_exited(boton: TextureButton, clave_boton: String):
	_aplicar_textura_normal(boton, clave_boton)

func _on_boton_idioma_mouse_entered(boton: TextureButton, clave_boton: String):
	_aplicar_hover_contrario_idioma(boton, clave_boton)

func _on_boton_idioma_mouse_exited(boton: TextureButton, clave_boton: String):
	_aplicar_textura_normal_idioma(boton, clave_boton)

func _aplicar_hover_contrario(boton: TextureButton, clave_boton: String):
	var modo_actual = ConfigManager.get_color_mode()
	var modo_contrario = "dark" if modo_actual == "light" else "light"
	
	if texturas_botones.has(modo_contrario) and texturas_botones[modo_contrario].has(clave_boton):
		var texture_path = texturas_botones[modo_contrario][clave_boton]
		var texture = load(texture_path)
		if texture:
			boton.texture_hover = texture
			print("🎯 Hover contrario aplicado: ", clave_boton, " -> ", modo_contrario)

func _aplicar_hover_contrario_idioma(boton: TextureButton, clave_boton: String):
	var modo_actual = ConfigManager.get_color_mode()
	var idioma_actual = ConfigManager.get_language()
	var modo_contrario = "dark" if modo_actual == "light" else "light"
	var clave_config_contraria = "%s_%s" % [idioma_actual, modo_contrario]
	
	if texturas_botones_idioma.has(clave_config_contraria) and texturas_botones_idioma[clave_config_contraria].has(clave_boton):
		var texture_path = texturas_botones_idioma[clave_config_contraria][clave_boton]
		var texture = load(texture_path)
		if texture:
			boton.texture_hover = texture
			print("🎯 Hover contrario idioma aplicado: ", clave_boton, " -> ", clave_config_contraria)

func _aplicar_textura_normal(boton: TextureButton, clave_boton: String):
	var modo_actual = ConfigManager.get_color_mode()
	
	if texturas_botones.has(modo_actual) and texturas_botones[modo_actual].has(clave_boton):
		var texture_path = texturas_botones[modo_actual][clave_boton]
		var texture = load(texture_path)
		if texture:
			boton.texture_normal = texture

func _aplicar_textura_normal_idioma(boton: TextureButton, clave_boton: String):
	var modo_actual = ConfigManager.get_color_mode()
	var idioma_actual = ConfigManager.get_language()
	var clave_config_actual = "%s_%s" % [idioma_actual, modo_actual]
	
	if texturas_botones_idioma.has(clave_config_actual) and texturas_botones_idioma[clave_config_actual].has(clave_boton):
		var texture_path = texturas_botones_idioma[clave_config_actual][clave_boton]
		var texture = load(texture_path)
		if texture:
			boton.texture_normal = texture

func _aplicar_configuracion():
	var modo = ConfigManager.get_color_mode()
	var idioma = ConfigManager.get_language()
	var clave_config = "%s_%s" % [idioma, modo]
	
	print("🎨 OptionsMenu: Aplicando configuración - Idioma: ", idioma, ", Modo: ", modo)
	
	# Aplicar fondo (depende de idioma y modo)
	_aplicar_fondo(clave_config)
	
	# Aplicar botones regulares (solo modo)
	_aplicar_botones(modo)
	
	# Aplicar botones de idioma (idioma y modo)
	_aplicar_botones_idioma(clave_config)
	
	# Aplicar checks de idioma (solo modo)
	_aplicar_checks_idioma(modo)
	
	# Actualizar hovers después de cambiar configuración
	_actualizar_todos_los_hovers()

func _actualizar_todos_los_hovers():
	# Actualizar hovers de botones regulares
	_actualizar_hover_boton(regresar, "regresar")
	_actualizar_hover_boton(modo_claro, "modo_claro")
	_actualizar_hover_boton(modo_oscuro, "modo_oscuro")
	_actualizar_hover_boton(sonido_on, "sonido_on")
	_actualizar_hover_boton(sonido_off, "sonido_off")
	
	# Actualizar hovers de botones de idioma
	_actualizar_hover_boton_idioma(idioma_espanol, "idioma_espanol")
	_actualizar_hover_boton_idioma(idioma_ingles, "idioma_ingles")

func _actualizar_hover_boton(boton: TextureButton, clave_boton: String):
	_aplicar_hover_contrario(boton, clave_boton)

func _actualizar_hover_boton_idioma(boton: TextureButton, clave_boton: String):
	_aplicar_hover_contrario_idioma(boton, clave_boton)

# ... (el resto de tus funciones existentes se mantienen igual)

func _aplicar_fondo(clave_config: String):
	if texturas_fondo.has(clave_config):
		var texture_path = texturas_fondo[clave_config]
		var texture = load(texture_path)
		if texture:
			background.texture = texture
			print("✅ Fondo aplicado: ", texture_path)
		else:
			print("❌ Error cargando fondo: ", texture_path)
	else:
		print("❌ Configuración no encontrada para fondo: ", clave_config)

func _aplicar_botones(modo: String):
	if texturas_botones.has(modo):
		var texturas_modo = texturas_botones[modo]
		
		# Aplicar texturas a botones regulares
		_aplicar_textura_boton(regresar, texturas_modo, "regresar")
		_aplicar_textura_boton(modo_claro, texturas_modo, "modo_claro")
		_aplicar_textura_boton(modo_oscuro, texturas_modo, "modo_oscuro")
		_aplicar_textura_boton(sonido_on, texturas_modo, "sonido_on")
		_aplicar_textura_boton(sonido_off, texturas_modo, "sonido_off")
		
		print("✅ Botones regulares aplicados - Modo: ", modo)
	else:
		print("❌ Modo no encontrado para botones regulares: ", modo)

func _aplicar_botones_idioma(clave_config: String):
	if texturas_botones_idioma.has(clave_config):
		var texturas_idioma = texturas_botones_idioma[clave_config]
		
		# Aplicar texturas a botones de idioma
		_aplicar_textura_boton(idioma_espanol, texturas_idioma, "idioma_espanol")
		_aplicar_textura_boton(idioma_ingles, texturas_idioma, "idioma_ingles")
		
		print("✅ Botones de idioma aplicados - Config: ", clave_config)
	else:
		print("❌ Configuración no encontrada para botones de idioma: ", clave_config)

func _aplicar_checks_idioma(modo: String):
	if texturas_checks.has(modo):
		var check_texture_path = texturas_checks[modo]
		var check_texture = load(check_texture_path)
		
		if check_texture:
			# Aplicar solo a los checks de idioma
			if check_espanol:
				check_espanol.texture = check_texture
			if check_ingles:
				check_ingles.texture = check_texture
			
			print("✅ Checks de idioma aplicados: ", check_texture_path)
		else:
			print("❌ Error cargando textura de check: ", check_texture_path)
	else:
		print("❌ Modo no encontrado para checks: ", modo)

func _aplicar_textura_boton(boton: TextureButton, texturas: Dictionary, clave: String):
	if boton and texturas.has(clave):
		var texture_path = texturas[clave]
		var texture = load(texture_path)
		if texture:
			boton.texture_normal = texture
		else:
			print("❌ Error cargando textura: ", texture_path, " para botón: ", clave)

# ===== FUNCIONALIDAD DE IDIOMA (Radio Buttons) =====
func _on_idioma_espanol_pressed():
	print("🌐 Idioma español presionado")
	ConfigManager.set_language("es")

func _on_idioma_ingles_pressed():
	print("🌐 Idioma inglés presionado")
	ConfigManager.set_language("en")

func _actualizar_botones_idioma():
	# Ocultar todos los checks de idioma primero
	if check_espanol:
		check_espanol.visible = false
	if check_ingles:
		check_ingles.visible = false
	
	# Mostrar solo el check del idioma activo
	match ConfigManager.get_language():
		"es":
			if check_espanol:
				check_espanol.visible = true
			print("✅ Idioma activo: Español")
		"en":
			if check_ingles:
				check_ingles.visible = true
			print("✅ Idioma activo: Inglés")

# ===== FUNCIONALIDAD DE MODO CLARO/OSCURO =====
func _on_modo_oscuro_pressed():
	print("🌙 Modo oscuro presionado")
	ConfigManager.set_color_mode("dark")

func _on_modo_claro_pressed():
	print("☀️ Modo claro presionado")
	ConfigManager.set_color_mode("light")

func _actualizar_estado_modo():
	match ConfigManager.get_color_mode():
		"light":
			print("✅ Modo activo: Claro")
		"dark":
			print("✅ Modo activo: Oscuro")

# ===== FUNCIONALIDAD DE SONIDO ON/OFF =====
func _on_sonido_on_pressed():
	print("🔊 Sonido ON presionado")
	ConfigManager.set_sound_volume(1.0)  # Volumen máximo

func _on_sonido_off_pressed():
	print("🔇 Sonido OFF presionado")
	ConfigManager.set_sound_volume(0.0)  # Silencio

func _actualizar_estado_sonido():
	if ConfigManager.get_sound_volume() > 0:
		print("✅ Sonido: Activado")
	else:
		print("✅ Sonido: Desactivado")

# ===== BOTÓN REGRESAR =====
func _on_regresar_pressed():
	print("🔙 Regresar al menú principal")
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/MainMenu.tscn")

# ===== MANEJADORES DE CAMBIOS DE CONFIGURACIÓN =====
func _on_config_changed(_value):
	print("🔄 OptionsMenu: Configuración cambiada - actualizando interfaz")
	_aplicar_configuracion()
	_actualizar_botones_idioma()
	_actualizar_estado_modo()
	_actualizar_estado_sonido()

func _on_sound_volume_changed(volume: float):
	print("🔊 Volumen de sonido cambiado: ", volume)
	_actualizar_estado_sonido()
