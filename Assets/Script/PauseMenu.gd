extends CanvasLayer

@onready var background = $Background
@onready var close_button = $Background/close_button
@onready var home_button = $Background/home_button

# Texturas para el fondo del menú de pausa - EXPANDIDO PARA IDIOMAS
var background_textures = {
	"light": {
		"es": "res://Assets/Sprites/UI/Pausa/pausa_es_light.png",
		"en": "res://Assets/Sprites/UI/Pausa/pausa_en_light.png"
	},
	"dark": {
		"es": "res://Assets/Sprites/UI/Pausa/pausa_es_dark.png",
		"en": "res://Assets/Sprites/UI/Pausa/pausa_en_dark.png"
	}
}

# Texturas para los botones - AHORA CON HOVER
var button_textures = {
	"light": {
		"close": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Claro/cerrar.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Oscuro/cerrar.png"
		},
		"home": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Claro/es_inicio.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Oscuro/inicio.png"
		}
	},
	"dark": {
		"close": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Oscuro/cerrar.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Claro/cerrar.png"
		},
		"home": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Oscuro/inicio.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Claro/es_inicio.png"
		}
	}
}

func _ready():
	# Aplicar configuración inicial
	_apply_configuration()
	
	# Conectar señales de los botones
	close_button.pressed.connect(_on_close_pressed)
	home_button.pressed.connect(_on_home_pressed)
	
	# Conectar señales de hover
	close_button.mouse_entered.connect(_on_close_button_mouse_entered)
	close_button.mouse_exited.connect(_on_close_button_mouse_exited)
	home_button.mouse_entered.connect(_on_home_button_mouse_entered)
	home_button.mouse_exited.connect(_on_home_button_mouse_exited)
	
	# Conectar a cambios de configuración
	ConfigManager.color_mode_changed.connect(_on_config_changed)
	ConfigManager.language_changed.connect(_on_config_changed)
	
	print("✅ Menú de pausa cargado - En árbol: ", is_inside_tree())

func _apply_configuration():
	var mode = ConfigManager.get_color_mode()
	var language = ConfigManager.get_language()
	
	# Aplicar fondo - AHORA CON IDIOMA
	if background_textures.has(mode) and background_textures[mode].has(language):
		var texture_path = background_textures[mode][language]
		var texture = load(texture_path)
		if texture:
			background.texture = texture
		else:
			print("❌ No se pudo cargar textura: ", texture_path)
	
	# Aplicar botones CON HOVER
	if button_textures.has(mode):
		var buttons = button_textures[mode]
		
		if buttons.has("close"):
			var close_textures = buttons["close"]
			var close_normal = load(close_textures["normal"])
			var close_hover = load(close_textures["hover"])
			
			if close_normal:
				close_button.texture_normal = close_normal
			if close_hover:
				close_button.texture_hover = close_hover
		
		if buttons.has("home"):
			var home_textures = buttons["home"]
			var home_normal = load(home_textures["normal"])
			var home_hover = load(home_textures["hover"])
			
			if home_normal:
				home_button.texture_normal = home_normal
			if home_hover:
				home_button.texture_hover = home_hover

func _on_config_changed(_value):
	_apply_configuration()

# Señales de hover para debug
func _on_close_button_mouse_entered():
	print("🖱️ Hover en botón cerrar")

func _on_close_button_mouse_exited():
	print("🖱️ Hover fuera de botón cerrar")

func _on_home_button_mouse_entered():
	print("🖱️ Hover en botón inicio")

func _on_home_button_mouse_exited():
	print("🖱️ Hover fuera de botón inicio")

func _on_close_pressed():
	print("🎮 Cerrando menú de pausa")
	close_pause_menu()

func _on_home_pressed():
	print("🏠 Volviendo al menú principal desde pausa")
	# Reanudar todo antes de cambiar de escena
	close_pause_menu()
	
	# Usar call_deferred para evitar problemas con el árbol de escena
	call_deferred("_change_to_main_menu")

func _change_to_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/MainMenu.tscn")

func open_pause_menu():
	print("⏸️ Abriendo menú de pausa")
	
	# VERIFICAR que estamos en el árbol de escena
	if not is_inside_tree():
		print("❌ PauseMenu no está en el árbol de escena - intentando recuperar...")
		# Intentar agregarse al árbol si es posible
		if get_parent() == null:
			get_tree().root.add_child(self)
			print("🔄 PauseMenu agregado al árbol raíz")
	
	# Verificar nuevamente
	if not is_inside_tree():
		print("❌❌ No se pudo agregar PauseMenu al árbol")
		return
	
	# Pausar el juego
	get_tree().paused = true
	
	# Detener el tiempo del GameManager
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_method("detener_tiempo"):
		game_manager.detener_tiempo()
	
	# Mostrar el menú
	show()
	
	# Hacer que este menú procese input incluso cuando el juego está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("✅ Menú de pausa abierto correctamente")

func close_pause_menu():
	print("▶️ Cerrando menú de pausa")
	
	# Ocultar el menú
	hide()
	
	# VERIFICAR que estamos en el árbol de escena antes de reanudar
	if not is_inside_tree():
		print("❌ PauseMenu no está en el árbol de escena")
		return
	
	# Reanudar el juego
	get_tree().paused = false
	
	# Reanudar el tiempo del GameManager (solo si estamos en un nivel válido)
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_method("iniciar_tiempo") and _is_valid_level():
		game_manager.iniciar_tiempo()

# Verificar si estamos en un nivel válido (01-05)
func _is_valid_level() -> bool:
	var game_manager = get_node_or_null("/root/GameManager")
	if not game_manager:
		return false
	
	var current_level = game_manager.current_area
	return current_level >= 1 and current_level <= 5

# Input para el menú de pausa (funciona incluso con el juego pausado)
func _input(event):
	if event.is_action_pressed("ui_cancel") and visible:  # ESC para cerrar
		close_pause_menu()
		get_viewport().set_input_as_handled()
