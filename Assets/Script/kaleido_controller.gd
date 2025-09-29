extends CharacterBody2D
class_name KaleidoController

signal player_died

@export var speed = 15.0
@export var jump_power = 30.0
@export var double_jump_power = 30.0 # Nueva variable para el poder del doble salto
@export var coyote_time_duration = 0.25 # Duración del coyote time en segundos

var speed_mult = 30.0
var jump_mult = -30.0
var direction = 0
var double_jump_available = true # Variable para controlar si el doble salto está disponible
var coyote_time_counter = 0.0 # Contador para el coyote time

# NUEVAS VARIABLES para pendientes
var was_on_floor = false
var is_on_slope = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Guardar estado anterior del suelo
	was_on_floor = is_on_floor()
	
	# Añade la gravedad.
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_time_counter -= delta # Decrementa el contador de coyote time

	# Detectar si estamos en una pendiente
	is_on_slope = _check_if_on_slope()
	
	# Reinicia el doble salto y el coyote time cuando el personaje está en el suelo O en pendiente.
	if is_on_floor() or is_on_slope:
		double_jump_available = true
		if is_on_floor():
			coyote_time_counter = coyote_time_duration

	# Maneja el salto.
	if Input.is_action_just_pressed("jump"):
		# Salto normal: si el personaje está en el suelo, en pendiente o dentro del coyote time.
		if is_on_floor() or is_on_slope or coyote_time_counter > 0:
			velocity.y = jump_power * jump_mult
			# Reinicia el contador para evitar saltos repetidos después de un solo salto en el suelo
			coyote_time_counter = 0

		# Doble salto: si el personaje no está en el suelo y el doble salto está disponible.
		elif not is_on_floor() and double_jump_available:
			velocity.y = double_jump_power * jump_mult
			double_jump_available = false # Deshabilita el doble salto

	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed * speed_mult
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_mult)

	move_and_slide()
	
	# ACTUALIZAR ANIMACIONES (si las tienes)
	_update_animations()

func _check_if_on_slope() -> bool:
	# Si estamos moviéndonos horizontalmente y tenemos poca velocidad vertical
	if abs(velocity.x) > 0 and velocity.y > -50 and velocity.y < 50:
		# Verificar si hay colisión con el suelo pero técnicamente no estamos "on_floor"
		return get_last_slide_collision() != null and not is_on_floor()
	return false

func _update_animations():
	# Si tienes un AnimationPlayer, aquí controlarías las animaciones
	if has_node("AnimationPlayer"):
		var anim_player = $AnimationPlayer
		
		# Usar is_on_slope para considerar que estamos "en suelo" para animaciones
		var effectively_grounded = is_on_floor() or is_on_slope
		
		if not effectively_grounded:
			# En el aire - animación de salto/caída
			if velocity.y < 0:
				anim_player.play("jump")
			else:
				anim_player.play("fall")
		else:
			# En suelo o pendiente
			if abs(velocity.x) > 0:
				anim_player.play("walk")
			else:
				anim_player.play("idle")

func _on_body_entered(body):
	# Si el objeto con el que colisionamos es un enemigo o un obstáculo,
	# emitimos la señal para reiniciar la escena.
	if body.is_in_group("enemies") or body.is_in_group("obstacles"):
		GameManager.reset_coins()
		emit_signal("player_died")
