# LevelCompleteScreen.gd
extends CanvasLayer

@onready var background = $Background
@onready var points_label = $Background/PointsLabel
@onready var time_label = $Background/TimeLabel
@onready var continue_button = $Background/ContinueButton
@onready var home_button = $Background/HomeButton

# Texturas para el fondo
var background_textures = {
	"light": "res://Assets/Sprites/UI/Pantalla culminacion/culm_light.png",
	"dark": "res://Assets/Sprites/UI/Pantalla culminacion/culm_dark.png"
}

# Texturas para los botones (con idioma y modo)
var button_textures = {
	"light": {
		"continue": {
			"es": "res://Assets/Sprites/UI/Botones/Modo Claro/es_reanudar.png",
			"en": "res://Assets/Sprites/UI/Botones/Modo Claro/en_reanudar.png"
		},
		"home": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Claro/es_inicio.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Oscuro/inicio.png"
		}
	},
	"dark": {
		"continue": {
			"es": "res://Assets/Sprites/UI/Botones/Modo Oscuro/es_reanudar.png",
			"en": "res://Assets/Sprites/UI/Botones/Modo Oscuro/en_reanudar.png"
		},
		"home": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Oscuro/inicio.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Claro/es_inicio.png"
		}
	}
}

var main_menu_scene = preload("res://Assets/Scenes/UI/MainMenu.tscn")

func _ready():
	# Aplicar configuración inicial
	_apply_configuration()
	
	# Configurar tamaño de fuente para los labels
	_setup_labels()
	
	# Conectar señales de los botones
	continue_button.pressed.connect(_on_continue_pressed)
	home_button.pressed.connect(_on_home_pressed)
	
	# Conectar señales de hover
	continue_button.mouse_entered.connect(_on_continue_button_mouse_entered)
	continue_button.mouse_exited.connect(_on_continue_button_mouse_exited)
	home_button.mouse_entered.connect(_on_home_button_mouse_entered)
	home_button.mouse_exited.connect(_on_home_button_mouse_exited)
	
	# Conectar a cambios de configuración
	ConfigManager.color_mode_changed.connect(_on_config_changed)
	ConfigManager.language_changed.connect(_on_config_changed)
	
	# Ocultar inicialmente
	hide()

func _setup_labels():
	# Configurar tamaño de fuente más grande para los labels
	points_label.add_theme_font_size_override("font_size", 30)
	time_label.add_theme_font_size_override("font_size", 30)
	
	# Centrar el texto
	points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Color del texto
	points_label.add_theme_color_override("font_color", Color.WHITE)
	time_label.add_theme_color_override("font_color", Color.WHITE)
	
	print("✅ Labels configurados con tamaño grande")

func _apply_configuration():
	var mode = ConfigManager.get_color_mode()
	var language = ConfigManager.get_language()
	
	# Aplicar fondo
	if background_textures.has(mode):
		var texture_path = background_textures[mode]
		var texture = load(texture_path)
		if texture:
			background.texture = texture
			print("✅ Fondo de culminación aplicado: ", texture_path)
		else:
			print("❌ No se pudo cargar textura de fondo: ", texture_path)
	
	# Aplicar botón continuar (con idioma y hover)
	if button_textures.has(mode) and button_textures[mode].has("continue"):
		var continue_textures = button_textures[mode]["continue"]
		if continue_textures.has(language):
			var continue_texture_path = continue_textures[language]
			var continue_texture = load(continue_texture_path)
			if continue_texture:
				continue_button.texture_normal = continue_texture
				print("✅ Botón continuar aplicado: ", continue_texture_path)
				
				# Aplicar hover (modo opuesto mismo idioma)
				var modo_opuesto = "light" if mode == "dark" else "dark"
				if button_textures.has(modo_opuesto) and button_textures[modo_opuesto].has("continue"):
					var continue_hover_textures = button_textures[modo_opuesto]["continue"]
					if continue_hover_textures.has(language):
						var hover_texture_path = continue_hover_textures[language]
						var hover_texture = load(hover_texture_path)
						if hover_texture:
							continue_button.texture_hover = hover_texture
							print("✅ Hover de continuar aplicado: ", hover_texture_path)
		else:
			print("❌ No se encontró textura de continuar para idioma: ", language)
	
	# Aplicar botón home (sin idioma, con hover)
	if button_textures.has(mode) and button_textures[mode].has("home"):
		var home_textures = button_textures[mode]["home"]
		var home_normal = load(home_textures["normal"])
		var home_hover = load(home_textures["hover"])
		
		if home_normal:
			home_button.texture_normal = home_normal
		if home_hover:
			home_button.texture_hover = home_hover

func _on_config_changed(_value):
	_apply_configuration()

# Señales de hover
func _on_continue_button_mouse_entered():
	print("🖱️ Hover en botón continuar")

func _on_continue_button_mouse_exited():
	print("🖱️ Hover fuera de botón continuar")

func _on_home_button_mouse_entered():
	print("🖱️ Hover en botón home")

func _on_home_button_mouse_exited():
	print("🖱️ Hover fuera de botón home")

# ===== FUNCIONALIDAD DE BOTONES =====
func _on_continue_pressed():
	print("🎮 Continuando al siguiente nivel")
	close_level_complete_screen()
	_load_next_level()

func _on_home_pressed():
	print("🏠 Volviendo al menú principal desde pantalla de culminación")
	close_level_complete_screen()
	call_deferred("_change_to_main_menu")

func _change_to_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu_scene)

# ===== FUNCIONES DE APERTURA/CIERRE =====
func open_level_complete_screen():
	print("🏆 Abriendo pantalla de culminación de nivel")
	
	# VERIFICAR que estamos en el árbol de escena (igual que en PauseMenu)
	if not is_inside_tree():
		print("❌ LevelCompleteScreen no está en el árbol de escena - intentando recuperar...")
		if get_parent() == null:
			get_tree().root.add_child(self)
			print("🔄 LevelCompleteScreen agregado al árbol raíz")
	
	# Verificar nuevamente
	if not is_inside_tree():
		print("❌❌ No se pudo agregar LevelCompleteScreen al árbol")
		return
	
	# Pausar el juego
	get_tree().paused = true
	
	# Detener el tiempo del GameManager (igual que en PauseMenu)
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_method("detener_tiempo"):
		game_manager.detener_tiempo()
		print("⏰ Tiempo detenido - pantalla de culminación activada")
	else:
		print("❌ No se pudo detener el tiempo - GameManager no encontrado")
	
	# Actualizar labels con datos actuales
	_update_display_data()
	
	# Mostrar la pantalla
	show()
	
	# Hacer que procese input incluso cuando el juego está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("✅ Pantalla de culminación abierta correctamente")

func close_level_complete_screen():
	print("🎯 Cerrando pantalla de culminación")
	
	# Ocultar la pantalla
	hide()
	
	# VERIFICAR que estamos en el árbol de escena antes de reanudar (igual que en PauseMenu)
	if not is_inside_tree():
		print("❌ LevelCompleteScreen no está en el árbol de escena")
		return
	
	# Reanudar el juego
	get_tree().paused = false
	
	# Reanudar el tiempo del GameManager (solo si estamos en un nivel válido) - igual que en PauseMenu
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_method("iniciar_tiempo") and _is_valid_level():
		game_manager.iniciar_tiempo()
		print("⏰ Tiempo reanudado - pantalla de culminación cerrada")

# Verificar si estamos en un nivel válido (01-05) - igual que en PauseMenu
func _is_valid_level() -> bool:
	var game_manager = get_node_or_null("/root/GameManager")
	if not game_manager:
		return false
	
	var current_level = game_manager.current_area
	return current_level >= 1 and current_level <= 5

func _update_display_data():
	var game_manager = get_node_or_null("/root/GameManager")
	if not game_manager:
		print("❌ No se encontró GameManager para actualizar datos")
		return
	
	# Obtener puntaje actual
	var current_points = game_manager.puntaje
	
	# Calcular tiempo transcurrido (tiempo total - tiempo restante)
	var elapsed_time = 300 - game_manager.tiempo_restante  # 300 segundos totales - tiempo restante
	
	# Formatear tiempo en minutos:segundos
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	var time_text = "%02d:%02d" % [minutes, seconds]
	
	# Actualizar labels
	points_label.text = str(current_points)
	time_label.text = time_text
	
	print("📊 Datos mostrados - Puntos: ", current_points, " Tiempo: ", time_text)
	print("⏰ Tiempo restante en GameManager: ", game_manager.tiempo_restante)

func _load_next_level():
	var game_manager = get_node_or_null("/root/GameManager")
	if not game_manager:
		print("❌ No se encontró GameManager")
		return
	
	# Desbloquear el siguiente nivel ANTES de cargarlo
	var next_level = game_manager.current_area + 1
	if next_level <= 5:  # Asegurar que no exceda el nivel máximo
		ConfigManager.unlock_level(next_level)
		print("🔓 Nivel ", next_level, " desbloqueado")
	
	# Cargar el siguiente nivel con pantalla de carga
	game_manager.load_level(next_level, true)
