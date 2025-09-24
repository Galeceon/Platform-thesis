extends Area2D
class_name AreaExit

var is_open = false

func _ready():
	#Cerrar la meta
	close()

func open():
	is_open = true

func close():
	is_open = false

func _on_body_entered(body):
	if is_open && body is KaleidoController:
		GameManager.next_level()
