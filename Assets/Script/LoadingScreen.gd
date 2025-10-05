# LoadingScreen.gd
extends CanvasLayer

@onready var background = $Background

func set_level(level_number: int):
	var texture_path = "res://Assets/Sprites/UI/Pantallas de carga/%02d.png" % level_number
	var texture = load(texture_path)
	
	if texture:
		background.texture = texture
		print("LoadingScreen: Cargada pantalla del nivel ", level_number)
	else:
		# Fallback
		var fallback_path = "res://Assets/Sprites/UI/Pantallas de carga/01.png"
		background.texture = load(fallback_path)
		print("LoadingScreen: ERROR - No se encontró ", texture_path, ", usando fallback")
