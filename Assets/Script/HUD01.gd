# Hud01.gd
extends Control

@onready var contador_gemas_label: Label
@onready var puerta_status_label: Label

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
		# Intentar con nombres alternativos
		contador_gemas_label = find_child("ContadorGemas") as Label
		if contador_gemas_label:
			print("✅ ContadorGemas (plural) encontrado")
		else:
			# Intentar con TexturaGema que aparece en tu imagen
			contador_gemas_label = find_child("TexturaGema") as Label
			if contador_gemas_label:
				print("✅ TexturaGema encontrado")
	
	if puerta_status_label:
		print("✅ PuertaStatus encontrado")
	else:
		print("❌ PuertaStatus NO encontrado")
	
	# Conectar señales del GameManager
	if GameManager:
		if GameManager.has_signal("coin_added"):
			GameManager.coin_added.connect(_on_game_manager_coin_added)
		if GameManager.has_signal("coins_reset"):
			GameManager.coins_reset.connect(_on_game_manager_coins_reset)
		print("✅ Señales del GameManager conectadas")
	else:
		print("❌ GameManager no encontrado")
	
	# Conectar señal de cambio de idioma
	if ConfigManager.has_signal("language_changed"):
		ConfigManager.language_changed.connect(_on_language_changed)
		print("✅ Señal language_changed conectada")
	
	# Actualizar estado inicial
	actualizar_contador_gemas()
	actualizar_status_puerta()

func _on_game_manager_coin_added():
	print("✅ Señal coin_added recibida")
	actualizar_contador_gemas()
	actualizar_status_puerta()

func _on_game_manager_coins_reset():
	print("✅ Señal coins_reset recibida")
	actualizar_contador_gemas()
	actualizar_status_puerta()

func _on_language_changed(_lang: String):
	print("🌐 Idioma cambiado - actualizando HUD")
	actualizar_contador_gemas()
	actualizar_status_puerta()

func actualizar_contador_gemas():
	if contador_gemas_label:
		var language = ConfigManager.get_language()
		var text = ""
		
		if language == "es":
			text = str(GameManager.coins) + " de 50"
		else: # "en"
			text = str(GameManager.coins) + " of 50"
		
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
