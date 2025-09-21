extends Node

var current_area = 1
var area_path = "res://Assets/Scenes/Areas/0"

func next_level():
	current_area += 1
	var full_path= area_path + str(current_area) + ".tscn"
	get_tree().change_scene_to_file(full_path)
	print("Siguientiola")
