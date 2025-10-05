# KaleidoController.gd - VERSIÓN SIMPLE
extends CharacterBody2D
class_name KaleidoController

signal player_died

@export var speed = 15.0
@export var jump_power = 30.0
@export var double_jump_power = 30.0
@export var coyote_time_duration = 0.25

var speed_mult = 30.0
var jump_mult = -30.0
var direction = 0
var double_jump_available = true
var coyote_time_counter = 0.0

# NUEVAS VARIABLES para pendientes
var was_on_floor = false
var is_on_slope = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("player")

func _physics_process(delta):
	# Guardar estado anterior del suelo
	was_on_floor = is_on_floor()
	
	# Añade la gravedad.
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_time_counter -= delta

	# Detectar si estamos en una pendiente
	is_on_slope = _check_if_on_slope()
	
	# Reinicia el doble salto y el coyote time cuando el personaje está en el suelo O en pendiente.
	if is_on_floor() or is_on_slope:
		double_jump_available = true
		if is_on_floor():
			coyote_time_counter = coyote_time_duration

	# Maneja el salto.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or is_on_slope or coyote_time_counter > 0:
			velocity.y = jump_power * jump_mult
			coyote_time_counter = 0
		elif not is_on_floor() and double_jump_available:
			velocity.y = double_jump_power * jump_mult
			double_jump_available = false

	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed * speed_mult
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_mult)

	move_and_slide()
	_update_animations()

func _check_if_on_slope() -> bool:
	if abs(velocity.x) > 0 and velocity.y > -50 and velocity.y < 50:
		return get_last_slide_collision() != null and not is_on_floor()
	return false

func _update_animations():
	if has_node("AgentAnimator/AnimationPlayer"):
		var anim_player = get_node("AgentAnimator/AnimationPlayer")
		var effectively_grounded = is_on_floor() or is_on_slope
		
		if not effectively_grounded:
			if velocity.y < 0:
				anim_player.play("jump")
			else:
				anim_player.play("fall")
		else:
			if abs(velocity.x) > 0:
				anim_player.play("move")
			else:
				anim_player.play("idle")

func _on_body_entered(body):
	if body.is_in_group("enemies") or body.is_in_group("obstacles"):
		emit_signal("player_died")
