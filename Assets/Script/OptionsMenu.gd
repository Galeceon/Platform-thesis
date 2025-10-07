# OptionsMenu.gd
extends Control

# Referencias a los botones de idioma
@onready var idioma_espanol = $idioma_español
@onready var idioma_ingles = $idioma_ingles

# Referencias a los checks (debes agregarlos como nodos hijos de los botones de idioma)
@onready var check_espanol = $idioma_español/CheckMark
@onready var check_ingles = $idioma_ingles/CheckMark

# Referencias a los botones de modo y sonido
@onready var modo_oscuro = $modo_oscuro
@onready var modo_claro = $modo_claro
@onready var sonido_on = $sonido_on
@onready var sonido_off = $sonido_off
@onready var regresar = $regresar

# Variables de estado (simuladas por ahora)
var idioma_actual = "es"
var modo_actual = "light"
var sonido_actual = true

func _ready():
	# Conectar todas las señales
	_conectar_senales()
	
	# Inicializar el estado visual de los botones
	_actualizar_botones_idioma()
	_actualizar_botones_modo()
	_actualizar_botones_sonido()

func _conectar_senales():
	# Botones de idioma
	idioma_espanol.pressed.connect(_on_idioma_espanol_pressed)
	idioma_ingles.pressed.connect(_on_idioma_ingles_pressed)
	
	# Botones de modo
	modo_oscuro.pressed.connect(_on_modo_oscuro_pressed)
	modo_claro.pressed.connect(_on_modo_claro_pressed)
	
	# Botones de sonido
	sonido_on.pressed.connect(_on_sonido_on_pressed)
	sonido_off.pressed.connect(_on_sonido_off_pressed)
	
	# Botón regresar
	regresar.pressed.connect(_on_regresar_pressed)

# ===== FUNCIONALIDAD DE IDIOMA (Radio Buttons) =====
func _on_idioma_espanol_pressed():
	print("🌐 Idioma español presionado")
	idioma_actual = "es"
	ConfigManager.set_language("es")
	_actualizar_botones_idioma()

func _on_idioma_ingles_pressed():
	print("🌐 Idioma inglés presionado")
	idioma_actual = "en"
	ConfigManager.set_language("en")
	_actualizar_botones_idioma()

func _actualizar_botones_idioma():
	# Ocultar todos los checks primero
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
	modo_actual = "dark"
	ConfigManager.set_color_mode("dark")
	_actualizar_botones_modo()

func _on_modo_claro_pressed():
	print("☀️ Modo claro presionado")
	modo_actual = "light"
	ConfigManager.set_color_mode("light")
	_actualizar_botones_modo()

func _actualizar_botones_modo():
	match ConfigManager.get_color_mode():
		"light":
			print("✅ Modo activo: Claro")
		"dark":
			print("✅ Modo activo: Oscuro")

# ===== FUNCIONALIDAD DE SONIDO ON/OFF =====
func _on_sonido_on_pressed():
	print("🔊 Sonido ON presionado")
	sonido_actual = true
	ConfigManager.set_sound_volume(1.0)  # Volumen máximo
	_actualizar_botones_sonido()

func _on_sonido_off_pressed():
	print("🔇 Sonido OFF presionado")
	sonido_actual = false
	ConfigManager.set_sound_volume(0.0)  # Silencio
	_actualizar_botones_sonido()

func _actualizar_botones_sonido():
	if ConfigManager.get_sound_volume() > 0:
		print("✅ Sonido: Activado")
	else:
		print("✅ Sonido: Desactivado")

# ===== BOTÓN REGRESAR =====
func _on_regresar_pressed():
	print("🔙 Regresar al menú principal")
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/MainMenu.tscn")
