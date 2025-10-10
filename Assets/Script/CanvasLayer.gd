extends CanvasLayer  

@onready var preview: TextureRect = $level
@onready var next_button: TextureButton = $next_button
@onready var back_button: TextureButton = $back_button1

@export var previews: Array[Texture2D] = []

var idx: int = 0

func _ready() -> void:
	next_button.pressed.connect(_on_next)
	back_button.pressed.connect(_on_back)
	update_ui()

func _on_next() -> void:
	if idx < previews.size() - 1:
		idx += 1
		update_ui()

func _on_back() -> void:
	if idx > 0:
		idx -= 1
		update_ui()

func update_ui() -> void:
	if previews.size() > 0:
		preview.texture = previews[idx]
	else:
		preview.texture = null
