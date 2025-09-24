extends Node

var current_area = 1
var area_path = "res://Assets/Scenes/Areas/0"
var coins = 0

func _ready():
	reset_coins()

func next_level():
	current_area += 1
	var full_path= area_path + str(current_area) + ".tscn"
	get_tree().change_scene_to_file(full_path)
	area_setup()

func area_setup():
	reset_coins()

func add_coin():
	coins += 1
	if coins >= 50:
		var goal = get_tree().get_first_node_in_group("goals") as AreaExit
		goal.open()

func reset_coins():
	coins = 0
