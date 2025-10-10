extends Control

@onready var background = $Background
@onready var texture_button = $Background/TextureButton

func _ready():
	# Verificar que los nodos existen
	if background == null:
		print("❌ Error: Nodo Background no encontrado")
	if texture_button == null:
		print("❌ Error: Nodo TextureButton no encontrado")
		return
	
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
	if background == null:
		return
		
	var language = ConfigManager.get_language()
	
	# Construir la ruta de la textura
	var texture_path = "res://Assets/Sprites/UI/Pantallas Finales/resumen_%s.png" % language
	var texture = load(texture_path)
	
	if texture:
		background.texture = texture
		print("✅ Fondo resumen cargado: ", texture_path)
	else:
		print("❌ Error cargando fondo resumen: ", texture_path)

func _update_button_texture():
	if texture_button == null:
		return
		
	var color_mode = ConfigManager.get_color_mode()
	
	# Usar operador ternario para los nombres diferentes
	var button_name = "es_inicio.png" if color_mode == "light" else "inicio.png"
	var texture_path = "res://Assets/Sprites/UI/Botones/Modo %s/%s" % [
		"Claro" if color_mode == "light" else "Oscuro", 
		button_name
	]
	
	var texture = load(texture_path)
	
	if texture:
		texture_button.texture_normal = texture
		print("✅ Botón inicio cargado: ", texture_path)
	else:
		print("❌ Error cargando botón inicio: ", texture_path)

func _on_texture_button_pressed():
	# Cambia esta línea por la escena que corresponda
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/MainMenu.tscn")
