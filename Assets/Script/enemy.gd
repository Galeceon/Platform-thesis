extends CharacterBody2D

@onready var timer = $Timer
@onready var sprite = $Sprite2D
@onready var area_detection = $Area2D
@onready var animation_player = $AnimationPlayer
@onready var raycast = $RayCast2D

# Configurables
@export var speed: float = 250.0
@export var move_direction: float = 1.0  # 1 = derecha, -1 = izquierda

# Variables para control de animaciones
var is_turning: bool = false
var can_move: bool = true
var just_turned: bool = false  # Para evitar bucles

func _ready():
	# Configurar timer para muerte
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.timeout.connect(_on_timer_timeout)
	
	# Configurar detección de colisiones
	add_to_group("enemies")
	
	# Conectar la señal del Area2D
	if area_detection and not area_detection.body_entered.is_connected(_on_area_body_entered):
		area_detection.body_entered.connect(_on_area_body_entered)
	
	# Configurar RayCast2D para detección de bordes
	if has_node("RayCast2D"):
		raycast = $RayCast2D
		raycast.enabled = true
		raycast.collision_mask = 1  # Colisionar con el layer del terreno
		# Configurar el rayo para que apunte hacia abajo desde el borde
		raycast.target_position = Vector2(0, 50)  # 50px hacia abajo
		_update_raycast_position()
	else:
		print("⚠️ RayCast2D no encontrado - la detección de bordes no funcionará")
	
	# Iniciar con animación de caminar
	if animation_player:
		animation_player.play("move")

func _physics_process(delta):
	# Solo procesar movimiento si el juego NO está pausado
	if get_tree().paused:
		return
	
	# Si está girando, no aplicar movimiento
	if is_turning:
		velocity.x = 0
	else:
		# Movimiento horizontal solo si puede moverse
		if can_move:
			velocity.x = speed * move_direction
		else:
			velocity.x = 0
	
	velocity.y = 200  # Gravedad aplicada
	
	# Aplicar gravedad si es necesario
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	
	move_and_slide()
	
	# Solo detectar colisiones si no está girando y no acaba de girar
	if not is_turning and not just_turned:
		# Detectar colisiones con paredes u otros enemigos
		if is_on_wall():
			print("🔴 Enemigo: Detectada pared - girando")
			_start_turn_animation()
		
		# Detectar bordes de plataformas (si está a punto de caerse)
		elif _should_turn_at_edge():
			print("🔴 Enemigo: Detectado borde - girando")
			_start_turn_animation()
	
	# Actualizar posición del RayCast2D
	_update_raycast_position()
	
	# Actualizar dirección del sprite (solo si no está girando)
	if not is_turning:
		_update_sprite_direction()

# CORREGIDO: Detección de bordes simplificada y precisa
func _should_turn_at_edge() -> bool:
	if not raycast or not is_on_floor() or is_turning:
		return false
	
	# Usar el RayCast2D para detectar si hay suelo adelante
	# Si el RayCast2D NO está colisionando, significa que hay un borde
	var should_turn = not raycast.is_colliding()
	
	# DEBUG
	if should_turn:
		print("🚨 Borde detectado - RayCast no colisiona")
	
	return should_turn

# CORREGIDO: Posición del RayCast2D ajustada para el tamaño del enemigo
func _update_raycast_position():
	if not raycast:
		return
	
	# Calcular posición basada en el tamaño del enemigo
	# Ancho: -40px a 40px = 80px total → radio de 40px
	# Alto: -72px a 72px = 144px total → "pies" en y = 72px
	
	var ray_offset_x = 35 * move_direction  # Un poco menos que el radio de 40px
	var ray_offset_y = 70  # Casi al nivel de los pies (72px)
	
	raycast.position = Vector2(ray_offset_x, ray_offset_y)

func _update_sprite_direction():
	# Girar el sprite según la dirección del movimiento
	if move_direction > 0:
		sprite.scale.x = abs(sprite.scale.x)  # Mirando derecha
	else:
		sprite.scale.x = -abs(sprite.scale.x)  # Mirando izquierda

func _start_turn_animation():
	if is_turning:
		return  # Ya está girando
	
	is_turning = true
	can_move = false
	just_turned = true  # Marcar que acaba de girar
	
	# Timer para resetear just_turned después del giro
	var cooldown_timer = get_tree().create_timer(0.5)
	cooldown_timer.timeout.connect(_reset_just_turned)
	
	# Reproducir animación de giro
	if animation_player:
		animation_player.play("turn")
		# Conectar la señal para saber cuándo termina la animación
		if not animation_player.animation_finished.is_connected(_on_turn_animation_finished):
			animation_player.animation_finished.connect(_on_turn_animation_finished)
	else:
		# Si no hay AnimationPlayer, cambiar dirección inmediatamente
		_finish_turn()

func _reset_just_turned():
	just_turned = false

func _on_turn_animation_finished(anim_name: String):
	if anim_name == "turn":
		_finish_turn()

func _finish_turn():
	# Cambiar dirección
	move_direction *= -1
	
	# Restaurar estado normal
	is_turning = false
	can_move = true
	
	# Actualizar dirección del sprite
	_update_sprite_direction()
	
	# Reanudar animación de caminar
	if animation_player:
		animation_player.play("move")
	
	# Desconectar la señal para evitar múltiples conexiones
	if animation_player and animation_player.animation_finished.is_connected(_on_turn_animation_finished):
		animation_player.animation_finished.disconnect(_on_turn_animation_finished)

func _change_direction():
	_start_turn_animation()

func _on_area_body_entered(body):
	if body is KaleidoController:
		print("Enemigo: Jugador detectado - notificando muerte")
		body.emit_signal("player_died")

func _on_area_entered(area):
	if get_tree().paused:
		return
	if area.is_in_group("enemies"):
		_start_turn_animation()

func _on_timer_timeout():
	print("Enemigo: ⚡ TIMER TIMEOUT - Reiniciando escena")
	get_tree().paused = false
	get_tree().reload_current_scene()
