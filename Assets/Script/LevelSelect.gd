extends CanvasLayer

@onready var fondo: TextureRect = $Fondo
@onready var preview: TextureRect = $level
@onready var next_button: TextureButton = $next_button
@onready var back_button: TextureButton = $back_button1
@onready var play_button: TextureButton = $play_button
@onready var p_atras_button: TextureButton = $p_atras_button
@onready var home_button: TextureButton = $home_button
@onready var config_button: TextureButton = $config_button

@onready var config_manager: Node = get_node("/root/ConfigManager")

# Miniaturas y escenas configuradas desde el inspector
@export var previews: Array[Texture2D] = []
@export var level_scenes: Array[PackedScene] = []

var idx: int = 0
var current_mode: String
var current_lang: String

func _ready() -> void:
	current_mode = config_manager.get_color_mode()
	current_lang = config_manager.get_language()

	# Escuchar cambios en tiempo real
	config_manager.color_mode_changed.connect(_on_color_mode_changed)
	config_manager.language_changed.connect(_on_language_changed)

	# Conectar botones
	if next_button: next_button.pressed.connect(_on_next)
	if back_button: back_button.pressed.connect(_on_back)
	if play_button: play_button.pressed.connect(_on_play)
	if p_atras_button: p_atras_button.pressed.connect(_on_p_atras)
	if home_button: home_button.pressed.connect(_on_home)
	if config_button: config_button.pressed.connect(_on_config)

	update_ui()

# --- Actualiza idioma o modo en tiempo real ---
func _on_color_mode_changed(new_mode: String) -> void:
	current_mode = new_mode
	update_ui()

func _on_language_changed(new_lang: String) -> void:
	current_lang = new_lang
	update_ui()

# --- Navegación ---
func _on_next() -> void:
	if idx < previews.size() - 1:
		idx += 1
		update_ui()

func _on_back() -> void:
	if idx > 0:
		idx -= 1
		update_ui()

# --- Botón JUGAR ---
func _on_play() -> void:
	if idx < level_scenes.size():
		get_tree().change_scene_to_packed(level_scenes[idx])

# --- Botones adicionales ---
func _on_p_atras() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/MainMenu.tscn")

func _on_config() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/OptionsMenu.tscn")

func _on_home() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/MainMenu.tscn")

# --- Carga dinámica de fondos ---
func update_ui() -> void:
	# Actualiza preview
	if idx < previews.size():
		preview.texture = previews[idx]
	else:
		preview.texture = null

	# Cargar fondo correcto según idioma y modo
	var fondo_path = "res://Assets/Sprites/UI/Pantallas de carga/%02d_%s_%s.png" % [idx + 1, current_lang, current_mode]
	if ResourceLoader.exists(fondo_path):
		fondo.texture = load(fondo_path)
	else:
		print("⚠️ Fondo no encontrado: ", fondo_path)
		fondo.texture = null

	# Desactivar botones si es necesario
	next_button.disabled = idx >= previews.size() - 1
	back_button.disabled = idx <= 0
