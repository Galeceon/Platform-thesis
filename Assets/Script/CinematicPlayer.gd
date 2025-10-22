# CinematicPlayer.gd
extends CanvasLayer

@onready var video_player: VideoStreamPlayer = $VideoPlayer

signal cinematic_finished

# Rutas de los videos (OGV)
var video_paths = {
	CinematicManager.CinematicType.INTRO_ES: "res://Assets/Videos/intro_es.ogv",
	CinematicManager.CinematicType.INTRO_EN: "res://Assets/Videos/intro_en.ogv", 
	CinematicManager.CinematicType.OUTRO_ES: "res://Assets/Videos/outro_es.ogv",
	CinematicManager.CinematicType.OUTRO_EN: "res://Assets/Videos/outro_en.ogv"
}

# Variable para controlar si ya estamos procesando el skip
var is_skipping = false

func _ready():
	# Configurar video player
	video_player.finished.connect(_on_video_finished)
	
	# CONFIGURAR ESCALADO PARA AJUSTAR A PANTALLA
	_setup_video_scaling()
	
	# Hacer que este nodo capture input - CONFIGURACIÓN MEJORADA
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Asegurar que capture input
	set_process_input(true)
	video_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("🎬 CinematicPlayer listo - Capturando input")

func _setup_video_scaling():
	# Configurar para que ocupe toda la pantalla
	video_player.set_anchors_preset(Control.PRESET_FULL_RECT)
	video_player.set_offsets_preset(Control.PRESET_FULL_RECT)
	
	# La propiedad más importante para el escalado en Godot 4
	video_player.expand = true
	
	# Forzar actualización del tamaño
	var viewport_size = get_viewport().get_visible_rect().size
	video_player.size = viewport_size
	
	print("🎥 Video configurado para ocupar pantalla completa")

func play_cinematic(cinematic_type: CinematicManager.CinematicType):
	var video_path = video_paths[cinematic_type]
	
	print("🎥 Intentando cargar video: ", video_path)
	
	if ResourceLoader.exists(video_path):
		var video_stream = load(video_path)
		if video_stream:
			video_player.stream = video_stream
			
			# Asegurar que el expand esté activado
			video_player.expand = true
			
			# Resetear estado de skip
			is_skipping = false
			
			video_player.play()
			print("✅ Reproduciendo: ", video_path)
			print("🎮 Presiona ESC para saltar la cinemática")
		else:
			print("❌ Error cargando video stream: ", video_path)
			_finish_cinematic()
	else:
		print("❌ Video no encontrado: ", video_path)
		_finish_cinematic()

func _finish_cinematic():
	# Prevenir múltiples llamadas
	if is_skipping:
		return
	
	is_skipping = true
	print("✅ Video finalizado/saltado")
	
	# Emitir la señal antes de eliminar
	cinematic_finished.emit()
	
	# Eliminar inmediatamente
	queue_free()

func _on_video_finished():
	print("🎥 Video terminó naturalmente")
	_finish_cinematic()

# Permitir saltar con tecla ESC (ui_cancel) - VERSIÓN MEJORADA
func _input(event):
	# Solo procesar si no estamos ya saltando
	if is_skipping:
		return
	
	# Verificar si es la tecla ESC
	if event.is_action_pressed("ui_cancel"):
		print("⏭️ Saltando cinemática con ESC - Evento capturado")
		video_player.stop()
		_finish_cinematic()
		get_viewport().set_input_as_handled()
	
	# También permitir saltar con cualquier tecla o click
	elif event is InputEventKey and event.pressed and not event.echo:
		print("⏭️ Saltando cinemática con tecla: ", event.keycode)
		video_player.stop()
		_finish_cinematic()
		get_viewport().set_input_as_handled()
	
	elif event is InputEventMouseButton and event.pressed:
		print("⏭️ Saltando cinemática con click del mouse")
		video_player.stop()
		_finish_cinematic()
		get_viewport().set_input_as_handled()
