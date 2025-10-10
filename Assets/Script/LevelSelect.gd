extends CanvasLayer

@onready var fondo: TextureRect = $Fondo
@onready var preview: TextureRect = $level
@onready var next_button: TextureButton = $next_button
@onready var back_button: TextureButton = $back_button1
@onready var play_button: TextureButton = $play_button
@onready var p_atras_button: TextureButton = $p_atras_button
@onready var home_button: TextureButton = $home_button
@onready var config_button: TextureButton = $config_button

# Arrays configurables desde el Inspector
@export var previews: Array[Texture2D] = []        # Miniaturas de los niveles
@export var fondos: Array[Texture2D] = []          # Fondos de los niveles
@export var level_scenes: Array[PackedScene] = []  # Escenas reales

# Escenas adicionales (las de los botones extra)
@export var escena_anterior: PackedScene
@export var escena_home: PackedScene
@export var escena_config: PackedScene

var idx: int = 0   # Índice actual

func _ready() -> void:
	# Conexiones seguras de botones
	if next_button:
		next_button.pressed.connect(_on_next)
	if back_button:
		back_button.pressed.connect(_on_back)
	if play_button:
		play_button.pressed.connect(_on_play)

	# Botones extra
	if p_atras_button:
		p_atras_button.pressed.connect(_on_p_atras)
	if home_button:
		home_button.pressed.connect(_on_home)
	if config_button:
		config_button.pressed.connect(_on_config)

	update_ui()

# --- Navegación de previews ---

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
		var scene_to_load: PackedScene = level_scenes[idx]
		get_tree().change_scene_to_packed(scene_to_load)

# --- Botones adicionales ---
func _on_p_atras() -> void:
	if escena_anterior:
		get_tree().change_scene_to_packed(escena_anterior)

func _on_home() -> void:
	if escena_home:
		get_tree().change_scene_to_packed(escena_home)

func _on_config() -> void:
	if escena_config:
		get_tree().change_scene_to_packed(escena_config)

# --- Actualización visual ---
func update_ui() -> void:
	if idx < previews.size():
		preview.texture = previews[idx]
	else:
		preview.texture = null

	if idx < fondos.size():
		fondo.texture = fondos[idx]
	else:
		fondo.texture = null

	next_button.disabled = idx >= previews.size() - 1
	back_button.disabled = idx <= 0
