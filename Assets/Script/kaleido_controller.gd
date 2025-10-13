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

# NUEVO: Referencia al Sprite2D dentro de AgentAnimator
var sprite: Sprite2D

func _ready():
	add_to_group("player")
	
	# Esperar a que ConfigManager esté listo
	call_deferred("_setup_character_skin")

func _setup_character_skin():
	# Buscar el Sprite2D dentro de AgentAnimator
	sprite = get_node_or_null("AgentAnimator/Sprite2D")
	
	if sprite:
		print("✅ Sprite2D encontrado en AgentAnimator")
		_apply_character_skin()  # Aplicar skin al cargar
		
		# Conectar señal por si cambia durante el juego
		if ConfigManager.character_skin_changed.is_connected(_on_character_skin_changed):
			ConfigManager.character_skin_changed.disconnect(_on_character_skin_changed)
		ConfigManager.character_skin_changed.connect(_on_character_skin_changed)
	else:
		print("❌ ERROR: No se pudo encontrar Sprite2D en AgentAnimator/Sprite2D")
		# Debug: ver qué hay en AgentAnimator
		var agent_animator = get_node_or_null("AgentAnimator")
		if agent_animator:
			print("🔍 Nodos hijos de AgentAnimator:")
			for child in agent_animator.get_children():
				print("   - ", child.name, " (", child.get_class(), ")")

func _apply_character_skin():
	if not sprite:
		print("❌ No se puede aplicar skin - Sprite2D es null")
		return
	
	# Manejo seguro en caso de error
	var skin_id = 1
	if ConfigManager.config.has("character_skin"):
		skin_id = ConfigManager.get_character_skin()
	else:
		print("⚠️  character_skin no encontrado, usando valor por defecto (1)")
		skin_id = 1
	
	var texture_path = "res://Assets/Sprites/kaleido/kaleido-%d.png" % skin_id
	var texture = load(texture_path)
	
	if texture:
		sprite.texture = texture
		print("✅ Aplicada skin del personaje: ", skin_id, " (", texture_path, ")")
	else:
		print("❌ No se pudo cargar skin: ", texture_path)
		# MEJORADO: Sistema de fallback robusto
		_apply_fallback_skin(skin_id)

# NUEVA FUNCIÓN: Sistema de fallback mejorado
func _apply_fallback_skin(failed_skin_id: int):
	print("🔄 Intentando aplicar fallback para skin fallida: ", failed_skin_id)
	
	# Intentar skins en este orden: 1, 2, 3, 4
	var fallback_order = [1, 2, 3, 4]
	
	for fallback_id in fallback_order:
		# Saltar la skin que ya falló
		if fallback_id == failed_skin_id:
			continue
			
		var fallback_path = "res://Assets/Sprites/kaleido/kaleido-%d.png" % fallback_id
		var fallback_texture = load(fallback_path)
		
		if fallback_texture:
			sprite.texture = fallback_texture
			print("✅ Fallback exitoso: skin ", fallback_id, " aplicada en lugar de ", failed_skin_id)
			
			# Opcional: Actualizar ConfigManager con la skin válida
			ConfigManager.set_character_skin(fallback_id)
			return
	
	# Si llegamos aquí, ningún fallback funcionó
	print("❌ CRÍTICO: No se pudo cargar ninguna skin de fallback")
	# Intentar cargar cualquier textura disponible
	_try_emergency_texture()

# FUNCIÓN DE EMERGENCIA: Intentar cargar cualquier textura
func _try_emergency_texture():
	# Buscar cualquier archivo .png en la carpeta de sprites
	var dir = DirAccess.open("res://Assets/Sprites/kaleido/")
	if dir:
		var files = dir.get_files()
		for file in files:
			if file.get_extension().to_lower() == "png":
				var emergency_path = "res://Assets/Sprites/kaleido/" + file
				var emergency_texture = load(emergency_path)
				if emergency_texture:
					sprite.texture = emergency_texture
					print("🚨 Textura de emergencia cargada: ", file)
					return
	
	# Último recurso: crear un sprite rojo temporal
	print("💥 Creando sprite de emergencia temporal")
	sprite.texture = _create_emergency_texture()

func _create_emergency_texture():
	# Crear una textura roja simple como último recurso
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.RED)
	var texture = ImageTexture.create_from_image(image)
	return texture

func _on_character_skin_changed(skin_id: int):
	print("🔄 Cambiando skin del personaje a: ", skin_id)
	_apply_character_skin()

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

# Añade esto al KaleidoController.gd para probar las skins
func _input(event):	
	if get_tree().paused:
		return
	
	# Tecla para abrir/cerrar pausa (normalmente ESC o P)
	if event.is_action_pressed("ui_cancel"):  # ESC key
		if GameManager and GameManager.can_pause():
			GameManager.toggle_pause_menu()
			get_viewport().set_input_as_handled()

	if event.is_action_pressed("ui_1"):
		ConfigManager.set_character_skin(1)
		print("🎨 DEBUG: Skin cambiada a 1")
	elif event.is_action_pressed("ui_2"):
		ConfigManager.set_character_skin(2)
		print("🎨 DEBUG: Skin cambiada a 2")
	elif event.is_action_pressed("ui_3"):
		ConfigManager.set_character_skin(3)
		print("🎨 DEBUG: Skin cambiada a 3")
	elif event.is_action_pressed("ui_4"):
		ConfigManager.set_character_skin(4)
		print("🎨 DEBUG: Skin cambiada a 4")
	elif event.is_action_pressed("ui_5"):
		# Probar skin inválida (debería usar fallback)
		ConfigManager.set_character_skin(99)
		print("🎨 DEBUG: Skin inválida - probando fallback")
	elif event.is_action_pressed("ui_6"):
		# Probar skin que no existe
		ConfigManager.set_character_skin(999)
		print("🎨 DEBUG: Skin inexistente - probando fallback extremo")
