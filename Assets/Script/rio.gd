extends Area2D

signal player_entered_water

func _on_body_entered(body): #Glugluglu
	if body is KaleidoController:
		emit_signal("player_entered_water")
