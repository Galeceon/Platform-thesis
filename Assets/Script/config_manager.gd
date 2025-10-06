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
				# IMPORTANTE: Actualizar el diccionario existente con valores por defecto
				_update_config_with_defaults(loaded_config)
				print("ConfigManager: Configuración cargada")
				return
	
	# Si llegamos aquí, usar configuración por defecto
	print("ConfigManager: Configuración por defecto cargada")

# NUEVA FUNCIÓN: Asegurar que todas las claves existan
func _update_config_with_defaults(loaded_config: Dictionary):
	# Para cada clave en la configuración por defecto
	for key in config.keys():
		if loaded_config.has(key):
			# Si existe en el archivo cargado, usar ese valor
			config[key] = loaded_config[key]
		else:
			# Si no existe, mantener el valor por defecto
			print("ConfigManager: Clave '%s' no encontrada, usando valor por defecto" % key)
	
	# Asegurar que character_skin esté en el rango correcto
	if config.has("character_skin"):
		config["character_skin"] = _validate_skin_id(config["character_skin"])

# Validar skin ID - permite valores fuera de rango para testing
func _validate_skin_id(skin_id: int) -> int:
	if skin_id >= 1 and skin_id <= 4:
		return skin_id
	else:
		print("⚠️  Skin ID fuera de rango: ", skin_id, ", pero permitiendo para testing")
		return skin_id  # Devolver el valor original para que falle la carga de textura

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

# Selección de personaje - CORREGIDO: No usar clamp aquí
func set_character_skin(skin_id: int):
	# Solo validar, no clamp - permitir valores fuera de rango para testing
	var validated_skin = _validate_skin_id(skin_id)
	if validated_skin != config["character_skin"]:
		config["character_skin"] = validated_skin
		save_config()
		character_skin_changed.emit(validated_skin)
		print("ConfigManager: Skin de personaje cambiado a: ", validated_skin)

func get_character_skin() -> int:
	return config["character_skin"]
