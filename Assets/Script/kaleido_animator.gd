extends Node2D

@export var kaleido_controller : KaleidoController
@export var animation_player : AnimationPlayer
@export var sprite : Sprite2D

func _process(delta):
	#Cambiar de lado el sprite del personaje
	if kaleido_controller.direction == 1:
		sprite.flip_h = false
	elif kaleido_controller.direction == -1:
		sprite.flip_h = true
	
	#Evento para transición a movimiento y fuera de movimiento
	if abs(kaleido_controller.velocity.x) > 0.0:
		animation_player.play("move") #Nombre de la animación de movimiento
	else:
		animation_player.play("idle") #Nombre de la animación de idle (sin movimiento)
	
	#Evento para reproducir la animación de salto // Godot utiliza -y para subir, +y para bajar
	if kaleido_controller.velocity.y < 0.0:
		animation_player.play("jump") #Animación para saltar
	elif kaleido_controller.velocity.y > 0.0:
		animation_player.play("fal") #Animación para caer
