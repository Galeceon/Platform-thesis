extends CharacterBody2D

@onready var timer = $Timer  # Añade Timer como hijo del enemigo
@onready var sprite = find_child("Sprite2D")  # Ajusta la ruta según tu escena

# Configurables
@export var speed: float = 50.0
@export var move_direction: float = 1.0  # 1 = derecha, -1 = izquierda

func _ready():
	# Configurar timer para muerte
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	# Configurar detección de colisiones
	add_to_group("enemies")

func _physics_process(delta):
	# Movimiento horizontal
	velocity.x = speed * move_direction
	velocity.y = 0  # Los enemigos no se mueven verticalmente
	
	# Aplicar gravedad si es necesario
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	
	move_and_slide()
	
	# Detectar colisiones con paredes u otros enemigos
	if is_on_wall():
		_change_direction()
	
	# Detectar caída de plataformas (opcional - si quieres que den vuelta en bordes)
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

func _on_body_entered(body):
	if body is KaleidoController:
		print("Enemigo: Jugador murió")
		# Resetear monedas y metas
		GameManager.reset_coins()
		GameManager._close_all_goals()
		
		# Iniciar timer para reinicio
		timer.start()

func _on_area_entered(area):
	# Colisión con otros enemigos
	if area.is_in_group("enemies"):
		_change_direction()

func _on_timer_timeout():
	print("Enemigo: Reiniciando escena")
	get_tree().reload_current_scene()
