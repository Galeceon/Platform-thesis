extends Area2D


@onready var audio_player = $AudioStreamPlayer
@onready var coin_sprite = find_child("Sprite2D2")

func _on_body_entered(body):
	if body is KaleidoController:
		GameManager.add_coin()
		# Verifica que el sprite y el audio existan antes de usarlos
		if audio_player and coin_sprite:
			audio_player.play()
			coin_sprite.visible = false
		
		# Deshabilita la colisión para evitar más interacciones
		set_collision_mask_value(1, false)
		
		# Espera a que termine el sonido y elimina el nodo
		if audio_player and audio_player.is_playing():
			await audio_player.finished
		queue_free()
