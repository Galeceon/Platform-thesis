# CinematicManager.gd (Autoload)
extends Node

signal cinematic_started(cinematic_name)
signal cinematic_finished(cinematic_name)

enum CinematicType {
	INTRO_ES,      # Introducción español
	INTRO_EN,      # Introducción inglés
	OUTRO_ES,      # Final español  
	OUTRO_EN       # Final inglés
}

var cinematic_scene = preload("res://Assets/Scenes/UI/CinematicPlayer.tscn")
var current_cinematic_instance: CanvasLayer = null
var current_cinematic_type: CinematicType
var is_playing_cinematic = false  # Nueva variable para controlar estado

func play_cinematic(cinematic_type: CinematicType):
	# Prevenir múltiples cinemáticas simultáneas
	if is_playing_cinematic:
		print("⚠️ Ya hay una cinemática en reproducción, ignorando...")
		return
	
	print("🎬 CinematicManager: Iniciando cinemática: ", cinematic_type)
	
	current_cinematic_type = cinematic_type
	is_playing_cinematic = true
	
	# Crear instancia del reproductor de cinemáticas
	current_cinematic_instance = cinematic_scene.instantiate()
	get_tree().root.add_child(current_cinematic_instance)
	
	# Conectar señales
	if current_cinematic_instance.has_signal("cinematic_finished"):
		current_cinematic_instance.cinematic_finished.connect(_on_cinematic_finished)
	
	# Iniciar cinemática específica
	current_cinematic_instance.play_cinematic(cinematic_type)
	cinematic_started.emit(cinematic_type)

func _on_cinematic_finished():
	print("🎬 CinematicManager: Cinemática finalizada")
	is_playing_cinematic = false
	
	# Guardar el tipo antes de liberar la instancia
	var finished_type = current_cinematic_type
	
	if current_cinematic_instance:
		current_cinematic_instance.queue_free()
		current_cinematic_instance = null
	
	# EMITIR con el parámetro
	cinematic_finished.emit(finished_type)

# Función para verificar si hay una cinemática en reproducción
func is_cinematic_playing() -> bool:
	return is_playing_cinematic

# Función para forzar el cierre de la cinemática (útil en casos de error)
func force_stop_cinematic():
	if current_cinematic_instance:
		current_cinematic_instance.queue_free()
		current_cinematic_instance = null
	is_playing_cinematic = false
	print("🛑 Cinemática forzada a detenerse")
