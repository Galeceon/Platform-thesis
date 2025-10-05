# BaseMenu.gd
extends CanvasLayer
class_name BaseMenu

# Variable para trackear el botón seleccionado
var current_button_index: int = 0
var buttons: Array[Button] = []

func _ready():
	# Encontrar todos los botones en el contenedor principal
	_find_buttons()
	update_button_focus()

func _find_buttons():
	# Buscar el contenedor principal (ajusta la ruta según tu escena)
	var container = get_node("VBoxContainer")
	if container:
		for child in container.get_children():
			if child is Button:
				buttons.append(child)
	
	print("Found ", buttons.size(), " buttons in menu")

func _input(event):
	# Solo procesar input si este menú está visible
	if not visible:
		return
	
	# Navegación con teclado
	if event.is_action_pressed("move_up"):
		current_button_index = wrapi(current_button_index - 1, 0, buttons.size())
		update_button_focus()
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("move_down"):
		current_button_index = wrapi(current_button_index + 1, 0, buttons.size())
		update_button_focus()
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("jump") or event.is_action_pressed("ui_accept"):
		if buttons.size() > 0:
			buttons[current_button_index].emit_signal("pressed")
			get_viewport().set_input_as_handled()

func update_button_focus():
	for i in range(buttons.size()):
		if i == current_button_index:
			buttons[i].grab_focus()
		else:
			buttons[i].release_focus()

# Función para resetear la selección cuando el menú se muestra
func show_menu():
	visible = true
	current_button_index = 0
	update_button_focus()
