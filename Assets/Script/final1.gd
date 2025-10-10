extends Control

@onready var background = $Background
@onready var texture_button = $Background/TextureButton

func _ready():
	# Conectar a las señales del ConfigManager
	ConfigManager.color_mode_changed.connect(_on_config_changed)
	ConfigManager.language_changed.connect(_on_config_changed)
	
	# Aplicar la configuración actual
	_update_background_texture()
	_update_button_texture()

func _on_config_changed(_value = null):
	# Actualizar texturas cuando cambie la configuración
	_update_background_texture()
	_update_button_texture()

func _update_background_texture():
	var language = ConfigManager.get_language()
	var color_mode = ConfigManager.get_color_mode()
	
	# Construir la ruta de la textura
	var texture_path = "res://Assets/Sprites/UI/Pantallas Finales/final_%s_%s.png" % [language, color_mode]
	var texture = load(texture_path)
	
	if texture:
		background.texture = texture
		print("✅ Fondo final cargado: ", texture_path)
	else:
		print("❌ Error cargando fondo final: ", texture_path)

func _update_button_texture():
	var color_mode = ConfigManager.get_color_mode()
	
	# Construir la ruta de la textura del botón
	var texture_path = "res://Assets/Sprites/UI/Botones/Modo %s/regresar.png" % ["Claro" if color_mode == "light" else "Oscuro"]
	var texture = load(texture_path)
	
	if texture:
		texture_button.texture_normal = texture
		print("✅ Botón regresar cargado: ", texture_path)
	else:
		print("❌ Error cargando botón regresar: ", texture_path)

func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/final2.tscn")
