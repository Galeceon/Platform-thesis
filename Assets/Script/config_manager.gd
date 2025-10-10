# ConfigManager.gd (versión simplificada)
extends Node

# Configuración persistente
var config = {
	"color_mode": "light",      # "light" or "dark"
	"language": "es",           # "es" or "en" 
	"sound_volume": 1.0,        # 0.0 to 1.0
	"unlocked_levels": 1,       # Progreso del jugador
	"character_skin": 1         # Skin del personaje (1-4)
}

# Señales para notificar cambios
signal color_mode_changed(mode)
signal language_changed(lang)
signal sound_volume_changed(volume)
signal character_skin_changed(skin_id)

func _ready():
	load_config()
	apply_global_volume()

func save_config():
	var config_file = FileAccess.open("user://config.cfg", FileAccess.WRITE)
	if config_file:
		config_file.store_var(config)
		print("ConfigManager: Configuración guardada")
	else:
		print("ConfigManager: Error guardando configuración")

func load_config():
	if FileAccess.file_exists("user://config.cfg"):
		var config_file = FileAccess.open("user://config.cfg", FileAccess.READ)
		if config_file:
			var loaded_config = config_file.get_var()
			if loaded_config != null:
				for key in config.keys():
					if loaded_config.has(key):
						config[key] = loaded_config[key]
				print("ConfigManager: Configuración cargada")
				return
	print("ConfigManager: Configuración por defecto cargada")

# Función simplificada para aplicar volumen global
func apply_global_volume():
	var volume = config["sound_volume"]
	var db_volume = linear_to_db(volume)
	
	# Buscar todos los nodos de audio en el árbol
	var all_nodes = _get_all_nodes(get_tree().root)
	var audio_players = []
	
	for node in all_nodes:
		if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
			audio_players.append(node)
			node.volume_db = db_volume
	
	print("🔊 ConfigManager: Volumen aplicado a ", audio_players.size(), " reproductores")

# Función auxiliar para obtener todos los nodos
func _get_all_nodes(root: Node) -> Array:
	var nodes = [root]
	for child in root.get_children():
		nodes.append_array(_get_all_nodes(child))
	return nodes

func apply_volume_to_player(player: Node):
	if player and (player is AudioStreamPlayer or player is AudioStreamPlayer2D or player is AudioStreamPlayer3D):
		player.volume_db = linear_to_db(config["sound_volume"])

func _validate_skin_id(skin_id: int) -> int:
	if skin_id >= 1 and skin_id <= 4:
		return skin_id
	else:
		print("⚠️  Skin ID fuera de rango: ", skin_id, ", pero permitiendo para testing")
		return skin_id

# Resto de las funciones permanecen igual...
func set_color_mode(mode: String):
	if mode != config["color_mode"]:
		config["color_mode"] = mode
		save_config()
		color_mode_changed.emit(mode)
		print("ConfigManager: Modo de color cambiado a: ", mode)

func get_color_mode() -> String:
	return config["color_mode"]

func set_language(lang: String):
	if lang != config["language"]:
		config["language"] = lang
		save_config()
		language_changed.emit(lang)
		print("ConfigManager: Idioma cambiado a: ", lang)

func get_language() -> String:
	return config["language"]

func set_sound_volume(volume: float):
	var new_volume = clamp(volume, 0.0, 1.0)
	if new_volume != config["sound_volume"]:
		config["sound_volume"] = new_volume
		save_config()
		apply_global_volume()
		sound_volume_changed.emit(config["sound_volume"])
		print("ConfigManager: Volumen de sonido cambiado a: ", config["sound_volume"])

func get_sound_volume() -> float:
	return config["sound_volume"]

func unlock_level(level: int):
	if level > config["unlocked_levels"]:
		config["unlocked_levels"] = level
		save_config()
		print("ConfigManager: Nivel ", level, " desbloqueado")

func get_unlocked_levels() -> int:
	return config["unlocked_levels"]

func set_character_skin(skin_id: int):
	var validated_skin = _validate_skin_id(skin_id)
	if validated_skin != config["character_skin"]:
		config["character_skin"] = validated_skin
		save_config()
		character_skin_changed.emit(validated_skin)
		print("ConfigManager: Skin de personaje cambiado a: ", validated_skin)

func get_character_skin() -> int:
	return config["character_skin"]
