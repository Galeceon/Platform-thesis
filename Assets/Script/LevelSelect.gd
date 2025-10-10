extends CanvasLayer

@onready var fondo: TextureRect = $Fondo
@onready var preview: TextureRect = $level
@onready var next_button: TextureButton = $next_button
@onready var back_button: TextureButton = $back_button1
@onready var play_button: TextureButton = $play_button   # el botón de jugar

# Arrays configurables desde el Inspector
@export var previews: Array[Texture2D] = []        # Miniaturas de los niveles
@export var fondos: Array[Texture2D] = []          # Fondos de los niveles
@export var level_scenes: Array[PackedScene] = []  # Escenas reales

var idx: int = 0   # Índice actual

func _ready() -> void:
	# Conexiones seguras de botones
	if next_button:
		next_button.pressed.connect(_on_next)
	if back_button:
		back_button.pressed.connect(_on_back)
	if play_button:
		play_button.pressed.connect(_on_play)

	update_ui()

func _on_next() -> void:
	print("NEXT pulsado, idx =", idx, " / total previews =", previews.size())
	if idx < previews.size() - 1:
		idx += 1
		update_ui()

func _on_back() -> void:
	print("BACK pulsado, idx =", idx)
	if idx > 0:
		idx -= 1
		update_ui()

func _on_play() -> void:
	print("PLAY pulsado en idx =", idx)
	if idx < level_scenes.size():
		var scene_to_load: PackedScene = level_scenes[idx]
		get_tree().change_scene_to_packed(scene_to_load)

func update_ui() -> void:
	print("Actualizando UI con idx =", idx)

	# Cambiar preview
	if idx < previews.size():
		preview.texture = previews[idx]
	else:
		preview.texture = null

	# Cambiar fondo
	if idx < fondos.size():
		fondo.texture = fondos[idx]
	else:
		fondo.texture = null

	# Desactivar botones si estamos en el límite
	next_button.disabled = idx >= previews.size() - 1
	back_button.disabled = idx <= 0
