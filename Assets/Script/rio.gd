# Rio.gd
extends Area2D

@onready var timer = $Timer  # Asegúrate de añadir un Timer como hijo del río

func _ready():
	# Configurar el timer
	timer.wait_time = 0.2
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	# Conectar la señal body_entered
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is KaleidoController:
		print("Río: Jugador tocó el agua - iniciando timer de 0.2s")
		# Iniciar timer en lugar de emitir inmediatamente
		timer.start()

func _on_timer_timeout():
	print("Río: Timer completado - emitiendo player_died")
	# Buscar al jugador para emitir la señal
	var player = get_tree().get_first_node_in_group("player") as KaleidoController
	if player:
		player.emit_signal("player_died")
