extends Node

signal transition_finished

var color_rect: ColorRect
var animation_player: AnimationPlayer
var canvas_layer: CanvasLayer
var scene_loaded: bool = false
var initializing: bool = false  # Para evitar bucles

func _ready():
	if initializing:
		return
		
	initializing = true
	print("🎬 Transicion Autoload inicializando...")
	_instantiate_scene()

func _instantiate_scene():
	# Verificar si ya existe una instancia
	if get_tree().get_nodes_in_group("transicion_system").size() > 0:
		print("⚠️ Sistema de transición ya existe, omitiendo...")
		return
	
	var scene_path = "res://Assets/Scenes/UI/Transicion.tscn"
	print("📁 Intentando cargar escena: ", scene_path)
	
	var packed_scene = load(scene_path)
	
	if packed_scene:
		# Instanciar la escena completa
		var scene_instance = packed_scene.instantiate()
		
		# Añadir al árbol de escenas como hijo de la raíz
		get_tree().root.add_child(scene_instance)
		
		# Añadir a grupo para evitar duplicados
		scene_instance.add_to_group("transicion_system")
		
		# Guardar referencia al CanvasLayer
		canvas_layer = scene_instance
		
		# Buscar los nodos hijos
		_find_nodes_in_scene(scene_instance)
		
		if color_rect and animation_player:
			scene_loaded = true
			print("✅ Escena Transicion instanciada correctamente")
			_configure_nodes()
		else:
			push_error("❌ No se encontraron todos los nodos en la escena instanciada")
			_create_fallback_nodes()
	else:
		push_error("❌ No se pudo cargar la escena: ", scene_path)
		_create_fallback_nodes()

func _find_nodes_in_scene(scene_instance: Node):
	print("🔍 Buscando nodos en escena instanciada...")
	
	# BUSCAR ColorRect
	color_rect = scene_instance.get_node_or_null("ColorRect")
	if color_rect == null:
		# Buscar recursivamente
		color_rect = _find_node_recursive(scene_instance, "ColorRect") as ColorRect
	
	# BUSCAR AnimationPlayer
	animation_player = scene_instance.get_node_or_null("AnimationPlayer")
	if animation_player == null:
		# Buscar recursivamente
		animation_player = _find_node_recursive(scene_instance, "AnimationPlayer") as AnimationPlayer
	
	print("🔍 Resultados búsqueda:")
	print("   ColorRect: ", color_rect != null)
	print("   AnimationPlayer: ", animation_player != null)

func _find_node_recursive(root: Node, node_name: String) -> Node:
	if root.name == node_name:
		return root
	
	for child in root.get_children():
		var result = _find_node_recursive(child, node_name)
		if result:
			return result
	
	return null

func _create_fallback_nodes():
	print("🚨 Creando nodos de fallback...")
	
	# Crear CanvasLayer
	canvas_layer = CanvasLayer.new()
	canvas_layer.name = "Transicion"
	canvas_layer.layer = 100
	canvas_layer.follow_viewport_enabled = true
	get_tree().root.add_child(canvas_layer)
	canvas_layer.add_to_group("transicion_system")
	
	# CREAR ColorRect
	color_rect = ColorRect.new()
	color_rect.name = "ColorRect"
	color_rect.color = Color.BLACK
	color_rect.anchor_left = 0.0
	color_rect.anchor_top = 0.0
	color_rect.anchor_right = 1.0
	color_rect.anchor_bottom = 1.0
	color_rect.visible = false
	canvas_layer.add_child(color_rect)
	
	# CREAR AnimationPlayer
	animation_player = AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	canvas_layer.add_child(animation_player)
	
	scene_loaded = true
	print("⚠️ Nodos de fallback creados")

func _configure_nodes():
	if color_rect:
		color_rect.visible = false
		print("✅ ColorRect configurado")
	else:
		push_error("❌ ColorRect NO encontrado")
	
	if animation_player:
		if animation_player.animation_finished.is_connected(_on_animation_finished):
			animation_player.animation_finished.disconnect(_on_animation_finished)
		animation_player.animation_finished.connect(_on_animation_finished)
		print("✅ AnimationPlayer configurado")
		
		# LISTAR ANIMACIONES DISPONIBLES
		print("🎭 Animaciones en AnimationPlayer:")
		var anim_list = animation_player.get_animation_list()
		if anim_list.size() > 0:
			for anim in anim_list:
				print("   - ", anim)
		else:
			print("   (ninguna animación encontrada)")
	else:
		push_error("❌ AnimationPlayer NO encontrado")

func start_transition():
	print("🎬 Iniciando transición...")
	
	if not scene_loaded or color_rect == null or animation_player == null:
		push_error("❌ No se puede iniciar transición - sistema no inicializado")
		await get_tree().process_frame
		transition_finished.emit()
		return
	
	color_rect.visible = true
	
	if animation_player.has_animation("fade_out"):
		animation_player.play("fade_out")
		print("✅ Animación fade_out iniciada")
	else:
		push_error("❌ Animación fade_out no encontrada")
		await get_tree().create_timer(0.5).timeout
		transition_finished.emit()

func _on_animation_finished(anim_name):
	print("🔚 Animación terminada: ", anim_name)
	
	if anim_name == "fade_out":
		print("🎬 Fade_out completado")
		transition_finished.emit()
		
		if animation_player.has_animation("fade_in"):
			animation_player.play("fade_in")
			print("✅ Animación fade_in iniciada")
		else:
			color_rect.visible = false
			
	elif anim_name == "fade_in":
		print("🎬 Fade_in completado")
		color_rect.visible = false

# Función para probar la transición
func test_transition():
	print("🧪 TEST: Probando transición...")
	start_transition()
