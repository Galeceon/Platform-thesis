# puzzle.gd
extends CanvasLayer

signal puzzle_solved
const PUZZLE_SIZE = 3
const TARGET_BOARD = [1, 2, 3, 4, 5, 6, 7, 8, 0]

@export var background_music: AudioStream

# Referencias a nodos
@onready var background = $Background
@onready var puzzle_background = $PuzzleBackground
@onready var puzzle_container = $PuzzleContainer
@onready var grid_container = $PuzzleContainer/GridContainer
@onready var audio_player = $AudioStreamPlayer

var board = []
var empty_pos = Vector2(PUZZLE_SIZE - 1, PUZZLE_SIZE - 1)
var current_level = 1
var tile_size = Vector2.ZERO  # Variable para almacenar el tamaño fijo de las tiles

# --- Inicialización y Configuración ---

func _ready():
	# Obtener el nivel actual del GameManager
	current_level = GameManager.current_area
	
	# Configurar para funcionar aunque el juego esté pausado
	set_process_unhandled_input(true)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Configurar fondos y música
	_setup_backgrounds()
	_setup_background_music()
	
	# Configurar el contenedor del puzzle Y CALCULAR TAMAÑO DE TILES
	_setup_puzzle_container()
	
	# Mezclar y configurar el tablero
	_shuffle_board()
	_draw_board()

func _setup_backgrounds():
	# Configurar fondo principal (01.png, 02.png, etc.)
	var main_bg_path = "res://Assets/Sprites/UI/Puzzles/Fondo/%02d.png" % current_level
	var main_bg_texture = load(main_bg_path)
	
	if main_bg_texture:
		background.texture = main_bg_texture
		print("✅ Fondo principal aplicado: ", main_bg_path)
	else:
		print("❌ Error cargando fondo principal: ", main_bg_path)
	
	# Configurar fondo del puzzle (background.png)
	var puzzle_bg_path = "res://Assets/Sprites/UI/Puzzles/%02d/background.png" % current_level
	var puzzle_bg_texture = load(puzzle_bg_path)
	
	if puzzle_bg_texture:
		puzzle_background.texture = puzzle_bg_texture
		print("✅ Fondo del puzzle aplicado: ", puzzle_bg_path)
	else:
		print("❌ Error cargando fondo del puzzle: ", puzzle_bg_path)

func _setup_puzzle_container():
	# USAR LAS COORDENADAS EXACTAS DEL EDITOR:
	var puzzle_position = Vector2(420, 220)  # Posición del PuzzleContainer
	var puzzle_size = Vector2(307, 294)      # Tamaño del PuzzleContainer
	
	# Configurar el contenedor del puzzle con los valores del editor
	puzzle_container.position = puzzle_position
	puzzle_container.size = puzzle_size
	
	# Configurar el GridContainer para que ocupe TODO el espacio del puzzle_container
	var grid_size = puzzle_size  # Mismo tamaño que el contenedor padre
	var grid_position = Vector2.ZERO  # Posición dentro del contenedor padre
	
	grid_container.size = grid_size
	grid_container.position = grid_position
	
	# Configurar GridContainer para layout controlado
	grid_container.size_flags_horizontal = Control.SIZE_FILL
	grid_container.size_flags_vertical = Control.SIZE_FILL
	
	# Forzar que las columnas tengan tamaño fijo
	grid_container.columns = PUZZLE_SIZE
	
	# Añadir separación entre piezas (mínima)
	grid_container.add_theme_constant_override("h_separation", 2)
	grid_container.add_theme_constant_override("v_separation", 2)
	
	# CALCULAR EL TAMAÑO FIJO DE LAS TILES UNA SOLA VEZ
	tile_size.x = (grid_size.x - (2 * (PUZZLE_SIZE - 1))) / PUZZLE_SIZE
	tile_size.y = (grid_size.y - (2 * (PUZZLE_SIZE - 1))) / PUZZLE_SIZE
	
	print("🎯 Puzzle configurado desde valores del editor:")
	print("  PuzzleContainer - Posición: ", puzzle_position, " Tamaño: ", puzzle_size)
	print("  GridContainer - Tamaño: ", grid_size)
	print("  Tile size FIJO: ", tile_size)

func _setup_background_music():
	# Asignar la música si se configuró
	if background_music:
		audio_player.stream = background_music
		audio_player.volume_db = -10.0
		
		# APLICAR EL VOLUMEN CONFIGURADO - ESTA ES LA LÍNEA QUE FALTA
		ConfigManager.apply_volume_to_player(audio_player)
		
		audio_player.play()
		print("🎵 Música del puzzle iniciada")
	else:
		print("⚠️  No hay música asignada para el puzzle")

func connect_win_signal(callable):
	puzzle_solved.connect(callable)

# --- Lógica de Mezcla (Shuffle) ---

func _shuffle_board():
	"""Mezcla el tablero realizando movimientos aleatorios (garantiza resolubilidad)."""
	
	board = TARGET_BOARD.duplicate()
	empty_pos = Vector2(PUZZLE_SIZE - 1, PUZZLE_SIZE - 1)
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var shuffle_moves = 100 
	
	for i in shuffle_moves:
		var valid_moves = []
		
		var adjacent_pos = [
			Vector2(empty_pos.x + 1, empty_pos.y),
			Vector2(empty_pos.x - 1, empty_pos.y),
			Vector2(empty_pos.x, empty_pos.y + 1),
			Vector2(empty_pos.x, empty_pos.y - 1)
		]
		
		for pos in adjacent_pos:
			if pos.x >= 0 and pos.x < PUZZLE_SIZE and pos.y >= 0 and pos.y < PUZZLE_SIZE:
				valid_moves.append(pos)
		
		if valid_moves.size() > 0:
			var chosen_pos = valid_moves[rng.randi_range(0, valid_moves.size() - 1)]
			var chosen_index = int(chosen_pos.y * PUZZLE_SIZE + chosen_pos.x)
			var empty_index = board.find(0)
			
			# Intercambio manual
			var temp = board[chosen_index]
			board[chosen_index] = board[empty_index]
			board[empty_index] = temp
			
			empty_pos = chosen_pos

# --- Detección de Input y Movimiento ---

func _unhandled_input(event):
	"""Maneja el input del teclado"""
	if not event.is_pressed():
		return

	var tile_to_move_pos = Vector2(-1, -1)
	
	# Lógica de Teclado
	if event.is_action_pressed("move_right") and empty_pos.x > 0:
		tile_to_move_pos = Vector2(empty_pos.x - 1, empty_pos.y)
	elif event.is_action_pressed("move_left") and empty_pos.x < PUZZLE_SIZE - 1:
		tile_to_move_pos = Vector2(empty_pos.x + 1, empty_pos.y)
	elif event.is_action_pressed("move_down") and empty_pos.y > 0:
		tile_to_move_pos = Vector2(empty_pos.x, empty_pos.y - 1)
	elif event.is_action_pressed("move_up") and empty_pos.y < PUZZLE_SIZE - 1:
		tile_to_move_pos = Vector2(empty_pos.x, empty_pos.y + 1)
	
	if tile_to_move_pos != Vector2(-1, -1):
		_move_tile_logic(tile_to_move_pos)
		get_viewport().set_input_as_handled()

func _on_tile_clicked(tile_value):
	"""Maneja el click del mouse, moviendo la ficha clickeada si es adyacente."""
	var tile_index = board.find(tile_value)
	var empty_index = board.find(0)
	
	var tile_pos = Vector2(tile_index % PUZZLE_SIZE, floor(tile_index / PUZZLE_SIZE))
	var empty_pos_temp = Vector2(empty_index % PUZZLE_SIZE, floor(empty_index / PUZZLE_SIZE))
	
	if _is_adjacent(tile_pos, empty_pos_temp):
		_move_tile_logic(tile_pos) 

func _move_tile_logic(tile_pos_vec):
	"""Lógica central de movimiento y actualización."""
	var tile_index = int(tile_pos_vec.y * PUZZLE_SIZE + tile_pos_vec.x)
	var empty_index = board.find(0)

	# Intercambio manual
	var temp = board[tile_index]
	board[tile_index] = board[empty_index]
	board[empty_index] = temp
	
	empty_pos = tile_pos_vec
	
	_draw_board() 
	_check_win_condition()

# --- Renderizado y Utilidades ---

func _draw_board():
	# Limpiar el grid container
	for child in grid_container.get_children():
		child.queue_free()

	print("📐 Usando tile size FIJO: ", tile_size)
	
	# Crear las piezas del puzzle usando el tamaño fijo
	for tile_value in board:
		var tile_node
		
		if tile_value == 0:
			# Espacio vacío - crear un control vacío
			tile_node = Control.new()
			tile_node.custom_minimum_size = tile_size
			tile_node.size = tile_size
		else:
			# Pieza con imagen
			tile_node = _create_visual_tile(tile_value, tile_size)
			# Conecta el botón para que el click funcione
			tile_node.connect("pressed", Callable(self, "_on_tile_clicked").bind(tile_value))
		
		grid_container.add_child(tile_node)

func _is_adjacent(p1, p2):
	var dx = abs(p1.x - p2.x)
	var dy = abs(p1.y - p2.y)
	return (dx == 1 and dy == 0) or (dx == 0 and dy == 1)

func _check_win_condition():
	if board == TARGET_BOARD:
		print("🎉 ¡Puzzle completado!")
		if audio_player and audio_player.playing:
			audio_player.stop()
		# Reanudar el juego ANTES de emitir la señal
		get_tree().paused = false
		puzzle_solved.emit()
		queue_free()

func _create_visual_tile(value, size):
	"""Crea un botón con la imagen correspondiente a la pieza."""
	var tile = TextureButton.new()
	
	# Tamaño FIJO usando el valor precalculado
	tile.custom_minimum_size = size
	tile.size = size
	
	# IMPORTANTE: Desactivar expansión para mantener tamaño fijo
	tile.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tile.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# Configurar para que la imagen se ESCALE al tamaño del botón
	tile.stretch_mode = TextureButton.STRETCH_SCALE
	
	# Ignorar el tamaño original de la textura
	tile.ignore_texture_size = true
	
	# Desactivar el foco
	tile.focus_mode = Control.FOCUS_NONE
	
	# Cargar la textura
	var texture_path = "res://Assets/Sprites/UI/Puzzles/%02d/%d.png" % [current_level, value]
	var texture = load(texture_path)
	
	if texture:
		tile.texture_normal = texture
	else:
		print("❌ Error cargando pieza: ", texture_path)
		# Fallback: mostrar el número
		var label = Label.new()
		label.text = str(value)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		tile.add_child(label)
	
	return tile
