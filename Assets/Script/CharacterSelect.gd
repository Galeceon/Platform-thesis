extends Node2D

@onready var fondo: TextureRect = $Fondo
@onready var color_texture: TextureRect = $color  # Muestra el nombre del color seleccionado
@onready var character_sprite: TextureRect = $Character
@onready var atras_button: TextureButton = $Atras_Button
@onready var jugar_button: TextureButton = $jugar_button
@onready var next_button: TextureButton = $next_button
@onready var prev_button: TextureButton = $prev_button

var main_menu_scene = preload("res://Assets/Scenes/UI/MainMenu.tscn")

# Configuración de colores disponibles
var colors = ["Naranja", "Rojo", "Azul", "Verde"]  # Orden de navegación
var current_color_index: int = 0

# Rutas de texturas para el fondo
var background_paths = {
	"light": "res://Assets/Sprites/UI/pantalla_seleccion/ModoClaro.png",
	"dark": "res://Assets/Sprites/UI/pantalla_seleccion/ModoOscuro.png"
}

# Rutas de texturas para el TextureRect que muestra el nombre del color
var color_name_paths = {
	"es": {
		"Naranja": "res://Assets/Sprites/UI/Botones/Seleccion/Naranja.png",
		"Rojo": "res://Assets/Sprites/UI/Botones/Seleccion/Rojo.png", 
		"Azul": "res://Assets/Sprites/UI/Botones/Seleccion/Azul.png",
		"Verde": "res://Assets/Sprites/UI/Botones/Seleccion/Verde.png"
	},
	"en": {
		"Naranja": "res://Assets/Sprites/UI/Botones/Seleccion/Orange.png",
		"Rojo": "res://Assets/Sprites/UI/Botones/Seleccion/Red.png",
		"Azul": "res://Assets/Sprites/UI/Botones/Seleccion/Blue.png",
		"Verde": "res://Assets/Sprites/UI/Botones/Seleccion/Green.png"
	}
}

# Rutas de sprites del personaje
var character_paths = {
	"Naranja": "res://Assets/Sprites/kaleido/Select_Naranja.png",
	"Rojo": "res://Assets/Sprites/kaleido/Select_Rojo.png",
	"Azul": "res://Assets/Sprites/kaleido/Select_Azul.png",
	"Verde": "res://Assets/Sprites/kaleido/Select_Verde.png"
}

# Mapeo de colores a skin IDs
var color_to_id = {
	"Naranja": 1,
	"Rojo": 2, 
	"Azul": 3,
	"Verde": 4
}

# Texturas para botones con texto (Jugar)
var jugar_button_paths = {
	"light": {
		"es": "res://Assets/Sprites/UI/Botones/Modo Claro/es_jugar.png",
		"en": "res://Assets/Sprites/UI/Botones/Modo Claro/en_jugar.png"
	},
	"dark": {
		"es": "res://Assets/Sprites/UI/Botones/Modo Oscuro/es_jugar.png",
		"en": "res://Assets/Sprites/UI/Botones/Modo Oscuro/en_jugar.png"
	}
}

# Texturas para botones sin texto (navegación y atrás)
var button_paths_no_text = {
	"light": {
		"next": "res://Assets/Sprites/UI/Botones/Modo Claro/derecha.png",
		"prev": "res://Assets/Sprites/UI/Botones/Modo Claro/izquierda.png",
		"atras": "res://Assets/Sprites/UI/Botones/Modo Claro/regresar.png"
	},
	"dark": {
		"next": "res://Assets/Sprites/UI/Botones/Modo Oscuro/derecha.png",
		"prev": "res://Assets/Sprites/UI/Botones/Modo Oscuro/izquierda.png",
		"atras": "res://Assets/Sprites/UI/Botones/Modo Oscuro/regresar.png"
	}
}

func _ready():
	# Verificar que todos los nodos existen
	_verificar_nodos()
	
	# Configurar índice inicial basado en la skin actual
	current_color_index = _get_initial_color_index()
	
	# Conectar señales
	ConfigManager.color_mode_changed.connect(_on_color_mode_changed)
	ConfigManager.language_changed.connect(_on_language_changed)
	ConfigManager.character_skin_changed.connect(_on_character_skin_changed)
	
	# Conectar botones
	atras_button.pressed.connect(_on_back_pressed)
	jugar_button.pressed.connect(_on_jugar_pressed)
	next_button.pressed.connect(_on_next_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	
	# Actualizar UI inicial
	update_ui()
	
	print("✅ Selección de personajes inicializada - Color actual:", colors[current_color_index])

func _verificar_nodos():
	print("🔍 Verificando nodos de Selección de Personajes:")
	print("   Fondo:", fondo != null)
	print("   Color Texture:", color_texture != null)
	print("   Character:", character_sprite != null)
	print("   Atrás Button:", atras_button != null)
	print("   Jugar Button:", jugar_button != null)
	print("   Next Button:", next_button != null)
	print("   Prev Button:", prev_button != null)

func _get_initial_color_index() -> int:
	var current_skin = ConfigManager.get_character_skin()
	for i in range(colors.size()):
		if color_to_id[colors[i]] == current_skin:
			return i
	return 0  # Por defecto Naranja

func _on_color_mode_changed(mode: String):
	update_ui()

func _on_language_changed(lang: String):
	update_ui()

func _on_character_skin_changed(skin_id: int):
	# Actualizar índice si la skin cambió desde otro lugar
	for i in range(colors.size()):
		if color_to_id[colors[i]] == skin_id:
			current_color_index = i
			update_ui()
			break

func _on_next_pressed():
	if current_color_index < colors.size() - 1:
		current_color_index += 1
		_save_selection()
		update_ui()
		print("➡️ Siguiente color:", colors[current_color_index])

func _on_prev_pressed():
	if current_color_index > 0:
		current_color_index -= 1
		_save_selection()
		update_ui()
		print("⬅️ Color anterior:", colors[current_color_index])

func _save_selection():
	var selected_color = colors[current_color_index]
	var skin_id = color_to_id[selected_color]
	ConfigManager.set_character_skin(skin_id)
	print("💾 Skin guardada:", selected_color, " (ID:", skin_id, ")")

func update_ui():
	var current_mode = ConfigManager.get_color_mode()
	var current_lang = ConfigManager.get_language()
	var current_color = colors[current_color_index]
	
	# Actualizar fondo
	_actualizar_fondo(current_mode)
	
	# Actualizar nombre del color (TextureRect)
	_actualizar_nombre_color(current_color, current_lang)
	
	# Actualizar sprite del personaje
	_actualizar_personaje(current_color)
	
	# Actualizar botones
	_actualizar_botones(current_mode, current_lang)
	
	# Actualizar estado de botones de navegación
	_actualizar_estado_navegacion()

func _actualizar_fondo(mode: String):
	if fondo and background_paths.has(mode):
		var texture = load(background_paths[mode])
		if texture:
			fondo.texture = texture

func _actualizar_nombre_color(color: String, lang: String):
	if color_texture and color_name_paths.has(lang) and color_name_paths[lang].has(color):
		var texture_path = color_name_paths[lang][color]
		var texture = load(texture_path)
		if texture:
			color_texture.texture = texture
			print("✅ Nombre de color actualizado:", color, " (", lang, ")")
		else:
			print("❌ No se pudo cargar textura:", texture_path)

func _actualizar_personaje(color: String):
	if character_sprite and character_paths.has(color):
		var texture = load(character_paths[color])
		if texture:
			character_sprite.texture = texture
			print("🎨 Sprite de personaje actualizado:", color)

func _actualizar_botones(mode: String, lang: String):
	# Botón Jugar (con texto)
	if jugar_button:
		_aplicar_textura_boton(jugar_button, jugar_button_paths, "jugar", mode, lang)
	
	# Botones sin texto
	if atras_button:
		_aplicar_textura_boton(atras_button, button_paths_no_text, "atras", mode, lang)
	if next_button:
		_aplicar_textura_boton(next_button, button_paths_no_text, "next", mode, lang)
	if prev_button:
		_aplicar_textura_boton(prev_button, button_paths_no_text, "prev", mode, lang)

func _aplicar_textura_boton(boton: TextureButton, texturas_dict: Dictionary, clave: String, mode: String, lang: String):
	if not boton:
		return
	
	var texture_path = null
	
	# Determinar la ruta según el tipo de botón
	if clave == "jugar":
		# Botón con texto (depende de modo e idioma)
		if texturas_dict.has(mode) and texturas_dict[mode].has(lang):
			texture_path = texturas_dict[mode][lang]
	else:
		# Botones sin texto (solo dependen del modo)
		if texturas_dict.has(mode) and texturas_dict[mode].has(clave):
			texture_path = texturas_dict[mode][clave]
	
	# Cargar y aplicar textura normal
	if texture_path and ResourceLoader.exists(texture_path):
		var texture = load(texture_path)
		if texture:
			boton.texture_normal = texture
		else:
			print("❌ Error cargando textura:", texture_path)
	else:
		print("⚠️ Textura no encontrada:", texture_path)
	
	# Aplicar textura hover (modo opuesto)
	_aplicar_textura_hover(boton, clave, mode, lang)

func _aplicar_textura_hover(boton: TextureButton, clave: String, mode: String, lang: String):
	var modo_opuesto = "light" if mode == "dark" else "dark"
	var hover_texture_path = null
	
	if clave == "jugar":
		# Botón con texto - hover del modo opuesto mismo idioma
		if jugar_button_paths.has(modo_opuesto) and jugar_button_paths[modo_opuesto].has(lang):
			hover_texture_path = jugar_button_paths[modo_opuesto][lang]
	else:
		# Botones sin texto - hover del modo opuesto
		if button_paths_no_text.has(modo_opuesto) and button_paths_no_text[modo_opuesto].has(clave):
			hover_texture_path = button_paths_no_text[modo_opuesto][clave]
	
	# Cargar y aplicar textura hover
	if hover_texture_path and ResourceLoader.exists(hover_texture_path):
		var hover_texture = load(hover_texture_path)
		if hover_texture:
			boton.texture_hover = hover_texture

func _actualizar_estado_navegacion():
	# Botón siguiente - invisible si estamos en el último color
	if next_button:
		next_button.visible = (current_color_index < colors.size() - 1)
		print("➡️  Botón siguiente - Visible:", next_button.visible)
	
	# Botón anterior - invisible si estamos en el primer color
	if prev_button:
		prev_button.visible = (current_color_index > 0)
		print("⬅️  Botón anterior - Visible:", prev_button.visible)

func _on_jugar_pressed():
	print("🎮 Iniciando nuevo juego desde selección de personajes...")
	
	# 1. Guardar selección final por si acaso
	_save_selection()
	
	# 2. Resetear progreso del juego
	ConfigManager.config["unlocked_levels"] = 1
	ConfigManager.save_config()
	print("✅ Progreso reseteado - Solo nivel 1 desbloqueado")
	
	# 3. Iniciar el juego CON CINEMÁTICA (cambiar esta línea)
	GameManager.start_new_game()  # ← ESTA ES LA LÍNEA CLAVE
	print("✅ Iniciando juego con cinemática...")

func _on_back_pressed():
	print("🔙 Volviendo al menú principal...")
	get_tree().change_scene_to_packed(main_menu_scene)
