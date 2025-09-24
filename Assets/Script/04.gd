extends Node2D

func _ready():
	# Conecta la señal `player_entered_water` del Area2D a esta clase
	# Asumiendo que el Area2D del río está en la ruta:
	var river_area = get_node("CanvasLayer2/rio/Area2D")
	if river_area != null:
		river_area.connect("player_entered_water", Callable(self, "_on_player_entered_water"))


func _on_area_2d_body_entered(body):
	if body is KaleidoController:
		var timer = get_node("Timer")
		if timer:
			timer.start()


func _on_timer_timeout():
	get_tree().reload_current_scene()
