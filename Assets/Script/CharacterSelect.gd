extends Node

@onready var fondo = $Fondo
@onready var rojo_button = $RojoButton
@onready var naranja_button = $NaranjaButton
@onready var azul_button = $AzulButton
@onready var verde_button = $VerdeButton
@onready var character_sprite = $Character
@onready var atras_button = $Atras_Button
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
	"Verde": "res://Assets/Sprites/kaleido/Select_Green.png"
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

func _ready():
	# Aplicar configuración inicial
	_apply_color_mode(ConfigManager.get_color_mode())
	_apply_language(ConfigManager.get_language())
	_apply_character_skin(ConfigManager.get_character_skin())
	
	# Conectar señales del ConfigManager
	ConfigManager.color_mode_changed.connect(_apply_color_mode)
	ConfigManager.language_changed.connect(_apply_language)
	ConfigManager.character_skin_changed.connect(_apply_character_skin)
	
	atras_button.pressed.connect(_on_back_pressed)

	# Conectar botones
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

func _apply_color_mode(mode: String):
	if not fondo: return
	if background_paths.has(mode):
		fondo.texture = load(background_paths[mode])
	else:
		print("⚠️ Fondo no encontrado para modo:", mode)
	#Configurar el botón Atrás
	if atras_button and back_button_paths.has(mode):
		var back_data = back_button_paths[mode]
		atras_button.texture_normal = load(back_data["normal"])
		atras_button.texture_hover = load(back_data["hover"])
	print("🧩 Atras normal:", atras_button.texture_normal)
	print("🧩 Atras hover:", atras_button.texture_hover)


func _apply_language(lang: String):
	if not button_paths.has(lang): return
	var lang_buttons = button_paths[lang]
	
	rojo_button.texture_normal = load(lang_buttons["Rojo"])
	naranja_button.texture_normal = load(lang_buttons["Naranja"])
	azul_button.texture_normal = load(lang_buttons["Azul"])
	verde_button.texture_normal = load(lang_buttons["Verde"])

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
		
func _on_back_pressed():
	print("🔙 Volviendo al menú principal (precargado)...")
	get_tree().change_scene_to_packed(main_menu_scene)
