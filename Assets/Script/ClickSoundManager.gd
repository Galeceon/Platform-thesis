# ClickSoundManager.gd
extends Node

var click_sound_pool: Array = []
var max_sounds = 3
var is_enabled: bool = true
var base_volume_db: float = -10.0  # Volumen base cuando el sonido está activado

func _ready():
	# Crear pool de sonidos
	for i in range(max_sounds):
		var sound_player = AudioStreamPlayer.new()
		sound_player.stream = preload("res://Assets/Sounds/click_sound.mp3")
		add_child(sound_player)
		click_sound_pool.append(sound_player)
	
	# Conectar al ConfigManager para cambios de volumen
	if has_node("/root/ConfigManager"):
		var config_manager = get_node("/root/ConfigManager")
		if config_manager.has_signal("sound_volume_changed"):
			config_manager.sound_volume_changed.connect(_on_sound_volume_changed)
	
	# Conectar a todos los botones existentes y futuros
	get_tree().node_added.connect(_on_node_added)
	_connect_existing_buttons()
	
	# Aplicar volumen inicial basado en ConfigManager
	_update_volume_from_config()
	
	print("🔊 ClickSoundManager listo - Integrado con ConfigManager")

func _update_volume_from_config():
	if has_node("/root/ConfigManager"):
		var config_manager = get_node("/root/ConfigManager")
		var config_volume = config_manager.get_sound_volume()
		
		# Si el volumen del config es 0, silenciar completamente
		if config_volume == 0.0:
			_apply_volume_to_all(-80.0)  # Silencio total
		else:
			# Usar nuestro volumen base (-10dB) cuando el config está en 1
			# O interpolar si quisieras diferentes niveles
			_apply_volume_to_all(base_volume_db)
		
		print("🔊 Click volume: Config=", config_volume, " → DB=", base_volume_db if config_volume > 0 else -80.0)

func _on_sound_volume_changed(volume: float):
	print("🔊 ClickSoundManager: Volumen del ConfigManager cambiado a ", volume)
	_update_volume_from_config()

func _apply_volume_to_all(db_volume: float):
	for sound_player in click_sound_pool:
		sound_player.volume_db = db_volume

# El resto del código se mantiene igual...
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

# Función para cambiar el volumen base si lo necesitas
func set_base_volume_db(db_volume: float):
	base_volume_db = db_volume
	_update_volume_from_config()
