# AreaExit.gd
extends Area2D
class_name AreaExit

var is_open = false
const PUZZLE_SCENE = preload("res://Assets/Scenes/puzzle.tscn") 

func _ready():
	close()  # Asegurar que empiece cerrada
	add_to_group("goals")  # ¡IMPORTANTE! Asegurar que esté en el grupo

func open():
	is_open = true
	print("Meta ABRIERTA - is_open = ", is_open)

func close():
	is_open = false
	print("Meta CERRADA - is_open = ", is_open)

# AreaExit.gd - modificar la función _on_body_entered
func _on_body_entered(body):
	if is_open and body is KaleidoController:
		print("Jugador tocó meta ABIERTA - iniciando puzzle")
		get_tree().paused = true 
		
		var puzzle_instance = PUZZLE_SCENE.instantiate()
		
		# El puzzle ahora obtiene el nivel automáticamente del GameManager
		# No necesitamos pasar la imagen manualmente
		
		get_tree().root.add_child(puzzle_instance)
		
		if puzzle_instance.has_method("connect_win_signal"):
			puzzle_instance.connect_win_signal(Callable(GameManager, "next_level"))
	else:
		print("Jugador tocó meta CERRADA - is_open = ", is_open)

func close_all_goals():
	var goals = get_tree().get_nodes_in_group("goals")
	print("Cerrando ", goals.size(), " metas")
	for goal in goals:
		if goal is AreaExit:
			goal.close()
