# MainMenu.gd
extends Control

# Referencias a los nodos
@onready var background = $TextureRect
@onready var jugar_button = $jugar_button
@onready var reanudar_button = $reanudar_button
@onready var como_jugar_button = $como_jugar_button
@onready var creditos_button = $creditos_button
@onready var config_button = $config_button
@onready var cerrar_button = $cerrar_button
var level_select_scene = preload("res://Assets/Scenes/UI/LevelSelect.tscn")

# Texturas para modo claro y oscuro
var texturas_fondo = {
	"light": "res://Assets/Sprites/UI/Pantallas de inicio/PANTALLA 2-03.jpg",
	"dark": "res://Assets/Sprites/UI/Pantallas de inicio/PANTALLA-NIGHT-MODE.jpg"
}

var texturas_botones = {
	"light": {
		"cerrar": "res://Assets/Sprites/UI/Botones/Modo Claro/cerrar.png",
		"config": "res://Assets/Sprites/UI/Botones/Modo Claro/configuracion.png"
	},
	"dark": {
		"cerrar": "res://Assets/Sprites/UI/Botones/Modo Oscuro/cerrar.png",
		"config": "res://Assets/Sprites/UI/Botones/Modo Oscuro/configuracion.png"
	}
}

var texturas_botones_texto = {
	"light": {
		"es": {
			"jugar": "res://Assets/Sprites/UI/Botones/Modo Claro/es_jugar.png",
			"reanudar": "res://Assets/Sprites/UI/Botones/Modo Claro/es_reanudar.png",
			"como_jugar": "res://Assets/Sprites/UI/Botones/Modo Claro/es_como_jugar.png",
			"creditos": "res://Assets/Sprites/UI/Botones/Modo Claro/es_creditos.png"
		},
		"en": {
			"jugar": "res://Assets/Sprites/UI/Botones/Modo Claro/en_jugar.png",
			"reanudar": "res://Assets/Sprites/UI/Botones/Modo Claro/en_reanudar.png",
			"como_jugar": "res://Assets/Sprites/UI/Botones/Modo Claro/en_como_jugar.png",
			"creditos": "res://Assets/Sprites/UI/Botones/Modo Claro/en_creditos.png"
		}
	},
	"dark": {
		"es": {
			"jugar": "res://Assets/Sprites/UI/Botones/Modo Oscuro/es_jugar.png",
			"reanudar": "res://Assets/Sprites/UI/Botones/Modo Oscuro/es_reanudar.png",
			"como_jugar": "res://Assets/Sprites/UI/Botones/Modo Oscuro/es_como_jugar.png",
			"creditos": "res://Assets/Sprites/UI/Botones/Modo Oscuro/es_creditos.png"
		},
		"en": {
			"jugar": "res://Assets/Sprites/UI/Botones/Modo Oscuro/en_jugar.png",
			"reanudar": "res://Assets/Sprites/UI/Botones/Modo Oscuro/en_reanudar.png",
			"como_jugar": "res://Assets/Sprites/UI/Botones/Modo Oscuro/en_como_jugar.png",
			"creditos": "res://Assets/Sprites/UI/Botones/Modo Oscuro/en_creditos.png"
		}
	}
}

# Variable para controlar si las señales ya están conectadas
var senales_conectadas = false

func _ready():
	# Conectar señales de los botones (solo si no están conectadas)
	_conectar_senales()
	
	# Conectar a cambios de configuración (solo una vez)
	if not ConfigManager.color_mode_changed.is_connected(_on_config_changed):
		ConfigManager.color_mode_changed.connect(_on_config_changed)
	if not ConfigManager.language_changed.is_connected(_on_config_changed):
		ConfigManager.language_changed.connect(_on_config_changed)
	
	# Aplicar configuración actual
	_aplicar_configuracion()
	
	# ACTUALIZADO: El botón Reanudar ahora está SIEMPRE ACTIVO
	_actualizar_boton_reanudar()

func _conectar_senales():
	# Si ya están conectadas, no hacer nada
	if senales_conectadas:
		return
	
	# Conectar señales solo si no están conectadas
	if not cerrar_button.pressed.is_connected(_on_cerrar_button_pressed):
		cerrar_button.pressed.connect(_on_cerrar_button_pressed)
	if not config_button.pressed.is_connected(_on_config_button_pressed):
		config_button.pressed.connect(_on_config_button_pressed)
	if not jugar_button.pressed.is_connected(_on_jugar_button_pressed):
		jugar_button.pressed.connect(_on_jugar_button_pressed)
	if not reanudar_button.pressed.is_connected(_on_reanudar_button_pressed):
		reanudar_button.pressed.connect(_on_reanudar_button_pressed)
	if not como_jugar_button.pressed.is_connected(_on_como_jugar_button_pressed):
		como_jugar_button.pressed.connect(_on_como_jugar_button_pressed)
	if not creditos_button.pressed.is_connected(_on_creditos_button_pressed):
		creditos_button.pressed.connect(_on_creditos_button_pressed)
	
	senales_conectadas = true
	print("✅ Señales del MainMenu conectadas")

func _aplicar_configuracion():
	var modo = ConfigManager.get_color_mode()
	var idioma = ConfigManager.get_language()
	
	print("🎨 Aplicando configuración - Modo: ", modo, ", Idioma: ", idioma)
	
	# Aplicar fondo
	_aplicar_fondo(modo)
	
	# Aplicar botones con texto
	_aplicar_botones_texto(modo, idioma)
	
	# Aplicar botones sin texto
	_aplicar_botones_sin_texto(modo)

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

func _aplicar_botones_texto(modo: String, idioma: String):
	if texturas_botones_texto.has(modo) and texturas_botones_texto[modo].has(idioma):
		var texturas_idioma = texturas_botones_texto[modo][idioma]
		
		# Aplicar texturas a cada botón
		_aplicar_textura_boton(jugar_button, texturas_idioma, "jugar")
		_aplicar_textura_boton(reanudar_button, texturas_idioma, "reanudar")
		_aplicar_textura_boton(como_jugar_button, texturas_idioma, "como_jugar")
		_aplicar_textura_boton(creditos_button, texturas_idioma, "creditos")
		
		print("✅ Botones de texto aplicados - Modo: ", modo, ", Idioma: ", idioma)
	else:
		print("❌ Combinación no encontrada - Modo: ", modo, ", Idioma: ", idioma)

func _aplicar_botones_sin_texto(modo: String):
	if texturas_botones.has(modo):
		var texturas_modo = texturas_botones[modo]
		
		# Aplicar botones sin texto
		_aplicar_textura_boton(cerrar_button, texturas_modo, "cerrar")
		_aplicar_textura_boton(config_button, texturas_modo, "config")
		
		print("✅ Botones sin texto aplicados - Modo: ", modo)
	else:
		print("❌ Modo no encontrado para botones sin texto: ", modo)

func _aplicar_textura_boton(boton: TextureButton, texturas: Dictionary, clave: String):
	if not boton or not texturas.has(clave):
		return
	
	var texture_path = texturas[clave]
	var texture = load(texture_path)
	if texture:
		boton.texture_normal = texture
	
	var modo_actual = ConfigManager.get_color_mode()
	var idioma_actual = ConfigManager.get_language()
	var modo_opuesto = "light" if modo_actual == "dark" else "dark"
	
	var textura_hover_path = null

	# 🔹 Si el botón tiene texto (como jugar, reanudar, etc.)
	if clave in ["jugar", "reanudar", "como_jugar", "creditos"]:
		# Buscar textura hover del mismo idioma pero modo opuesto
		if texturas_botones_texto.has(modo_opuesto):
			var dict_opuesto = texturas_botones_texto[modo_opuesto]
			if dict_opuesto.has(idioma_actual) and dict_opuesto[idioma_actual].has(clave):
				textura_hover_path = dict_opuesto[idioma_actual][clave]
	
	# 🔹 Si el botón es "config" o "cerrar", buscar en los botones sin texto
	elif clave in ["config", "cerrar"]:
		if texturas_botones.has(modo_opuesto) and texturas_botones[modo_opuesto].has(clave):
			textura_hover_path = texturas_botones[modo_opuesto][clave]

	# 🔹 Aplicar hover si existe
	if textura_hover_path:
		var hover_texture = load(textura_hover_path)
		if hover_texture:
			boton.texture_hover = hover_texture

func _actualizar_boton_reanudar():
	# ACTUALIZADO: El botón Reanudar ahora está SIEMPRE ACTIVO
	reanudar_button.disabled = false
	
	var nivel_desbloqueado = ConfigManager.get_unlocked_levels()
	print("🔓 Botón Reanudar SIEMPRE ACTIVO - Nivel desbloqueado: ", nivel_desbloqueado)

func _on_config_changed(_value):
	print("🔄 Configuración cambiada - actualizando Main Menu")
	_aplicar_configuracion()

# Señales de los botones - MODIFICADAS
func _on_cerrar_button_pressed():
	print("🚪 Cerrando juego...")
	get_tree().quit()

func _on_jugar_button_pressed():
	# Lleva a la selección de personajes
	print("🎭 Abriendo selección de personajes...")
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/CharacterSelect.tscn")

func _on_reanudar_button_pressed():
	# Lleva a la selección de niveles (siempre activo)
	print("🎮 Abriendo selección de niveles...")
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/LevelSelect.tscn")

func _on_como_jugar_button_pressed():
	print("❓ Abriendo Cómo Jugar...")
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/HowToPlay.tscn")

func _on_creditos_button_pressed():
	print("👥 Abriendo Créditos...")
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/Credits.tscn")

func _on_config_button_pressed():
	print("⚙️ Abriendo Configuración...")
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/OptionsMenu.tscn")
