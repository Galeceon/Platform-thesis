# HowToPlay.gd
extends Control

# Configuración de páginas
var paginas = [
	"res://Assets/Sprites/UI/Como Jugar/shield_right_es_light.png",
	"res://Assets/Sprites/UI/Como Jugar/shield_left_es_light.png", 
	"res://Assets/Sprites/UI/Como Jugar/shield_up_es_light.png",
	"res://Assets/Sprites/UI/Como Jugar/shield_up_up_es_light.png"
]

var pagina_actual = 0
var total_paginas = 4

# Referencias a nodos
@onready var current_page = $CurrentPage
@onready var left_button = $Navigation/LeftButton
@onready var right_button = $Navigation/RightButton
@onready var page_indicator = $Navigation/PageIndicator
@onready var regresar_button = $Navigation/RegresarButton

func _ready():
	# Conectar señales
	left_button.pressed.connect(_on_left_pressed)
	right_button.pressed.connect(_on_right_pressed)
	regresar_button.pressed.connect(_on_regresar_pressed)
	
	# Cargar primera página
	_actualizar_pagina()

func _actualizar_pagina():
	# 1. Cargar la textura de la página actual
	var texture_path = paginas[pagina_actual]
	var texture = load(texture_path)
	if texture:
		current_page.texture = texture
		print("📄 Página cargada: ", texture_path)
	else:
		print("❌ Error cargando textura: ", texture_path)
	
	# 2. Actualizar visibilidad de botones
	left_button.visible = (pagina_actual > 0)
	right_button.visible = (pagina_actual < total_paginas - 1)
	
	# 3. Actualizar indicador de página
	page_indicator.text = "%d/%d" % [pagina_actual + 1, total_paginas]
	
	print("🔢 Página actual: ", pagina_actual + 1, " de ", total_paginas)

func _on_left_pressed():
	if pagina_actual > 0:
		pagina_actual -= 1
		_actualizar_pagina()
		print("⬅️ Navegando a página: ", pagina_actual + 1)

func _on_right_pressed():
	if pagina_actual < total_paginas - 1:
		pagina_actual += 1
		_actualizar_pagina()
		print("➡️ Navegando a página: ", pagina_actual + 1)

func _on_regresar_pressed():
	print("🔙 Regresando al menú principal")
	get_tree().change_scene_to_file("res://Assets/Scenes/UI/MainMenu.tscn")
