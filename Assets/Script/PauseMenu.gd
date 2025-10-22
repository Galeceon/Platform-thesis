# PauseMenu.gd
extends CanvasLayer

@onready var background = $Background
@onready var close_button = $Background/close_button
@onready var retry_button = $Background/retry_button
@onready var home_button = $Background/home_button
@onready var sonido_on = $Background/sonido_on
@onready var sonido_off = $Background/sonido_off

# Texturas para el fondo del menú de pausa
var background_textures = {
	"light": {
		"es": "res://Assets/Sprites/UI/Pausa/pausa_es_light.png",
		"en": "res://Assets/Sprites/UI/Pausa/pausa_en_light.png"
	},
	"dark": {
		"es": "res://Assets/Sprites/UI/Pausa/pausa_es_dark.png",
		"en": "res://Assets/Sprites/UI/Pausa/pausa_en_dark.png"
	}
}

# Texturas para el botón cerrar/reanudar - CON IDIOMA
var close_button_textures = {
	"light": {
		"es": "res://Assets/Sprites/UI/Botones/Modo Claro/es_reanudar.png",
		"en": "res://Assets/Sprites/UI/Botones/Modo Claro/en_reanudar.png"
	},
	"dark": {
		"es": "res://Assets/Sprites/UI/Botones/Modo Oscuro/es_reanudar.png",
		"en": "res://Assets/Sprites/UI/Botones/Modo Oscuro/en_reanudar.png"
	}
}

# Texturas para todos los botones (sin idioma)
var button_textures = {
	"light": {
		"retry": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Claro/reintentar.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Oscuro/reintentar.png"
		},
		"home": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Claro/es_inicio.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Oscuro/inicio.png"
		},
		"sonido_on": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Claro/sonido_on.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Oscuro/sound_on.png"
		},
		"sonido_off": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Claro/sonido_off.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Oscuro/sound_off.png"
		}
	},
	"dark": {
		"retry": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Oscuro/reintentar.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Claro/reintentar.png"
		},
		"home": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Oscuro/inicio.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Claro/inicio.png"
		},
		"sonido_on": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Oscuro/sound_on.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Claro/sonido_on.png"
		},
		"sonido_off": {
			"normal": "res://Assets/Sprites/UI/Botones/Modo Oscuro/sound_off.png",
			"hover": "res://Assets/Sprites/UI/Botones/Modo Claro/sonido_off.png"
		}
	}
}

var main_menu_scene = preload("res://Assets/Scenes/UI/MainMenu.tscn")

func _ready():
	# Aplicar configuración inicial
	_apply_configuration()
	
	# Conectar señales de los botones
	close_button.pressed.connect(_on_close_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	home_button.pressed.connect(_on_home_pressed)
	sonido_on.pressed.connect(_on_sonido_on_pressed)
	sonido_off.pressed.connect(_on_sonido_off_pressed)
	
	# Conectar señales de hover
	close_button.mouse_entered.connect(_on_close_button_mouse_entered)
	close_button.mouse_exited.connect(_on_close_button_mouse_exited)
	retry_button.mouse_entered.connect(_on_retry_button_mouse_entered)
	retry_button.mouse_exited.connect(_on_retry_button_mouse_exited)
	home_button.mouse_entered.connect(_on_home_button_mouse_entered)
	home_button.mouse_exited.connect(_on_home_button_mouse_exited)
	sonido_on.mouse_entered.connect(_on_sonido_on_mouse_entered)
	sonido_on.mouse_exited.connect(_on_sonido_on_mouse_exited)
	sonido_off.mouse_entered.connect(_on_sonido_off_mouse_entered)
	sonido_off.mouse_exited.connect(_on_sonido_off_mouse_exited)
	
	# Conectar a cambios de configuración
	ConfigManager.color_mode_changed.connect(_on_config_changed)
	ConfigManager.language_changed.connect(_on_config_changed)
	ConfigManager.sound_volume_changed.connect(_on_sound_volume_changed)
	
	# Actualizar estado inicial de botones de sonido
	_actualizar_estado_sonido()
	
	print("✅ Menú de pausa cargado - En árbol: ", is_inside_tree())

func _apply_configuration():
	var mode = ConfigManager.get_color_mode()
	var language = ConfigManager.get_language()
	
	# Aplicar fondo
	if background_textures.has(mode) and background_textures[mode].has(language):
		var texture_path = background_textures[mode][language]
		var texture = load(texture_path)
		if texture:
			background.texture = texture
			print("✅ Fondo de pausa aplicado: ", texture_path)
		else:
			print("❌ No se pudo cargar textura de fondo: ", texture_path)
	
	# Aplicar botón cerrar/reanudar (con idioma)
	if close_button_textures.has(mode) and close_button_textures[mode].has(language):
		var close_texture_path = close_button_textures[mode][language]
		var close_texture = load(close_texture_path)
		if close_texture:
			close_button.texture_normal = close_texture
			print("✅ Botón cerrar/reanudar aplicado: ", close_texture_path)
			
			# Aplicar hover (modo opuesto mismo idioma)
			var modo_opuesto = "light" if mode == "dark" else "dark"
			if close_button_textures.has(modo_opuesto) and close_button_textures[modo_opuesto].has(language):
				var hover_texture_path = close_button_textures[modo_opuesto][language]
				var hover_texture = load(hover_texture_path)
				if hover_texture:
					close_button.texture_hover = hover_texture
					print("✅ Hover de cerrar/reanudar aplicado: ", hover_texture_path)
		else:
			print("❌ No se pudo cargar textura de cerrar: ", close_texture_path)
	
	# Aplicar otros botones CON HOVER (sin idioma)
	if button_textures.has(mode):
		var buttons = button_textures[mode]
		
		# Botón reintentar
		if buttons.has("retry"):
			var retry_textures = buttons["retry"]
			var retry_normal = load(retry_textures["normal"])
			var retry_hover = load(retry_textures["hover"])
			
			if retry_normal:
				retry_button.texture_normal = retry_normal
			if retry_hover:
				retry_button.texture_hover = retry_hover
		
		# Botón home (sin idioma)
		if buttons.has("home"):
			var home_textures = buttons["home"]
			var home_normal = load(home_textures["normal"])
			var home_hover = load(home_textures["hover"])
			
			if home_normal:
				home_button.texture_normal = home_normal
			if home_hover:
				home_button.texture_hover = home_hover
		
		# Botones de sonido
		if buttons.has("sonido_on"):
			var sonido_on_textures = buttons["sonido_on"]
			var sonido_on_normal = load(sonido_on_textures["normal"])
			var sonido_on_hover = load(sonido_on_textures["hover"])
			
			if sonido_on_normal:
				sonido_on.texture_normal = sonido_on_normal
			if sonido_on_hover:
				sonido_on.texture_hover = sonido_on_hover
		
		if buttons.has("sonido_off"):
			var sonido_off_textures = buttons["sonido_off"]
			var sonido_off_normal = load(sonido_off_textures["normal"])
			var sonido_off_hover = load(sonido_off_textures["hover"])
			
			if sonido_off_normal:
				sonido_off.texture_normal = sonido_off_normal
			if sonido_off_hover:
				sonido_off.texture_hover = sonido_off_hover

func _on_config_changed(_value):
	_apply_configuration()

# Señales de hover para debug
func _on_close_button_mouse_entered():
	print("🖱️ Hover en botón cerrar/reanudar")

func _on_close_button_mouse_exited():
	print("🖱️ Hover fuera de botón cerrar/reanudar")

func _on_retry_button_mouse_entered():
	print("🖱️ Hover en botón reintentar")

func _on_retry_button_mouse_exited():
	print("🖱️ Hover fuera de botón reintentar")

func _on_home_button_mouse_entered():
	print("🖱️ Hover en botón home")

func _on_home_button_mouse_exited():
	print("🖱️ Hover fuera de botón home")

func _on_sonido_on_mouse_entered():
	print("🖱️ Hover en botón sonido on")

func _on_sonido_on_mouse_exited():
	print("🖱️ Hover fuera de botón sonido on")

func _on_sonido_off_mouse_entered():
	print("🖱️ Hover en botón sonido off")

func _on_sonido_off_mouse_exited():
	print("🖱️ Hover fuera de botón sonido off")

# ===== FUNCIONALIDAD DE BOTONES =====
func _on_close_pressed():
	print("🎮 Cerrando menú de pausa")
	close_pause_menu()

func _on_retry_pressed():
	print("🔄 Reintentando nivel desde pausa")
	_reiniciar_nivel()

func _on_home_pressed():
	print("🏠 Volviendo al menú principal desde pausa")
	# Reanudar todo antes de cambiar de escena
	close_pause_menu()
	
	# Usar call_deferred para evitar problemas con el árbol de escena
	call_deferred("_change_to_main_menu")

func _change_to_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu_scene)

func _on_sonido_on_pressed():
	print("🔊 Sonido ON presionado desde pausa")
	ConfigManager.set_sound_volume(1.0)  # Volumen máximo

func _on_sonido_off_pressed():
	print("🔇 Sonido OFF presionado desde pausa")
	ConfigManager.set_sound_volume(0.0)  # Silencio

# ===== FUNCIÓN PARA REINICIAR NIVEL =====
func _reiniciar_nivel():
	print("🔄 PauseMenu: Reiniciando nivel...")
	
	# Cerrar menú de pausa primero
	close_pause_menu()
	
	# Usar call_deferred para evitar problemas con el árbol de escena
	call_deferred("_reiniciar_nivel_deferred")

func _reiniciar_nivel_deferred():
	# Obtener GameManager
	var game_manager = get_node_or_null("/root/GameManager")
	if not game_manager:
		print("❌ No se encontró GameManager para reiniciar nivel")
		return
	
	# Resetear monedas
	game_manager.reset_coins()
	print("✅ Monedas reseteadas")
	
	# Resetear tiempo (sin perder puntos)
	game_manager.reset_tiempo()
	print("✅ Tiempo reseteado")
	
	# Cerrar todas las metas
	game_manager.close_all_goals()
	print("✅ Metas cerradas")
	
	# Recargar la escena actual
	get_tree().reload_current_scene()
	
	# ESPERAR a que la escena se recargue completamente
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("🔄 Escena recargada - aplicando configuración")
	
	# Iniciar tiempo después de recargar
	game_manager.iniciar_tiempo()
	print("⏰ Tiempo iniciado después de reinicio")
	
	# Aplicar volumen global
	game_manager.apply_global_volume()
	
	print("✅ Nivel reiniciado exitosamente - Puntos conservados")

# ===== FUNCIONALIDAD DE SONIDO =====
func _on_sound_volume_changed(volume: float):
	print("🔊 PauseMenu: Volumen de sonido cambiado: ", volume)
	_actualizar_estado_sonido()

func _actualizar_estado_sonido():
	var volumen = ConfigManager.get_sound_volume()
	print("🔊 PauseMenu: Estado de sonido actualizado - Volumen: ", volumen)

# ===== FUNCIONES DE APERTURA/CIERRE =====
func open_pause_menu():
	print("⏸️ Abriendo menú de pausa")
	
	# VERIFICAR que estamos en el árbol de escena
	if not is_inside_tree():
		print("❌ PauseMenu no está en el árbol de escena - intentando recuperar...")
		# Intentar agregarse al árbol si es posible
		if get_parent() == null:
			get_tree().root.add_child(self)
			print("🔄 PauseMenu agregado al árbol raíz")
	
	# Verificar nuevamente
	if not is_inside_tree():
		print("❌❌ No se pudo agregar PauseMenu al árbol")
		return
	
	# Pausar el juego
	get_tree().paused = true
	
	# Detener el tiempo del GameManager
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_method("detener_tiempo"):
		game_manager.detener_tiempo()
	
	# Mostrar el menú
	show()
	
	# Hacer que este menú procese input incluso cuando el juego está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("✅ Menú de pausa abierto correctamente")

func close_pause_menu():
	print("▶️ Cerrando menú de pausa")
	
	# Ocultar el menú
	hide()
	
	# VERIFICAR que estamos en el árbol de escena antes de reanudar
	if not is_inside_tree():
		print("❌ PauseMenu no está en el árbol de escena")
		return
	
	# Reanudar el juego
	get_tree().paused = false
	
	# Reanudar el tiempo del GameManager (solo si estamos en un nivel válido)
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_method("iniciar_tiempo") and _is_valid_level():
		game_manager.iniciar_tiempo()

# Verificar si estamos en un nivel válido (01-05)
func _is_valid_level() -> bool:
	var game_manager = get_node_or_null("/root/GameManager")
	if not game_manager:
		return false
	
	var current_level = game_manager.current_area
	return current_level >= 1 and current_level <= 5

# Input para el menú de pausa (funciona incluso con el juego pausado)
func _input(event):
	if event.is_action_pressed("ui_cancel") and visible:  # ESC para cerrar
		close_pause_menu()
		get_viewport().set_input_as_handled()
