extends Control

@onready var contador_gemas_label: Label
@onready var puerta_status_label: Label
@onready var puntaje_label: Label = $TexturaPuntos/Puntaje
@onready var tiempo_label: Label = $TextutaTiempo/Tiempo
@onready var textura_pausa: TextureButton = $TexturaPausa  # Referencia al nodo TexturaPausa

func _ready():
	# Buscar los nodos por nombre
	contador_gemas_label = find_child("ContadorGema") as Label
	puerta_status_label = find_child("PuertaStatus") as Label
	
	# Debug: listar todos los hijos para ver los nombres reales
	print("=== HIJOS DEL HUD ===")
	for child in get_children():
		print("Hijo: ", child.name, " | Tipo: ", child.get_class())
	print("======================")
	
	# Verificar que encontramos los nodos
	if contador_gemas_label:
		print("✅ ContadorGema encontrado")
	else:
		print("❌ ContadorGema NO encontrado")
		contador_gemas_label = find_child("ContadorGemas") as Label
		if contador_gemas_label:
			print("✅ ContadorGemas (plural) encontrado")
		else:
			contador_gemas_label = find_child("TexturaGema") as Label
			if contador_gemas_label:
				print("✅ TexturaGema encontrado")
	
	if puerta_status_label:
		print("✅ PuertaStatus encontrado")
	else:
		print("❌ PuertaStatus NO encontrado")
	
	if puntaje_label:
		print("✅ Puntaje encontrado")
	else:
		print("❌ Puntaje NO encontrado")
		puntaje_label = find_child("Puntaje") as Label
	
	if tiempo_label:
		print("✅ Tiempo encontrado")
	else:
		print("❌ Tiempo NO encontrado")
		tiempo_label = find_child("Tiempo") as Label
	
	if textura_pausa:
		print("✅ TexturaPausa encontrado")
	else:
		print("❌ TexturaPausa NO encontrado")
		textura_pausa = find_child("TexturaPausa") as TextureButton
	
	# Conectar señales del GameManager
	if GameManager:
		if GameManager.has_signal("coin_added"):
			GameManager.coin_added.connect(_on_game_manager_coin_added)
		if GameManager.has_signal("coins_reset"):
			GameManager.coins_reset.connect(_on_game_manager_coins_reset)
		if GameManager.has_signal("puntaje_actualizado"):
			GameManager.puntaje_actualizado.connect(_on_game_manager_puntaje_actualizado)
		if GameManager.has_signal("tiempo_actualizado"):
			GameManager.tiempo_actualizado.connect(_on_game_manager_tiempo_actualizado)
		print("✅ Señales del GameManager conectadas")
	else:
		print("❌ GameManager no encontrado")
	
	# Conectar señal de cambio de idioma
	if ConfigManager.has_signal("language_changed"):
		ConfigManager.language_changed.connect(_on_language_changed)
		print("✅ Señal language_changed conectada")
	
	# Conectar señal de cambio de color_mode
	if ConfigManager.has_signal("color_mode_changed"):
		ConfigManager.color_mode_changed.connect(_on_color_mode_changed)
		print("✅ Señal color_mode_changed conectada")
	else:
		print("❌ ConfigManager no tiene señal color_mode_changed")
	
	# Actualizar estado inicial
	actualizar_contador_gemas()
	actualizar_status_puerta()
	actualizar_puntaje()
	actualizar_tiempo()
	actualizar_textura_pausa()
	
	# Configurar el botón de pausa si es un TextureButton
	_setup_pause_button()

func _setup_pause_button():
	if textura_pausa and textura_pausa is TextureButton:
		var pause_button = textura_pausa
		
		# Conectar señales para el efecto hover
		pause_button.mouse_entered.connect(_on_pause_button_mouse_entered)
		pause_button.mouse_exited.connect(_on_pause_button_mouse_exited)
		pause_button.pressed.connect(_on_pause_button_pressed)
		
		# Configurar texturas iniciales
		_actualizar_texturas_pause_button()
		
		print("✅ Botón de pausa configurado con efectos hover")

func _actualizar_texturas_pause_button():
	if textura_pausa and textura_pausa is TextureButton:
		var pause_button = textura_pausa
		var modo_oscuro = ConfigManager.get_color_mode() == "dark"
		
		var textura_normal = ""
		var textura_hover = ""
		
		if modo_oscuro:
			textura_normal = "res://Assets/Sprites/UI/Botones/Modo Oscuro/pausa.png"
			textura_hover = "res://Assets/Sprites/UI/Botones/Modo Claro/pausa.png"
		else:
			textura_normal = "res://Assets/Sprites/UI/Botones/Modo Claro/pausa.png"
			textura_hover = "res://Assets/Sprites/UI/Botones/Modo Oscuro/pausa.png"
		
		var tex_normal = load(textura_normal)
		var tex_hover = load(textura_hover)
		
		if tex_normal:
			pause_button.texture_normal = tex_normal
		if tex_hover:
			pause_button.texture_hover = tex_hover
		
		print("✅ Texturas del botón pausa actualizadas")

func _on_pause_button_mouse_entered():
	print("🖱️ Hover en botón pausa")

func _on_pause_button_mouse_exited():
	print("🖱️ Hover fuera del botón pausa")

func _on_pause_button_pressed():
	print("🎮 Botón pausa presionado - abriendo menú de pausa")
	# Abrir el menú de pausa a través del GameManager
	if GameManager and GameManager.has_method("toggle_pause_menu"):
		GameManager.toggle_pause_menu()

func _on_game_manager_coin_added():
	print("✅ Señal coin_added recibida")
	actualizar_contador_gemas()
	actualizar_status_puerta()

func _on_game_manager_coins_reset():
	print("✅ Señal coins_reset recibida")
	actualizar_contador_gemas()
	actualizar_status_puerta()

func _on_game_manager_puntaje_actualizado(puntaje: int):
	print("✅ Señal puntaje_actualizado recibida: ", puntaje)
	actualizar_puntaje()

func _on_game_manager_tiempo_actualizado(tiempo: int):
	print("✅ Señal tiempo_actualizado recibida: ", tiempo)
	actualizar_tiempo()

func _on_language_changed(_lang: String):
	print("🌐 Idioma cambiado - actualizando HUD")
	actualizar_contador_gemas()
	actualizar_status_puerta()

func _on_color_mode_changed(_mode: String):
	print("🎨 Modo de color cambiado - actualizando textura de pausa")
	actualizar_textura_pausa()
	# Actualizar también las texturas del botón si es TextureButton
	if textura_pausa and textura_pausa is TextureButton:
		_actualizar_texturas_pause_button()

func actualizar_contador_gemas():
	if contador_gemas_label:
		var language = ConfigManager.get_language()
		var text = ""
		
		if language == "es":
			text = str(GameManager.coins) + "/50"
		else: # "en"
			text = str(GameManager.coins) + "/50"
		
		contador_gemas_label.text = text
		print("✅ Contador actualizado: ", GameManager.coins, "/50 (", language, ")")
	else:
		print("❌ ERROR: contador_gemas_label es null - no se puede actualizar")

func actualizar_status_puerta():
	if puerta_status_label:
		var language = ConfigManager.get_language()
		var text = ""
		
		if GameManager.coins >= 50:
			if language == "es":
				text = "¡La puerta está abierta! ¡Resuelve el minijuego!"
			else: # "en"
				text = "The door is open! Solve the minigame!"
		else:
			if language == "es":
				text = "La puerta está cerrada... ¡Recoge las gemas!"
			else: # "en"
				text = "The door is closed... Collect the gems!"
		
		puerta_status_label.text = text
		print("✅ Status puerta actualizado (", language, ")")
	else:
		print("❌ ERROR: puerta_status_label es null - no se puede actualizar")

func actualizar_puntaje():
	if puntaje_label:
		var language = ConfigManager.get_language()
		var text = ""
		
		if language == "es":
			text = str(GameManager.puntaje) + " puntos"
		else: # "en"
			text = "Score: " + str(GameManager.puntaje)
		
		puntaje_label.text = text
	else:
		print("❌ ERROR: puntaje_label es null")

func actualizar_tiempo():
	if tiempo_label:
		var minutos = GameManager.tiempo_restante / 60
		var segundos = GameManager.tiempo_restante % 60
		var texto_tiempo = "%02d:%02d" % [minutos, segundos]
		tiempo_label.text = texto_tiempo
	else:
		print("❌ ERROR: tiempo_label es null")

func actualizar_textura_pausa():
	if textura_pausa:
		# Usar el método correcto de ConfigManager
		var modo_oscuro = ConfigManager.get_color_mode() == "dark"
		
		var ruta_textura = ""
		
		if modo_oscuro:
			ruta_textura = "res://Assets/Sprites/UI/Botones/Modo Oscuro/pausa.png"
		else:
			ruta_textura = "res://Assets/Sprites/UI/Botones/Modo Claro/pausa.png"
		
		var textura = load(ruta_textura)
		if textura:
			# Como ya sabemos que es TextureButton, asignar textura normal
			textura_pausa.texture_normal = textura
			print("✅ Textura de pausa actualizada: ", ruta_textura)
		else:
			print("❌ ERROR: No se pudo cargar la textura: ", ruta_textura)
	else:
		print("❌ ERROR: textura_pausa es null")
