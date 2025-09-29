extends Area2D
class_name AreaExit

var is_open = false
# ¡IMPORTANTE! Verifica que esta ruta sea correcta
const PUZZLE_SCENE = preload("res://Assets/Scenes/puzzle.tscn") 

func _ready():
	close()

func open():
	is_open = true

func close():
	is_open = false

func _on_body_entered(body):
	if is_open and body is KaleidoController:
		# 1. Pausa el juego
		get_tree().paused = true 
		
		# 2. Crea y añade la ventana del puzzle
		var puzzle_instance = PUZZLE_SCENE.instantiate()
		get_tree().root.add_child(puzzle_instance)
		
		# 3. Conecta la señal de victoria del puzzle al GameManager
		if puzzle_instance.has_method("connect_win_signal"):
			# Llama a next_level en el GameManager cuando el puzzle se resuelve
			puzzle_instance.connect_win_signal(Callable(GameManager, "next_level"))
