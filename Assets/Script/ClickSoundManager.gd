# ClickSoundManager.gd
extends Node

var click_sound_pool: Array = []
var max_sounds = 3
var is_enabled: bool = true
var base_volume_db: float = -10.0  # Volumen base más bajo

func _ready():
	# Crear pool de sonidos (inicialmente silenciados)
	for i in range(max_sounds):
		var sound_player = AudioStreamPlayer.new()
		sound_player.stream = preload("res://Assets/Sounds/click_sound.mp3")
		sound_player.volume_db = -80.0  # Silencio hasta que se cargue la config
		add_child(sound_player)
		click_sound_pool.append(sound_player)
	
	# Esperar a que el ConfigManager esté completamente inicializado
	call_deferred("_initialize_with_config")
	
	print("🔊 ClickSoundManager: Inicializando...")

func _initialize_with_config():
	# Esperar un frame para asegurar que ConfigManager está listo
	await get_tree().process_frame
	
	if has_node("/root/ConfigManager"):
		var config_manager = get_node("/root/ConfigManager")
		
		# Verificar que el ConfigManager tiene la configuración cargada
		if config_manager.config.has("sound_volume"):
			_apply_immediate_volume()
		else:
			# Si no tiene la config aún, esperar un poco más
			print("🔊 ClickSoundManager: ConfigManager no tiene config cargada, esperando...")
			await get_tree().create_timer(0.1).timeout
			_apply_immediate_volume()
		
		# Conectar para cambios futuros
		if config_manager.has_signal("sound_volume_changed"):
			config_manager.sound_volume_changed.connect(_on_sound_volume_changed)
	else:
		print("❌ ClickSoundManager: ConfigManager no encontrado")
		# Fallback: aplicar volumen por defecto
		_apply_volume_to_all(base_volume_db)
	
	# Conectar a todos los botones existentes y futuros
	get_tree().node_added.connect(_on_node_added)
	_connect_existing_buttons()
	
	print("🔊 ClickSoundManager listo")

func _apply_immediate_volume():
	if has_node("/root/ConfigManager"):
		var config_manager = get_node("/root/ConfigManager")
		var config_volume = config_manager.get_sound_volume()
		
		print("🔊 ClickSoundManager: Volumen inicial del ConfigManager = ", config_volume)
		
		# Aplicar volumen inmediatamente
		if config_volume == 0.0:
			_apply_volume_to_all(-80.0)  # Silencio total
			print("🔊 Click volume: SILENCIADO")
		else:
			# Usar cálculo más simple y consistente
			var calculated_volume_db = linear_to_db(config_volume) + base_volume_db
			_apply_volume_to_all(calculated_volume_db)
			print("🔊 Click volume: Config=", config_volume, " → DB=", calculated_volume_db)

func _on_sound_volume_changed(volume: float):
	print("🔊 ClickSoundManager: Volumen cambiado a ", volume)
	
	# Aplicar volumen inmediatamente cuando cambia
	if volume == 0.0:
		_apply_volume_to_all(-80.0)  # Silencio total
		print("🔊 Click volume: SILENCIADO por cambio")
	else:
		var calculated_volume_db = linear_to_db(volume) + base_volume_db
		_apply_volume_to_all(calculated_volume_db)
		print("🔊 Click volume: Cambiado a DB=", calculated_volume_db)

func _apply_volume_to_all(db_volume: float):
	for sound_player in click_sound_pool:
		sound_player.volume_db = db_volume

func _on_node_added(node):
	if node is BaseButton:
		_setup_button_sound(node)

func _connect_existing_buttons():
	var buttons = _find_all_buttons(get_tree().root)
	for button in buttons:
		_setup_button_sound(button)
	print("🔊 ClickSoundManager: Conectado a ", buttons.size(), " botones existentes")

func _find_all_buttons(root: Node) -> Array:
	var buttons = []
	var nodes_to_check = [root]
	
	while nodes_to_check.size() > 0:
		var node = nodes_to_check.pop_front()
		
		if node is BaseButton:
			buttons.append(node)
		
		for child in node.get_children():
			nodes_to_check.append(child)
	
	return buttons

func _setup_button_sound(button: BaseButton):
	if not button.pressed.is_connected(_on_button_pressed):
		button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	if is_enabled:
		play_click_sound()

func play_click_sound():
	if not is_enabled:
		return
	
	for sound_player in click_sound_pool:
		if not sound_player.playing:
			sound_player.play()
			return
	
	if click_sound_pool.size() > 0:
		click_sound_pool[0].play()

func set_enabled(enabled: bool):
	is_enabled = enabled
	print("🔊 ClickSoundManager: ", "activado" if enabled else "desactivado")

func set_base_volume_db(db_volume: float):
	base_volume_db = db_volume
	# Re-aplicar el volumen actual con la nueva base
	if has_node("/root/ConfigManager"):
		var config_manager = get_node("/root/ConfigManager")
		var config_volume = config_manager.get_sound_volume()
		if config_volume > 0:
			var calculated_volume_db = linear_to_db(config_volume) + base_volume_db
			_apply_volume_to_all(calculated_volume_db)
