# AudioPlayerController.gd
extends AudioStreamPlayer

func _ready():
	# Registrar este AudioStreamPlayer en el ConfigManager
	ConfigManager.register_audio_player(self)
	
	# Aplicar el volumen actual inmediatamente
	ConfigManager.apply_volume_to_player(self)

func _exit_tree():
	# Opcional: Quitar del grupo cuando se destruya
	ConfigManager.unregister_audio_player(self)
