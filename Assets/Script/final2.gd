extends Control

@onready var background = $Background
@onready var home_button = $Background/home_button
@onready var level_select_button = $Background/level_select_button
@onready var next_button = $Background/next_button
@onready var prev_button = $Background/prev_button

var current_page = 1
var total_pages = 4

# Texturas para los botones
var button_textures = {
	"light": {
		"home": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Claro/es_inicio.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Oscuro/inicio.png"
		},
		"level_select": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Claro/es_menu.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Oscuro/menu.png"
		},
		"next": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Claro/derecha.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Oscuro/derecha.png"
		},
		"prev": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Claro/izquierda.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Oscuro/izquierda.png"
		}
	},
	"dark": {
		"home": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Oscuro/inicio.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Claro/es_inicio.png"
		},
		"level_select": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Oscuro/menu.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Claro/es_menu.png"
		},
		"next": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Oscuro/derecha.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Claro/derecha.png"
		},
		"prev": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Oscuro/izquierda.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Claro/izquierda.png"
		}
	}
}

func _ready():
	# Verificar que los nodos existen
	if background == null:
		print("❌ Error: Nodo Background no encontrado")
	if home_button == null:
		print("❌ Error: Nodo home_button no encontrado")
	if level_select_button == null:
		print("❌ Error: Nodo level_select_button no encontrado")
	if next_button == null:
		print("❌ Error: Nodo next_button no encontrado")
	if prev_button == null:
		print("❌ Error: Nodo prev_button no encontrado")
	
	# Conectar señales de los botones
	home_button.pressed.connect(_on_home_pressed)
	level_select_button.pressed.connect(_on_level_select_pressed)
	next_button.pressed.connect(_on_next_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	
	# Conectar señales de hover
	home_button.mouse_entered.connect(_on_home_hover)
	home_button.mouse_exited.connect(_on_home_exit)
	level_select_button.mouse_entered.connect(_on_level_select_hover)
	level_select_button.mouse_exited.connect(_on_level_select_exit)
	next_button.mouse_entered.connect(_on_next_hover)
	next_button.mouse_exited.connect(_on_next_exit)
	prev_button.mouse_entered.connect(_on_prev_hover)
	prev_button.mouse_exited.connect(_on_prev_exit)
	
	# Conectar a las señales del ConfigManager
	ConfigManager.color_mode_changed.connect(_on_config_changed)
	ConfigManager.language_changed.connect(_on_config_changed)
	
	# Aplicar la configuración inicial
	_update_background_texture()
	_update_button_textures()
	_update_button_visibility()

func _on_config_changed(_value = null):
	# Actualizar texturas cuando cambie la configuración
	_update_background_texture()
	_update_button_textures()

func _update_background_texture():
	if background == null:
		return
		
	var language = ConfigManager.get_language()
	
	# Construir la ruta de la textura con formato de página
	var texture_path = "res://Assets/Sprites/UI/Pantallas Finales/%s_%02d.png" % [language, current_page]
	var texture = load(texture_path)
	
	if texture:
		background.texture = texture
		print("✅ Fondo página %d cargado: %s" % [current_page, texture_path])
	else:
		print("❌ Error cargando fondo página %d: %s" % [current_page, texture_path])

func _update_button_textures():
	var color_mode = ConfigManager.get_color_mode()
	
	if not button_textures.has(color_mode):
		print("❌ Modo de color no encontrado: ", color_mode)
		return
	
	var textures = button_textures[color_mode]
	
	# Aplicar texturas a cada botón
	_apply_button_texture(home_button, textures["home"])
	_apply_button_texture(level_select_button, textures["level_select"])
	_apply_button_texture(next_button, textures["next"])
	_apply_button_texture(prev_button, textures["prev"])

func _apply_button_texture(button: TextureButton, textures: Dictionary):
	if button == null:
		return
	
	var normal_texture = load(textures["normal"])
	var hover_texture = load(textures["hover"])
	
	if normal_texture:
		button.texture_normal = normal_texture
	if hover_texture:
		button.texture_hover = hover_texture

func _update_button_visibility():
	# Ocultar/mostrar botones según la página actual
	if prev_button:
		prev_button.visible = (current_page > 1)
	
	if next_button:
		next_button.visible = (current_page < total_pages)

# ===== FUNCIONALIDAD DE PAGINACIÓN =====
func _on_next_pressed():
	if current_page < total_pages:
		current_page += 1
		_update_background_texture()
		_update_button_visibility()
		print("➡️ Página cambiada a: ", current_page)

func _on_prev_pressed():
	if current_page > 1:
		current_page -= 1
		_update_background_texture()
		_update_button_visibility()
		print("⬅️ Página cambiada a: ", current_page)

# ===== FUNCIONALIDAD DE BOTONES =====
func _on_home_pressed():
	print("🏠 Volviendo al menú principal")
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/MainMenu.tscn")

func _on_level_select_pressed():
	print("🎯 Yendo al selector de niveles")
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/LevelSelect.tscn")

# ===== SEÑALES DE HOVER =====
func _on_home_hover():
	print("🖱️ Hover en botón home")

func _on_home_exit():
	print("🖱️ Hover fuera de botón home")

func _on_level_select_hover():
	print("🖱️ Hover en botón level select")

func _on_level_select_exit():
	print("🖱️ Hover fuera de botón level select")

func _on_next_hover():
	print("🖱️ Hover en botón next")

func _on_next_exit():
	print("🖱️ Hover fuera de botón next")

func _on_prev_hover():
	print("🖱️ Hover en botón prev")

func _on_prev_exit():
	print("🖱️ Hover fuera de botón prev")
