# GameManager.gd
extends Node

var current_area = 1
var area_path = "res://Assets/Scenes/Areas/0"
var coins = 0
var death_timer: Timer
var death_sound: AudioStreamPlayer
var puntaje = 0
var tiempo_restante = 300  # 5 minutos en segundos
var tiempo_corriendo = true
var tiempo_timer: Timer

signal puntaje_actualizado(puntaje)
signal tiempo_actualizado(tiempo_restante)
signal tiempo_agotado()
signal coin_added
signal coins_reset

func _ready():
	reset_coins()
	_setup_death_timer()
	_setup_death_sound()
	call_deferred("_connect_player_death_signal")
	# Cargar puntaje guardado
	call_deferred("load_puntaje")
	# Aplicar volumen global al inicio
	call_deferred("apply_global_volume")

# ===== SISTEMA DE VOLUMEN GLOBAL =====
func apply_global_volume():
	print("🔊 GameManager: Aplicando volumen global...")
	# Llamar directamente a la función del ConfigManager
	ConfigManager.apply_global_volume()

# ===== SISTEMA DE CARGA DE NIVELES =====
func load_level(level_number: int, with_loading_screen: bool = true):
	# Verificar si es el nivel final
	if level_number == 5:
		print("🎯 GameManager: Nivel 5 detectado - cargando escena final")
		get_tree().change_scene_to_file("res://Assets/Scenes/Areas/final1.tscn")
		# Aplicar volumen después de cargar la escena final
		call_deferred("apply_global_volume")
		return
	
	if with_loading_screen:
		await _show_loading_screen(level_number)
	else:
		# Carga directa (para "continuar" desde el menú)
		current_area = level_number
		var full_path = area_path + str(current_area) + ".tscn"
		get_tree().change_scene_to_file(full_path)
		
		# Esperar a que la escena se cargue
		await get_tree().process_frame
		await get_tree().process_frame
		
		area_setup()

func _show_loading_screen(level_number: int):
	print("🔄 GameManager: Iniciando carga del nivel ", level_number)
	
	# 1. Mostrar loading screen
	var loading_screen_scene = preload("res://Assets/Scenes/UI/LoadingScreen.tscn")
	var loading_screen = loading_screen_scene.instantiate()
	get_tree().root.add_child(loading_screen)
	
	if loading_screen.has_method("set_level"):
		loading_screen.set_level(level_number)
	
	print("📱 LoadingScreen mostrada - esperando input del jugador")
	
	# 2. Esperar a que el jugador presione una tecla
	# Conectar a la señal del LoadingScreen
	if loading_screen.has_signal("loading_completed"):
		print("⏳ Esperando señal loading_completed...")
		await loading_screen.loading_completed
		print("✅ Señal loading_completed recibida")
	else:
		print("❌ LoadingScreen no tiene señal loading_completed - usando fallback")
		# Fallback: esperar 8 segundos (3 de espera + 5 extra)
		await get_tree().create_timer(8.0).timeout
	
	print("⏰ LoadingScreen completada - cargando nivel")
	
	# 3. Cargar el nivel
	current_area = level_number
	var full_path = area_path + str(current_area) + ".tscn"
	get_tree().change_scene_to_file(full_path)
	
	# 4. Esperar a que el nivel se cargue completamente
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 5. Configurar el nivel
	area_setup()
	
	# 6. Quitar loading screen
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
		print("🔍 GameManager: Jugador encontrado, verificando conexión...")
		
		# Verificar si la señal existe
		if player.has_signal("player_died"):
			print("✅ GameManager: Señal player_died existe en el jugador")
			
			# Verificar conexiones actuales
			var connections = player.player_died.get_connections()
			print("🔗 GameManager: Conexiones a player_died: ", connections.size())
			
			# Desconectar si ya está conectada
			if player.player_died.is_connected(_on_player_died):
				player.player_died.disconnect(_on_player_died)
				print("🔄 GameManager: Señal desconectada para reconectar")
			
			# Conectar la señal
			player.player_died.connect(_on_player_died)
			print("✅ GameManager: Señal player_died CONECTADA")
		else:
			print("❌ GameManager: El jugador NO tiene la señal player_died")
	else:
		print("❌ GameManager: No se encontró jugador en el grupo 'player'")

func _on_player_died():
	print("GameManager: Jugador murió - procesando muerte")
	
	agregar_puntaje(-5000)
	
	# 1. Reproducir animación de muerte si existe
	var player = get_tree().get_first_node_in_group("player") as KaleidoController
	if player and player.has_node("AgentAnimator/AnimationPlayer"):
		var death_anim = player.get_node("AgentAnimator/AnimationPlayer")
		if death_anim and death_anim.has_animation("death"):
			print("🎭 Reproduciendo animación de muerte en pausa")
			death_anim.process_mode = Node.PROCESS_MODE_ALWAYS
			death_anim.play("death")
	
	# 2. Reproducir sonido de muerte (aplicar volumen antes de reproducir)
	if death_sound:
		# Aplicar volumen actual al sonido de muerte
		ConfigManager.apply_volume_to_player(death_sound)
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
	
	# Si estamos en el nivel 5 (final), no recargar la escena
	if current_area == 5:
		print("🎯 GameManager: En escena final - no recargar")
		return
	
	get_tree().reload_current_scene()
	
	# ESPERAR a que la escena se recargue completamente
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("🔄 GameManager: Escena recargada - aplicando configuración")
	
	# Aplicar volumen inmediatamente después de recargar
	apply_global_volume()
	
	# Esperar un poco más y aplicar de nuevo por si acaso
	await get_tree().create_timer(0.2).timeout
	apply_global_volume()
	
	# Reconectar señales del jugador
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
	
	# Agregar 2000 puntos por completar nivel
	agregar_puntaje(2000)
	
	# Verificar si estamos pasando al nivel 5 (final)
	if current_area + 1 == 5:
		print("🎉 GameManager: ¡Completando juego! Cargando escena final")
		# Desbloquear el nivel 5 en ConfigManager
		ConfigManager.unlock_level(5)
		# Cargar la escena final SIN pantalla de carga
		get_tree().change_scene_to_file("res://Assets/Scenes/Areas/final1.tscn")
		# Aplicar volumen después de cargar la escena final
		call_deferred("apply_global_volume")
	else:
		# Desbloquear el siguiente nivel en ConfigManager
		ConfigManager.unlock_level(current_area + 1)
		# Cargar el siguiente nivel con pantalla de carga
		await load_level(current_area + 1, true)

func area_setup():
	reset_coins()
	close_all_goals()
	reset_tiempo()
	iniciar_tiempo()
	# Esperar un frame para que el jugador esté en la escena
	call_deferred("_reconnect_player_signals")
	# Aplicar volumen global después de cargar la escena
	call_deferred("apply_global_volume")

# Nueva función para reconectar señales
func _reconnect_player_signals():
	print("🔄 GameManager: Reconectando señales del jugador...")
	
	# Esperar a que el jugador esté disponible
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player") as KaleidoController
	if player:
		print("🎯 GameManager: Jugador encontrado en el grupo 'player'")
		
		# Verificar y conectar señal de muerte
		if player.has_signal("player_died"):
			# Desconectar si ya estaba conectada
			if player.player_died.is_connected(_on_player_died):
				player.player_died.disconnect(_on_player_died)
			
			# Conectar la señal
			player.player_died.connect(_on_player_died)
			print("✅ GameManager: Señal player_died conectada al jugador")
		else:
			print("❌ GameManager: El jugador no tiene la señal player_died")
	else:
		print("❌ GameManager: No se pudo encontrar el jugador en el grupo 'player'")
		# Reintentar después de un tiempo
		await get_tree().create_timer(0.5).timeout
		_reconnect_player_signals()

func add_coin():
	coins += 1
	print("Moneda recolectada: ", coins, "/50")
	coin_added.emit()
	agregar_puntaje(100)
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
	# Resetear puntaje solo cuando se inicia un juego nuevo
	reset_puntaje()
	# Cargar nivel 1 con pantalla de carga
	await load_level(1, true)

func continue_game():
	# Cargar el último nivel desbloqueado sin pantalla de carga
	var last_unlocked = ConfigManager.get_unrolled_levels()
	
	# Cargar puntaje guardado al continuar juego
	load_puntaje()
	
	# Si el último nivel desbloqueado es 5, cargar la escena final
	if last_unlocked == 5:
		print("🎯 GameManager: Continuar juego - último nivel es 5, cargando escena final")
		get_tree().change_scene_to_file("res://Assets/Scenes/Areas/final1.tscn")
		# Aplicar volumen después de cargar la escena final
		call_deferred("apply_global_volume")
	else:
		await load_level(last_unlocked, true)

# GameManager.gd - agregar después de las funciones existentes

func _setup_tiempo_timer():
	tiempo_timer = Timer.new()
	tiempo_timer.wait_time = 1.0
	tiempo_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	tiempo_timer.timeout.connect(_on_tiempo_timer_timeout)
	add_child(tiempo_timer)
	print("GameManager: Timer de tiempo configurado")

func _on_tiempo_timer_timeout():
	if tiempo_corriendo:
		tiempo_restante -= 1
		tiempo_actualizado.emit(tiempo_restante)
		
		if tiempo_restante <= 0:
			tiempo_restante = 0
			tiempo_agotado.emit()
			# Matar al jugador cuando se agota el tiempo
			var player = get_tree().get_first_node_in_group("player") as KaleidoController
			if player:
				player.morir()
			tiempo_corriendo = false

func iniciar_tiempo():
	if not tiempo_timer:
		_setup_tiempo_timer()
	
	tiempo_corriendo = true
	if not tiempo_timer.is_stopped():
		tiempo_timer.stop()
	tiempo_timer.start()
	print("GameManager: Tiempo iniciado")

func detener_tiempo():
	tiempo_corriendo = false
	if tiempo_timer:
		tiempo_timer.stop()
	print("GameManager: Tiempo detenido")

func agregar_puntaje(cantidad: int):
	puntaje += cantidad
	if puntaje < 0:
		puntaje = 0
	puntaje_actualizado.emit(puntaje)
	# Guardar automáticamente cuando cambia el puntaje
	save_puntaje()
	print("Puntaje actualizado: ", puntaje)

func reset_puntaje():
	puntaje = 0
	puntaje_actualizado.emit(puntaje)
	print("GameManager: Puntaje reseteado")

func reset_tiempo():
	tiempo_restante = 300  # 5 minutos
	tiempo_actualizado.emit(tiempo_restante)
	print("GameManager: Tiempo reseteado")
	
# Agregar esta función para guardar y cargar el puntaje entre sesiones
func save_puntaje():
	if ConfigManager.config.has("puntaje_guardado"):
		ConfigManager.config["puntaje_guardado"] = puntaje
	else:
		ConfigManager.config["puntaje_guardado"] = puntaje
	ConfigManager.save_config()
	print("💾 Puntaje guardado: ", puntaje)

func load_puntaje():
	if ConfigManager.config.has("puntaje_guardado"):
		puntaje = ConfigManager.config["puntaje_guardado"]
		puntaje_actualizado.emit(puntaje)
		print("💾 Puntaje cargado: ", puntaje)
