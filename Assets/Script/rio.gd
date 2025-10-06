# Rio.gd
extends Area2D

@onready var timer = $Timer

func _ready():
	# Configurar el timer
	timer.wait_time = 0.2
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	# Conectar la señal body_entered
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is KaleidoController:
		print("🌊 Río: Jugador tocó el agua - iniciando timer de 0.2s")
		timer.start()

func _on_timer_timeout():
	print("⏰ Río: Timer completado - llamando muerte del jugador")
	
	# Buscar al jugador y llamar a su método de muerte directamente
	var player = get_tree().get_first_node_in_group("player") as KaleidoController
	if player:
		player.player_died.emit()
	else:
		print("❌ Río: No se encontró jugador")
