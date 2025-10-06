# GameManager.gd
extends Node

var current_area = 1
var area_path = "res://Assets/Scenes/Areas/0"
var coins = 0
var death_timer: Timer
var death_sound: AudioStreamPlayer

signal coin_added
signal coins_reset

func _ready():
	reset_coins()
	_setup_death_timer()
	_setup_death_sound()
	call_deferred("_connect_player_death_signal")

# ===== SISTEMA DE CARGA DE NIVELES =====
func load_level(level_number: int, with_loading_screen: bool = true):
	if with_loading_screen:
		await _show_loading_screen(level_number)
	else:
		# Carga directa (para "continuar" desde el menú)
		current_area = level_number
		var full_path = area_path + str(current_area) + ".tscn"
		get_tree().change_scene_to_file(full_path)
		area_setup()

func _show_loading_screen(level_number: int):
	print("🔄 GameManager: Iniciando carga del nivel ", level_number)
	
	# 1. Mostrar loading screen
	var loading_screen_scene = preload("res://Assets/Scenes/UI/LoadingScreen.tscn")
	var loading_screen = loading_screen_scene.instantiate()
	get_tree().root.add_child(loading_screen)
	
	if loading_screen.has_method("set_level"):
		loading_screen.set_level(level_number)
	
	print("📱 LoadingScreen mostrada - esperando 3 segundos")
	await get_tree().create_timer(3.0).timeout
	print("⏰ Tiempo de lectura completado")
	
	# 2. Cargar el nivel
	current_area = level_number
	var full_path = area_path + str(current_area) + ".tscn"
	get_tree().change_scene_to_file(full_path)
	area_setup()
	
	# 3. Quitar loading screen
	loading_screen.queue_free()
	
	print("✅ Nivel ", level_number, " cargado completamente")

# ===== SISTEMA DE MUERTE =====
func _setup_death_timer():
	death_timer = Timer.new()
	death_timer.wait_time = 1.0
	death_timer.one_shot = true
	death_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	death_timer.timeout.connect(_on_death_timer_timeout)
	add_child(death_timer)
	print("GameManager: Timer de muerte configurado")

func _setup_death_sound():
	death_sound = AudioStreamPlayer.new()
	death_sound.volume_db = -20.0
	death_sound.process_mode = Node.PROCESS_MODE_ALWAYS
	death_sound.stream = preload("res://Assets/Sounds/Touhou Death Sound Effect.mp3")
	add_child(death_sound)
	print("GameManager: Sonido de muerte configurado")

func _connect_player_death_signal():
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player") as KaleidoController
	if player:
		if player.player_died.is_connected(_on_player_died):
			player.player_died.disconnect(_on_player_died)
		player.player_died.connect(_on_player_died)
		print("GameManager: Señal player_died conectada")

func _on_player_died():
	print("GameManager: Jugador murió - procesando muerte")
	
	# 1. Reproducir animación de muerte si existe
	var player = get_tree().get_first_node_in_group("player") as KaleidoController
	if player and player.has_node("AgentAnimator/AnimationPlayer"):
		var death_anim = player.get_node("AgentAnimator/AnimationPlayer")
		if death_anim and death_anim.has_animation("death"):
			print("🎭 Reproduciendo animación de muerte en pausa")
			death_anim.process_mode = Node.PROCESS_MODE_ALWAYS
			death_anim.play("death")
	
	# 2. Reproducir sonido de muerte
	if death_sound:
		death_sound.play()
		print("GameManager: Sonido de muerte reproducido")
	
	# 3. Pausar el juego
	get_tree().paused = true
	print("GameManager: Juego pausado")
	
	# 4. Resetear datos del juego
	reset_coins()
	close_all_goals()
	
	# 5. Iniciar timer para reinicio
	if death_timer:
		if death_timer.time_left > 0:
			death_timer.stop()
		death_timer.start()
		print("GameManager: Timer de muerte iniciado")

func _on_death_timer_timeout():
	print("GameManager: Timer completado - reiniciando escena")
	
	# Detener el sonido de muerte por si acaso
	if death_sound and death_sound.playing:
		death_sound.stop()
	
	# Reanudar antes de reiniciar
	get_tree().paused = false
	get_tree().reload_current_scene()
	call_deferred("_connect_player_death_signal")

# ===== SISTEMA DE METAS Y MONEDAS =====
func close_all_goals():
	var goals = get_tree().get_nodes_in_group("goals")
	print("GameManager: Cerrando ", goals.size(), " metas")
	for goal in goals:
		if goal is AreaExit:
			goal.close()

func next_level():
	print("🎯 GameManager: Pasando al siguiente nivel")
	# Desbloquear el siguiente nivel en ConfigManager
	ConfigManager.unlock_level(current_area + 1)
	# Cargar el siguiente nivel con pantalla de carga
	await load_level(current_area + 1, true)

func area_setup():
	reset_coins()
	close_all_goals()
	call_deferred("_connect_player_death_signal")

func add_coin():
	coins += 1
	print("Moneda recolectada: ", coins, "/50")
	coin_added.emit()
	if coins >= 50:
		var goals = get_tree().get_nodes_in_group("goals")
		for goal in goals:
			if goal is AreaExit:
				goal.open()

func reset_coins():
	coins = 0
	print("GameManager: Contador de monedas reseteado a ", coins)
	coins_reset.emit()

# ===== FUNCIONES PÚBLICAS PARA MENÚS =====
func start_new_game():
	# Reiniciar progreso
	ConfigManager.config["unlocked_levels"] = 1
	ConfigManager.save_config()
	# Cargar nivel 1 con pantalla de carga
	await load_level(1, true)

func continue_game():
	# Cargar el último nivel desbloqueado sin pantalla de carga
	var last_unlocked = ConfigManager.get_unlocked_levels()
	await load_level(last_unlocked, false)
