# OptionsMenu.gd
extends Node2D  # ← CAMBIA de BaseMenu a Node2D

# Referencias a los Sprites
@onready var background = $Background
@onready var sun_button = $SunButton
@onready var moon_button = $MoonButton
@onready var es_button = $ESButton
@onready var en_button = $ENButton
@onready var sound_on_button = $SoundOnButton
@onready var sound_off_button = $SoundOffButton
@onready var back_button = $BackButton

# Texturas PRELOADED (igual que antes)
var sun_light = preload("res://Assets/Sprites/UI/Botones/Modo Claro/modo_claro.png")
var sun_dark = preload("res://Assets/Sprites/UI/Botones/Modo Oscuro/modo_claro.png")
var moon_light = preload("res://Assets/Sprites/UI/Botones/Modo Claro/modo_oscuro.png")
var moon_dark = preload("res://Assets/Sprites/UI/Botones/Modo Oscuro/modo_oscuro.png")
var es_light = preload("res://Assets/Sprites/UI/Configuracion/en_español_light.png")
var en_light = preload("res://Assets/Sprites/UI/Configuracion/en_ingles_light.png")
var es_dark = preload("res://Assets/Sprites/UI/Configuracion/en_español_dark.png")
var en_dark = preload("res://Assets/Sprites/UI/Configuracion/en_ingles_dark.png")
var sound_on_light = preload("res://Assets/Sprites/UI/Botones/Modo Claro/sonido_on.png")
var sound_off_light = preload("res://Assets/Sprites/UI/Botones/Modo Claro/sonido_off.png")
var sound_on_dark = preload("res://Assets/Sprites/UI/Botones/Modo Oscuro/sound_on.png")
var sound_off_dark = preload("res://Assets/Sprites/UI/Botones/Modo Oscuro/sound_off.png")
var back_light = preload("res://Assets/Sprites/UI/Botones/Modo Claro/regresar.png")
var back_dark = preload("res://Assets/Sprites/UI/Botones/Modo Oscuro/regresar.png")
var background_es_light = preload("res://Assets/Sprites/UI/Configuracion/config_es_light.png")
var background_es_dark = preload("res://Assets/Sprites/UI/Configuracion/config_es_dark.png")
var background_en_light = preload("res://Assets/Sprites/UI/Configuracion/config_en_light.png")
var background_en_dark = preload("res://Assets/Sprites/UI/Configuracion/config_en_dark.png")

# Variables para navegación
var buttons: Array[Sprite2D] = []
var current_button_index: int = 0

func _ready():
	# Recolectar todos los botones
	buttons = [sun_button, moon_button, es_button, en_button, sound_on_button, sound_off_button, back_button]
	setup_ui()
	ConfigManager.color_mode_changed.connect(_on_color_mode_changed)
	ConfigManager.language_changed.connect(_on_language_changed)

func _input(event):
	# Navegación con teclado
	if event.is_action_pressed("move_up"):
		current_button_index = wrapi(current_button_index - 1, 0, buttons.size())
		update_button_selection()
	elif event.is_action_pressed("move_down"):
		current_button_index = wrapi(current_button_index + 1, 0, buttons.size())
		update_button_selection()
	elif event.is_action_pressed("jump") or event.is_action_pressed("ui_accept"):
		_on_button_pressed(buttons[current_button_index])

func update_button_selection():
	for i in range(buttons.size()):
		if i == current_button_index:
			buttons[i].modulate = Color(1.2, 1.2, 1.2)  # Resaltar
		else:
			buttons[i].modulate = Color(1, 1, 1)  # Normal

func _on_button_pressed(button: Sprite2D):
	if button == sun_button:
		ConfigManager.set_color_mode("light")
	elif button == moon_button:
		ConfigManager.set_color_mode("dark")
	elif button == es_button:
		ConfigManager.set_language("es")
	elif button == en_button:
		ConfigManager.set_language("en")
	elif button == sound_on_button:
		ConfigManager.set_sound_volume(1.0)
	elif button == sound_off_button:
		ConfigManager.set_sound_volume(0.0)
	elif button == back_button:
		get_tree().change_scene_to_file("res://Assets/Scenes/UI/MainMenu.tscn")

# Detección de clic del mouse
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		for i in range(buttons.size()):
			var button = buttons[i]
			# Verificar si el click fue dentro del área del sprite
			if button.get_rect().has_point(button.to_local(event.position)):
				current_button_index = i
				_on_button_pressed(button)
				break

func setup_ui():
	update_all_ui()

func update_all_ui():
	var is_light_mode = ConfigManager.get_color_mode() == "light"
	var current_lang = ConfigManager.get_language()
	
	update_background(current_lang, is_light_mode)
	update_color_mode_buttons(is_light_mode)
	update_language_buttons(is_light_mode, current_lang)
	update_sound_buttons(is_light_mode)
	update_back_button(is_light_mode)
	update_button_selection()

func update_background(language: String, is_light_mode: bool):
	if background:
		match language:
			"es":
				background.texture = background_es_light if is_light_mode else background_es_dark
			"en":
				background.texture = background_en_light if is_light_mode else background_en_dark

func update_color_mode_buttons(is_light_mode: bool):
	if is_light_mode:
		sun_button.texture = sun_light
		moon_button.texture = moon_light
	else:
		sun_button.texture = sun_dark
		moon_button.texture = moon_dark

func update_language_buttons(is_light_mode: bool, current_lang: String):
	if is_light_mode:
		es_button.texture = es_light
		en_button.texture = en_light
	else:
		es_button.texture = es_dark
		en_button.texture = en_dark

func update_sound_buttons(is_light_mode: bool):
	if is_light_mode:
		sound_on_button.texture = sound_on_light
		sound_off_button.texture = sound_off_light
	else:
		sound_on_button.texture = sound_on_dark
		sound_off_button.texture = sound_off_dark

func update_back_button(is_light_mode: bool):
	if is_light_mode:
		back_button.texture = back_light
	else:
		back_button.texture = back_dark

func _on_color_mode_changed(mode: String):
	update_all_ui()

func _on_language_changed(lang: String):
	update_all_ui()
