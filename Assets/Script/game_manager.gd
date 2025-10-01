# GameManager.gd
extends Node

var current_area = 1
var area_path = "res://Assets/Scenes/Areas/0"
var coins = 0
var death_timer: Timer

func _ready():
	reset_coins()
	_setup_death_timer()
	call_deferred("_connect_player_death_signal")

func _setup_death_timer():
	death_timer = Timer.new()
	death_timer.wait_time = 1.0
	death_timer.one_shot = true
	death_timer.timeout.connect(_on_death_timer_timeout)
	add_child(death_timer)
	print("GameManager: Timer de muerte configurado")

func _connect_player_death_signal():
	# Esperar a que la escena esté completamente cargada
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player") as KaleidoController
	if player:
		# Desconectar primero para evitar duplicados
		if player.player_died.is_connected(_on_player_died):
			player.player_died.disconnect(_on_player_died)
		player.player_died.connect(_on_player_died)
		print("GameManager: Señal player_died conectada al jugador")
	else:
		print("GameManager: ERROR - No se encontró jugador para conectar")

func _on_player_died():
	print("GameManager: Jugador murió - procesando muerte")
	reset_coins()
	close_all_goals()
	
	if death_timer:
		if death_timer.time_left > 0:
			death_timer.stop()
			print("GameManager: Timer existente detenido")
		
		death_timer.start()
		print("GameManager: Timer de muerte (re)iniciado - Tiempo: ", death_timer.time_left)

func _on_death_timer_timeout():
	print("GameManager: Timer completado - reiniciando escena")
	get_tree().reload_current_scene()
	# IMPORTANTE: Reconectar la señal después del reinicio
	call_deferred("_connect_player_death_signal")

func close_all_goals():
	var goals = get_tree().get_nodes_in_group("goals")
	print("GameManager: Cerrando ", goals.size(), " metas")
	for goal in goals:
		if goal is AreaExit:
			goal.close()

func next_level():
	current_area += 1
	var full_path = area_path + str(current_area) + ".tscn"
	get_tree().change_scene_to_file(full_path)
	area_setup()

func area_setup():
	reset_coins()
	close_all_goals()
	# Reconectar después de cambiar de nivel también
	call_deferred("_connect_player_death_signal")

func add_coin():
	coins += 1
	print("Moneda recolectada: ", coins, "/50")
	if coins >= 50:
		var goals = get_tree().get_nodes_in_group("goals")
		for goal in goals:
			if goal is AreaExit:
				goal.open()

func reset_coins():
	coins = 0
	print("GameManager: Contador de monedas reseteado a ", coins)
