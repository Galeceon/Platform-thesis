# Enemigo.gd
extends CharacterBody2D

@onready var timer = $Timer
@onready var sprite = $Sprite2D
@onready var area_detection = $Area2D

# Configurables
@export var speed: float = 250.0
@export var move_direction: float = 1.0  # 1 = derecha, -1 = izquierda

func _ready():
	# Configurar timer para muerte - IMPORTANTE: funciona aunque el juego esté pausado
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.process_mode = Node.PROCESS_MODE_ALWAYS  # ⚡ ESTA LÍNEA ES CLAVE
	timer.timeout.connect(_on_timer_timeout)
	
	# Configurar detección de colisiones
	add_to_group("enemies")
	
	# Conectar la señal del Area2D
	if area_detection and not area_detection.body_entered.is_connected(_on_area_body_entered):
		area_detection.body_entered.connect(_on_area_body_entered)

func _physics_process(delta):
	# Solo procesar movimiento si el juego NO está pausado
	if get_tree().paused:
		return
	
	# Movimiento horizontal
	velocity.x = speed * move_direction
	velocity.y = 200  # Gravedad aplicada
	
	# Aplicar gravedad si es necesario
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	
	move_and_slide()
	
	# Detectar colisiones con paredes u otros enemigos
	if is_on_wall():
		_change_direction()
	
	# Detectar caída de plataformas
	if not is_on_floor() and is_on_wall():
		_change_direction()
	
	# Actualizar dirección del sprite
	_update_sprite_direction()

func _update_sprite_direction():
	# Girar el sprite según la dirección del movimiento
	if move_direction > 0:
		sprite.scale.x = abs(sprite.scale.x)  # Mirando derecha
	else:
		sprite.scale.x = -abs(sprite.scale.x)  # Mirando izquierda

func _change_direction():
	move_direction *= -1  # Cambiar dirección

func _on_area_body_entered(body):
	if body is KaleidoController:
		print("Enemigo: Jugador detectado - notificando muerte")
		# SOLO emitir la señal - el GameManager se encarga del sonido y pausa
		body.emit_signal("player_died")

func _on_area_entered(area):
	# Solo procesar colisiones entre enemigos si el juego NO está pausado
	if get_tree().paused:
		return
	# Colisión con otros enemigos
	if area.is_in_group("enemies"):
		_change_direction()

func _on_timer_timeout():
	print("Enemigo: ⚡ TIMER TIMEOUT - Reiniciando escena")
	# REANUDAR el juego antes de reiniciar
	get_tree().paused = false
	get_tree().reload_current_scene()
