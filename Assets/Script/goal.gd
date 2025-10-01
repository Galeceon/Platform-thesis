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

func _on_body_entered(body):
	if is_open and body is KaleidoController:
		print("Jugador tocó meta ABIERTA - iniciando puzzle")
		get_tree().paused = true 
		
		var puzzle_instance = PUZZLE_SCENE.instantiate()
		
		# BUSCAR la imagen en el nivel actual
		var puzzle_image_node = get_tree().get_first_node_in_group("puzzle_image")
		if puzzle_image_node and puzzle_image_node is TextureRect:
			puzzle_instance.level_image = puzzle_image_node.texture
		elif puzzle_image_node and puzzle_image_node is Sprite2D:
			puzzle_instance.level_image = puzzle_image_node.texture
		
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
