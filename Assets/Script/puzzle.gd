# puzzle.gd (Script Final y Completo para Godot 4.2.2)
extends CanvasLayer

signal puzzle_solved
const PUZZLE_SIZE = 3 # Cambiar a 3 para 3x3, 4 para 4x4
const TARGET_BOARD = [1, 2, 3, 4, 5, 6, 7, 8, 0]
#Puzzle 3x3=  [1, 2, 3, 4, 5, 6, 7, 8, 0]
#Puzzle 4x4 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0] 
#Cambiar tambien el GridContainer > Columns a 3

@export var level_image: Texture2D
@export var background_music: AudioStream
var grid_container: GridContainer # Declaración sin @onready
var board = []
var empty_pos = Vector2(PUZZLE_SIZE - 1, PUZZLE_SIZE - 1)
var audio_player: AudioStreamPlayer

# --- Inicialización y Configuración ---

func _ready():
	# Inicialización segura del GridContainer
	grid_container = get_node("ColorRect/CenterContainer/GridContainer")
	
	if not is_instance_valid(grid_container):
		push_error("ERROR: No se pudo encontrar el GridContainer. Verifica la ruta.")
		queue_free()
		return
	
	# IMPORTANTE: Configurar el proceso para que funcione aunque el juego esté pausado
	set_process_unhandled_input(true)
	process_mode = Node.PROCESS_MODE_ALWAYS  # Esto permite que el puzzle reciba input aunque el juego esté pausado
	
	_setup_background_music()
	
	# Mezclar y configurar el tablero
	_shuffle_board()
	_draw_board()

func _setup_background_music():
	# Crear el AudioStreamPlayer si no existe
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Asignar la música si se configuró
	if background_music:
		audio_player.stream = background_music
		audio_player.volume_db = -10.0  # Ajusta el volumen si es necesario
		audio_player.play()
	else:
		print("Advertencia: No hay música asignada para el puzzle")

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
			
			# Intercambio manual (solución al error 'swap' de Godot 4)
			var temp = board[chosen_index]
			board[chosen_index] = board[empty_index]
			board[empty_index] = temp
			
			empty_pos = chosen_pos

# --- Detección de Input y Movimiento ---

func _unhandled_input(event):
	"""Maneja el input del teclado"""
	# IMPORTANTE: Quitamos la verificación de pausa aquí
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
	print("Clicked tile: ", tile_value) # Deja el print para la depuración
	
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
	for child in grid_container.get_children():
		child.queue_free()

	for tile_value in board:
		var tile_node
		
		if tile_value == 0:
			tile_node = Control.new()
		else:
			tile_node = _create_visual_tile(tile_value)
			# Conecta el botón para que el click funcione
			tile_node.connect("pressed", Callable(self, "_on_tile_clicked").bind(tile_value))
		
		grid_container.add_child(tile_node)

func _is_adjacent(p1, p2):
	var dx = abs(p1.x - p2.x)
	var dy = abs(p1.y - p2.y)
	return (dx == 1 and dy == 0) or (dx == 0 and dy == 1)

# También modifica la función de victoria para reanudar correctamente
func _check_win_condition():
	if board == TARGET_BOARD:
		if audio_player and audio_player.playing:
			audio_player.stop()
		# IMPORTANTE: Reanudar el juego ANTES de emitir la señal
		get_tree().paused = false
		puzzle_solved.emit()
		queue_free()

func _create_visual_tile(value):
	"""Crea un nodo Button para la prueba con números."""
	var tile = Button.new()
	tile.custom_minimum_size = Vector2(100, 100)
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tile.text = str(value) 
	
	# 💥 SOLUCIÓN CRÍTICA: Desactivar el foco para que el input de teclado 
	# llegue a _unhandled_input en lugar de ser consumido por el botón.
	tile.focus_mode = Control.FOCUS_NONE 
	
	return tile
