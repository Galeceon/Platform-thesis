# Transicion.gd
extends CanvasLayer

signal transition_finished

var color_rect: ColorRect
var animation_player: AnimationPlayer

func _ready():
	# INICIALIZAR CORRECTAMENTE
	color_rect = get_node("ColorRect")
	animation_player = get_node("AnimationPlayer")
	
	print("🔍 Transicion - ColorRect: ", color_rect)
	print("🔍 Transicion - AnimationPlayer: ", animation_player)
	
	if color_rect:
		color_rect.visible = false
		print("✅ ColorRect configurado")
	else:
		push_error("❌ ColorRect NO encontrado. Estructura de la escena:")
		print("   Nodos hijos: ", get_children())
		for child in get_children():
			print("   - ", child.name, " (", child.get_class(), ")")
	
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)
		print("✅ AnimationPlayer configurado")
	else:
		push_error("❌ AnimationPlayer NO encontrado")

func start_transition():
	print("🎬 TRANSICION start_transition()")
	print("🎬 ColorRect: ", color_rect)
	print("🎬 AnimationPlayer: ", animation_player)
	
	if color_rect == null or animation_player == null:
		push_error("❌ NO se puede iniciar transición - nodos faltantes")
		# EMITIR SEÑAL DE TODAS FORMAS PARA NO BLOQUEAR EL JUEGO
		await get_tree().process_frame
		transition_finished.emit()
		return
	
	color_rect.visible = true
	
	if animation_player.has_animation("fade_out"):
		animation_player.play("fade_out")
		print("✅ Animación fade_out iniciada")
	else:
		push_error("❌ Animación fade_out no encontrada")
		# FADE MANUAL SI NO HAY ANIMACIÓN
		await get_tree().create_timer(0.5).timeout
		transition_finished.emit()

func _on_animation_finished(anim_name):
	print("🔚 Animación terminada: ", anim_name)
	if anim_name == "fade_out":
		transition_finished.emit()
		if animation_player.has_animation("fade_in"):
			animation_player.play("fade_in")
	elif anim_name == "fade_in":
		color_rect.visible = false
