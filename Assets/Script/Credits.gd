# Credits.gd
extends Control

# Referencias a los nodos
@onready var background = $TextureRect
@onready var regresar_button = $TextureButton

# Texturas para los fondos de créditos
var texturas_fondo = {
	"es_light": "res://Assets/Sprites/UI/Creditos/Credits_es_light.png",
	"es_dark": "res://Assets/Sprites/UI/Creditos/Credits_es_dark.png",
	"en_light": "res://Assets/Sprites/UI/Creditos/Credits_en_light.png",
	"en_dark": "res://Assets/Sprites/UI/Creditos/Credits_en_dark.png"
}

# Texturas para el botón regresar
var texturas_boton_regresar = {
	"light": "res://Assets/Sprites/UI/Botones/Modo Claro/regresar.png",
	"dark": "res://Assets/Sprites/UI/Botones/Modo Oscuro/regresar.png"
}

func _ready():
	# Conectar señal del botón
	regresar_button.pressed.connect(_on_regresar_pressed)
	
	# Conectar a cambios de configuración
	ConfigManager.color_mode_changed.connect(_on_config_changed)
	ConfigManager.language_changed.connect(_on_config_changed)
	
	# Aplicar configuración actual
	_aplicar_configuracion()

func _aplicar_configuracion():
	var modo = ConfigManager.get_color_mode()
	var idioma = ConfigManager.get_language()
	var clave_config = "%s_%s" % [idioma, modo]
	
	print("🎨 Credits: Aplicando configuración - Idioma: ", idioma, ", Modo: ", modo)
	
	# Aplicar fondo
	_aplicar_fondo(clave_config)
	
	# Aplicar botón regresar
	_aplicar_boton_regresar(modo)

func _aplicar_fondo(clave_config: String):
	if texturas_fondo.has(clave_config):
		var texture_path = texturas_fondo[clave_config]
		var texture = load(texture_path)
		if texture:
			background.texture = texture
			print("✅ Fondo de créditos aplicado: ", texture_path)
		else:
			print("❌ Error cargando fondo de créditos: ", texture_path)
	else:
		print("❌ Configuración no encontrada para fondo de créditos: ", clave_config)

func _aplicar_boton_regresar(modo: String):
	if texturas_boton_regresar.has(modo):
		var texture_path = texturas_boton_regresar[modo]
		var texture = load(texture_path)
		if texture:
			regresar_button.texture_normal = texture
			print("✅ Botón regresar aplicado: ", texture_path)
		else:
			print("❌ Error cargando botón regresar: ", texture_path)
	else:
		print("❌ Modo no encontrado para botón regresar: ", modo)

func _on_regresar_pressed():
	print("🔙 Regresar al menú principal desde créditos")
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/MainMenu.tscn")

func _on_config_changed(_value):
	print("🔄 Credits: Configuración cambiada - actualizando interfaz")
	_aplicar_configuracion()
