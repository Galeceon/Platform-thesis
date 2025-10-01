# Rio.gd
extends Area2D

func _ready():
	# Asegurar que la señal esté conectada
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is KaleidoController:
		print("Río: Jugador tocó el agua - emitiendo player_died")
		# Solo emitir la señal - el GameManager se encarga del resto
		body.emit_signal("player_died")
