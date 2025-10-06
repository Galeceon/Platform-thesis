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

func actualizar_contador_gemas():
	if contador_gemas_label:
		contador_gemas_label.text = str(GameManager.coins) + " de 50"
		print("✅ Contador actualizado: ", GameManager.coins, "/50")
	else:
		print("❌ ERROR: contador_gemas_label es null - no se puede actualizar")

func actualizar_status_puerta():
	if puerta_status_label:
		if GameManager.coins >= 50:
			puerta_status_label.text = "La puerta esta abierta! Resuelve el minijuego!"
		else:
			puerta_status_label.text = "La puerta esta cerrada... Recoge las gemas!"
		print("✅ Status puerta actualizado")
	else:
		print("❌ ERROR: puerta_status_label es null - no se puede actualizar")
