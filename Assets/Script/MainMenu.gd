extends Control


func _on_cerrar_button_pressed():
	get_tree().quit()

func _on_jugar_button_pressed():
	GameManager.start_new_game()

func _on_reanudar_button_pressed():
	GameManager.continue_game()

func _on_creditos_button_pressed():
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/Credits.tscn")

func _on_config_button_pressed():
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/OptionsMenu.tscn")
