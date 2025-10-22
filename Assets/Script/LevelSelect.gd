extends CanvasLayer

@onready var fondo: TextureRect = $Fondo
@onready var preview: TextureRect = $level
@onready var next_button: TextureButton = $next_button
@onready var back_button: TextureButton = $back_button1
@onready var play_button: TextureButton = $play_button
@onready var p_atras_button: TextureButton = $p_atras_button
@onready var home_button: TextureButton = $home_button
@onready var config_button: TextureButton = $config_button

@onready var config_manager: Node = get_node("/root/ConfigManager")

# Miniaturas y escenas configuradas desde el inspector
@export var previews: Array[Texture2D] = []
@export var level_scenes: Array[PackedScene] = []

var idx: int = 0
var current_mode: String
var current_lang: String

# Texturas para el botón "Jugar" en diferentes modos e idiomas
var texturas_play_button = {
	"light": {
		"es": "res://Assets/Sprites/UI/Botones/Modo Claro/es_jugar.png",
		"en": "res://Assets/Sprites/UI/Botones/Modo Claro/en_jugar.png"
	},
	"dark": {
		"es": "res://Assets/Sprites/UI/Botones/Modo Oscuro/es_jugar.png",
		"en": "res://Assets/Sprites/UI/Botones/Modo Oscuro/en_jugar.png"
	}
}

# Texturas para los otros botones (sin texto)
var texturas_botones_sin_texto = {
	"light": {
		"next": "res://Assets/Sprites/UI/Botones/Modo Claro/derecha.png",
		"back": "res://Assets/Sprites/UI/Botones/Modo Claro/izquierda.png",
		"home": "res://Assets/Sprites/UI/Botones/Modo Claro/es_inicio.png",
		"config": "res://Assets/Sprites/UI/Botones/Modo Claro/configuracion.png",
		"p_atras": "res://Assets/Sprites/UI/Botones/Modo Claro/regresar.png"
	},
	"dark": {
		"next": "res://Assets/Sprites/UI/Botones/Modo Oscuro/derecha.png",
		"back": "res://Assets/Sprites/UI/Botones/Modo Oscuro/izquierda.png",
		"home": "res://Assets/Sprites/UI/Botones/Modo Oscuro/inicio.png",
		"config": "res://Assets/Sprites/UI/Botones/Modo Oscuro/configuracion.png",
		"p_atras": "res://Assets/Sprites/UI/Botones/Modo Oscuro/regresar.png"
	}
}

func _ready() -> void:
	# Verificar que todos los nodos existen
	_verificar_nodos()
	
	current_mode = config_manager.get_color_mode()
	current_lang = config_manager.get_language()

	# Escuchar cambios en tiempo real
	config_manager.color_mode_changed.connect(_on_color_mode_changed)
	config_manager.language_changed.connect(_on_language_changed)

	# Conectar botones
	if next_button: next_button.pressed.connect(_on_next)
	if back_button: back_button.pressed.connect(_on_back)
	if play_button: play_button.pressed.connect(_on_play)
	if p_atras_button: p_atras_button.pressed.connect(_on_p_atras)
	if home_button: home_button.pressed.connect(_on_home)
	if config_button: config_button.pressed.connect(_on_config)

	update_ui()

# --- Verificar que todos los nodos existen ---
func _verificar_nodos():
	print("🔍 Verificando nodos del LevelSelect:")
	print("   Fondo: ", fondo != null)
	print("   Preview: ", preview != null)
	print("   Next Button: ", next_button != null)
	print("   Back Button: ", back_button != null)
	print("   Play Button: ", play_button != null)
	print("   P Atrás Button: ", p_atras_button != null)
	print("   Home Button: ", home_button != null)
	print("   Config Button: ", config_button != null)
	
	# Si el fondo no existe, intentar encontrarlo por otro nombre
	if fondo == null:
		fondo = find_child("TextureRect") as TextureRect
		if fondo:
			print("✅ Fondo encontrado como 'TextureRect'")
		else:
			# Buscar cualquier TextureRect
			var texture_rects = get_tree().get_nodes_in_group("texture_rects")
			if texture_rects.size() > 0:
				fondo = texture_rects[0] as TextureRect
				print("✅ Fondo encontrado en grupo 'texture_rects'")
			else:
				print("❌ No se pudo encontrar el nodo Fondo")

# --- Actualiza idioma o modo en tiempo real ---
func _on_color_mode_changed(new_mode: String) -> void:
	current_mode = new_mode
	update_ui()

func _on_language_changed(new_lang: String) -> void:
	current_lang = new_lang
	update_ui()

# --- Navegación ---
func _on_next() -> void:
	if idx < previews.size() - 1:
		idx += 1
		update_ui()

func _on_back() -> void:
	if idx > 0:
		idx -= 1
		update_ui()

# En LevelSelect.gd - MODIFICAR la función _on_play()
func _on_play() -> void:
	if idx < level_scenes.size():
		var nivel_seleccionado = idx + 1  # Convertir índice a número de nivel (1, 2, 3, 4)
		print("🎮 LevelSelect: Cargando nivel ", nivel_seleccionado, " con pantalla de carga")
		
		# Actualizar current_area en GameManager
		GameManager.current_area = nivel_seleccionado
		print("✅ GameManager.current_area actualizado a: ", GameManager.current_area)
		
		# Verificar si es un nuevo juego (nivel 1) o continuación
		if nivel_seleccionado == 1 and ConfigManager.get_unlocked_levels() == 1:
			print("🎬 Iniciando nuevo juego desde Level Select - reproduciendo cinemática")
			GameManager.start_new_game()  # ← CON CINEMÁTICA para nuevo juego
		else:
			print("🎮 Continuando juego desde Level Select")
			GameManager.load_level(nivel_seleccionado, true)  # ← SIN CINEMÁTICA para continuar

# --- Botones adicionales ---
func _on_p_atras() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/MainMenu.tscn")

func _on_config() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/OptionsMenu.tscn")

func _on_home() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/MainMenu.tscn")

# --- Carga dinámica de fondos y botones ---
func update_ui() -> void:
	# Actualiza preview
	if preview and idx < previews.size():
		preview.texture = previews[idx]
	elif preview:
		preview.texture = null

	# Cargar fondo correcto según idioma y modo - CON VERIFICACIÓN
	if fondo:
		var fondo_path = "res://Assets/Sprites/UI/Pantallas de carga/%02d_%s_%s.png" % [idx + 1, current_lang, current_mode]
		if ResourceLoader.exists(fondo_path):
			var texture = load(fondo_path)
			if texture:
				fondo.texture = texture
				print("✅ Fondo cargado: ", fondo_path)
			else:
				print("❌ Error cargando textura del fondo: ", fondo_path)
				fondo.texture = null
		else:
			print("⚠️ Fondo no encontrado: ", fondo_path)
			fondo.texture = null
	else:
		print("❌ Nodo fondo es null - no se puede cargar fondo")

	# Actualizar botones
	_actualizar_botones()

	# Actualizar visibilidad y estado de los botones basado en niveles desbloqueados
	_actualizar_estado_botones_navegacion()

# --- Actualizar estado de botones basado en niveles desbloqueados ---
func _actualizar_estado_botones_navegacion():
	var niveles_desbloqueados = ConfigManager.get_unlocked_levels()
	var nivel_actual = idx + 1  # idx empieza en 0, niveles empiezan en 1
	
	print("🎮 Nivel actual: ", nivel_actual, " | Niveles desbloqueados: ", niveles_desbloqueados)
	
	# Botón derecho (siguiente) - invisible si no hay más niveles adelante O si el siguiente nivel no está desbloqueado
	if next_button:
		var hay_siguiente_nivel = (idx < previews.size() - 1)
		var siguiente_nivel_desbloqueado = (nivel_actual + 1 <= niveles_desbloqueados)
		
		next_button.visible = hay_siguiente_nivel and siguiente_nivel_desbloqueado
		print("➡️  Botón siguiente - Visible: ", next_button.visible, 
			  " | Hay siguiente: ", hay_siguiente_nivel, 
			  " | Siguiente desbloqueado: ", siguiente_nivel_desbloqueado)
	
	# Botón izquierdo (anterior) - invisible si estamos en el primer nivel
	if back_button:
		back_button.visible = (idx > 0)
		print("⬅️  Botón anterior - Visible: ", back_button.visible)
	
	# Botón JUGAR - deshabilitado si el nivel actual no está desbloqueado
	if play_button:
		var nivel_actual_desbloqueado = (nivel_actual <= niveles_desbloqueados)
		play_button.disabled = not nivel_actual_desbloqueado
		
		if nivel_actual_desbloqueado:
			play_button.modulate = Color.WHITE
			print("🎮 Botón JUGAR - HABILITADO (Nivel ", nivel_actual, " desbloqueado)")
		else:
			play_button.modulate = Color.GRAY
			print("🔒 Botón JUGAR - DESHABILITADO (Nivel ", nivel_actual, " bloqueado)")

# --- Actualizar texturas de todos los botones ---
func _actualizar_botones():
	# Actualizar botón "Jugar" (con texto)
	if play_button:
		_aplicar_textura_boton(play_button, texturas_play_button, "play")

	# Actualizar botones sin texto (solo si son visibles)
	if next_button and next_button.visible:
		_aplicar_textura_boton(next_button, texturas_botones_sin_texto, "next")
	if back_button and back_button.visible:
		_aplicar_textura_boton(back_button, texturas_botones_sin_texto, "back")
	if home_button:
		_aplicar_textura_boton(home_button, texturas_botones_sin_texto, "home")
	if config_button:
		_aplicar_textura_boton(config_button, texturas_botones_sin_texto, "config")
	if p_atras_button:
		_aplicar_textura_boton(p_atras_button, texturas_botones_sin_texto, "p_atras")

# --- Función para aplicar texturas a botones ---
func _aplicar_textura_boton(boton: TextureButton, texturas_dict: Dictionary, clave: String):
	if not boton:
		return
	
	var texture_path = null
	
	# Determinar la ruta de la textura según el tipo de botón
	if clave == "play":
		# Botón con texto (depende de modo e idioma)
		if texturas_dict.has(current_mode) and texturas_dict[current_mode].has(current_lang):
			texture_path = texturas_dict[current_mode][current_lang]
	else:
		# Botones sin texto (solo dependen del modo)
		if texturas_dict.has(current_mode) and texturas_dict[current_mode].has(clave):
			texture_path = texturas_dict[current_mode][clave]
	
	# Cargar y aplicar textura normal
	if texture_path and ResourceLoader.exists(texture_path):
		var texture = load(texture_path)
		if texture:
			boton.texture_normal = texture
			print("✅ Textura aplicada a ", clave, ": ", texture_path)
		else:
			print("❌ Error cargando textura: ", texture_path)
	else:
		print("⚠️ Textura no encontrada: ", texture_path)
	
	# Aplicar textura hover (modo opuesto)
	_aplicar_textura_hover(boton, clave)

# --- Aplicar textura hover (modo opuesto) ---
func _aplicar_textura_hover(boton: TextureButton, clave: String):
	var modo_opuesto = "light" if current_mode == "dark" else "dark"
	var hover_texture_path = null
	
	if clave == "play":
		# Botón con texto - hover del modo opuesto mismo idioma
		if texturas_play_button.has(modo_opuesto) and texturas_play_button[modo_opuesto].has(current_lang):
			hover_texture_path = texturas_play_button[modo_opuesto][current_lang]
	else:
		# Botones sin texto - hover del modo opuesto
		if texturas_botones_sin_texto.has(modo_opuesto) and texturas_botones_sin_texto[modo_opuesto].has(clave):
			hover_texture_path = texturas_botones_sin_texto[modo_opuesto][clave]
	
	# Cargar y aplicar textura hover
	if hover_texture_path and ResourceLoader.exists(hover_texture_path):
		var hover_texture = load(hover_texture_path)
		if hover_texture:
			boton.texture_hover = hover_texture
