extends CharacterBody2D
class_name KaleidoController

@export var speed = 15.0
@export var jump_power = 30.0
@export var double_jump_power = 30.0 # Nueva variable para el poder del doble salto
@export var coyote_time_duration = 0.25 # Duración del coyote time en segundos

var speed_mult = 30.0
var jump_mult = -30.0
var direction = 0
var double_jump_available = true # Variable para controlar si el doble salto está disponible
var coyote_time_counter = 0.0 # Contador para el coyote time

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Añade la gravedad.
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_time_counter -= delta # Decrementa el contador de coyote time

	# Reinicia el doble salto y el coyote time cuando el personaje está en el suelo.
	if is_on_floor():
		double_jump_available = true
		coyote_time_counter = coyote_time_duration

	# Maneja el salto.
	if Input.is_action_just_pressed("jump"):
		# Salto normal: si el personaje está en el suelo o dentro del coyote time.
		if is_on_floor() or coyote_time_counter > 0:
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
