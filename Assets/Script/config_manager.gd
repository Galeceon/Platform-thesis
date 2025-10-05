# ConfigManager.gd
extends Node

# Configuración persistente
var config = {
	"color_mode": "light",      # "light" or "dark"
	"language": "es",           # "es" or "en" 
	"sound_volume": 1.0,        # 0.0 to 1.0
	"unlocked_levels": 1        # Progreso del jugador
}

# Señales para notificar cambios
signal color_mode_changed(mode)
signal language_changed(lang)
signal sound_volume_changed(volume)

func _ready():
	load_config()

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
				config = loaded_config
				print("ConfigManager: Configuración cargada")
				return
	print("ConfigManager: Configuración por defecto cargada")

# Modo de color
func set_color_mode(mode: String):
	if mode != config["color_mode"]:
		config["color_mode"] = mode
		save_config()
		color_mode_changed.emit(mode)
		print("ConfigManager: Modo de color cambiado a: ", mode)

func get_color_mode() -> String:
	return config["color_mode"]

# Idioma
func set_language(lang: String):
	if lang != config["language"]:
		config["language"] = lang
		save_config()
		language_changed.emit(lang)
		print("ConfigManager: Idioma cambiado a: ", lang)

func get_language() -> String:
	return config["language"]

# Volumen de sonido
func set_sound_volume(volume: float):
	config["sound_volume"] = clamp(volume, 0.0, 1.0)
	save_config()
	sound_volume_changed.emit(config["sound_volume"])
	print("ConfigManager: Volumen de sonido cambiado a: ", config["sound_volume"])

func get_sound_volume() -> float:
	return config["sound_volume"]

# Progreso de niveles
func unlock_level(level: int):
	if level > config["unlocked_levels"]:
		config["unlocked_levels"] = level
		save_config()
		print("ConfigManager: Nivel ", level, " desbloqueado")

func get_unlocked_levels() -> int:
	return config["unlocked_levels"]
