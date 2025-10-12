extends Node

@onready var fondo = $Fondo
@onready var rojo_button = $RojoButton
@onready var naranja_button = $NaranjaButton
@onready var azul_button = $AzulButton
@onready var verde_button = $VerdeButton
@onready var character_sprite = $Character
@onready var atras_button = $Atras_Button
@onready var jugar_button = $jugar_button  # NUEVO: Botón Jugar
@onready var main_menu_scene = preload("res://Assets/Scenes/UI/MainMenu.tscn")

var background_paths = {
	"light": "res://Assets/Sprites/UI/pantalla_seleccion/ModoClaro.png",
	"dark": "res://Assets/Sprites/UI/pantalla_seleccion/ModoOscuro.png"
}

var button_paths = {
	"es": {
		"Rojo": "res://Assets/Sprites/UI/Botones/Seleccion/Rojo.png",
		"Naranja": "res://Assets/Sprites/UI/Botones/Seleccion/Naranja.png",
		"Azul": "res://Assets/Sprites/UI/Botones/Seleccion/Azul.png",
		"Verde": "res://Assets/Sprites/UI/Botones/Seleccion/Verde.png"
	},
	"en": {
		"Rojo": "res://Assets/Sprites/UI/Botones/Seleccion/Red.png",
		"Naranja": "res://Assets/Sprites/UI/Botones/Seleccion/Orange.png",
		"Azul": "res://Assets/Sprites/UI/Botones/Seleccion/Blue.png",
		"Verde": "res://Assets/Sprites/UI/Botones/Seleccion/Green.png"
	}
}

var character_paths = {
	"Rojo": "res://Assets/Sprites/kaleido/Select_Rojo.png",
	"Naranja": "res://Assets/Sprites/kaleido/Select_Naranja.png",
	"Azul": "res://Assets/Sprites/kaleido/Select_Azul.png",
	"Verde": "res://Assets/Sprites/kaleido/Select_Verde.png"
}

var back_button_paths = {
	"light": {
		"normal": "res://Assets/Sprites/UI/Botones/Modo Claro/regresar.png",
		"hover": "res://Assets/Sprites/UI/Botones/Modo Oscuro/regresar.png"
	},
	"dark": {
		"normal": "res://Assets/Sprites/UI/Botones/Modo Oscuro/regresar.png",
		"hover": "res://Assets/Sprites/UI/Botones/Modo Claro/regresar.png"
	}
}

# NUEVO: Texturas para el botón Jugar
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

func _ready():
	# Aplicar configuración inicial
	_apply_color_mode(ConfigManager.get_color_mode())
	_apply_language(ConfigManager.get_language())
	_apply_character_skin(ConfigManager.get_character_skin())
	
	# Conectar señales del ConfigManager
	ConfigManager.color_mode_changed.connect(_apply_color_mode)
	ConfigManager.language_changed.connect(_apply_language)
	ConfigManager.character_skin_changed.connect(_apply_character_skin)
	
	# Conectar botones
	atras_button.pressed.connect(_on_back_pressed)
	jugar_button.pressed.connect(_on_jugar_pressed)  # NUEVO: Conectar botón Jugar

	# Conectar botones de selección de color
	rojo_button.pressed.connect(func(): _on_color_selected("Rojo"))
	naranja_button.pressed.connect(func(): _on_color_selected("Naranja"))
	azul_button.pressed.connect(func(): _on_color_selected("Azul"))
	verde_button.pressed.connect(func(): _on_color_selected("Verde"))

	# 🧩 DEPURACIÓN — Verifica si los botones están visibles y con textura
	print("🟡 RojoButton visible:", rojo_button.visible)
	print("🟢 Textura RojoButton:", rojo_button.texture_normal)
	print("🟠 NaranjaButton visible:", naranja_button.visible)
	print("🔵 AzulButton visible:", azul_button.visible)
	print("🟢 VerdeButton visible:", verde_button.visible)
	print("🎮 JugarButton visible:", jugar_button.visible)  # NUEVO: Debug botón Jugar

func _apply_color_mode(mode: String):
	if not fondo: return
	if background_paths.has(mode):
		fondo.texture = load(background_paths[mode])
	else:
		print("⚠️ Fondo no encontrado para modo:", mode)
	
	# Configurar el botón Atrás
	if atras_button and back_button_paths.has(mode):
		var back_data = back_button_paths[mode]
		atras_button.texture_normal = load(back_data["normal"])
		atras_button.texture_hover = load(back_data["hover"])
	
	# NUEVO: Configurar el botón Jugar
	if jugar_button and jugar_button_paths.has(mode):
		var current_lang = ConfigManager.get_language()
		var jugar_texture_path = jugar_button_paths[mode][current_lang]
		if ResourceLoader.exists(jugar_texture_path):
			jugar_button.texture_normal = load(jugar_texture_path)
			print("✅ Textura Jugar aplicada: ", jugar_texture_path)
			
			# Aplicar hover (modo opuesto)
			var modo_opuesto = "light" if mode == "dark" else "dark"
			if jugar_button_paths.has(modo_opuesto) and jugar_button_paths[modo_opuesto].has(current_lang):
				var hover_texture_path = jugar_button_paths[modo_opuesto][current_lang]
				if ResourceLoader.exists(hover_texture_path):
					jugar_button.texture_hover = load(hover_texture_path)
		else:
			print("❌ Textura Jugar no encontrada: ", jugar_texture_path)

func _apply_language(lang: String):
	if not button_paths.has(lang): return
	var lang_buttons = button_paths[lang]
	
	# Aplicar texturas a botones de color
	rojo_button.texture_normal = load(lang_buttons["Rojo"])
	naranja_button.texture_normal = load(lang_buttons["Naranja"])
	azul_button.texture_normal = load(lang_buttons["Azul"])
	verde_button.texture_normal = load(lang_buttons["Verde"])
	
	# NUEVO: Actualizar botón Jugar según idioma
	var current_mode = ConfigManager.get_color_mode()
	if jugar_button and jugar_button_paths.has(current_mode) and jugar_button_paths[current_mode].has(lang):
		var jugar_texture_path = jugar_button_paths[current_mode][lang]
		if ResourceLoader.exists(jugar_texture_path):
			jugar_button.texture_normal = load(jugar_texture_path)
			print("✅ Textura Jugar actualizada: ", jugar_texture_path)

func _apply_character_skin(skin_id: int):
	# Vincular IDs con colores (según orden de preferencia)
	var color_map = {1: "Naranja", 2: "Rojo", 3: "Azul", 4: "Verde"}
	var color_name = color_map.get(skin_id, "Naranja")
	_set_character_texture(color_name)

func _on_color_selected(color_name: String):
	_set_character_texture(color_name)

	# Guardar la selección como skin_id (1–4)
	var color_to_id = {"Naranja": 1, "Rojo": 2, "Azul": 3, "Verde": 4}
	if color_to_id.has(color_name):
		ConfigManager.set_character_skin(color_to_id[color_name])

func _set_character_texture(color_name: String):
	if not character_sprite: return
	if character_paths.has(color_name):
		var tex = load(character_paths[color_name])
		if tex:
			character_sprite.texture = tex
			print("🎨 Personaje cambiado a:", color_name)
	else:
		print("⚠️ No se encontró textura para:", color_name)

# NUEVO: Función para el botón Jugar
func _on_jugar_pressed():
	print("🎮 Iniciando nuevo juego desde selección de personajes...")
	
	# 1. Resetear progreso del juego
	ConfigManager.config["unlocked_levels"] = 1
	ConfigManager.save_config()
	print("✅ Progreso reseteado - Solo nivel 1 desbloqueado")
	
	# 2. Actualizar current_area del GameManager
	GameManager.current_area = 1
	print("✅ GameManager.current_area establecido a: 1")
	
	# 3. Iniciar el juego con pantalla de carga
	GameManager.load_level(1, true)
	print("✅ Iniciando nivel 1 con pantalla de carga...")

func _on_back_pressed():
	print("🔙 Volviendo al menú principal (precargado)...")
	get_tree().change_scene_to_packed(main_menu_scene)
