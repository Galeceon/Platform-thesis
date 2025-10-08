# LoadingScreen.gd
extends CanvasLayer

@onready var background = $Background
@onready var continue_label = $ContinueLabel  # Añade un Label como hijo

# Textos para continuar en diferentes idiomas
var continue_texts = {
	"es": "¡Pulsa cualquier tecla para continuar!",
	"en": "Press any key to continue!"
}

func set_level(level_number: int):
	var modo = ConfigManager.get_color_mode()
	var idioma = ConfigManager.get_language()
	
	# Construir el path con idioma y tema
	var texture_path = "res://Assets/Sprites/UI/Pantallas de carga/%02d_%s_%s.png" % [level_number, idioma, modo]
	var texture = load(texture_path)
	
	if texture:
		background.texture = texture
		print("LoadingScreen: Cargada pantalla del nivel %d - Idioma: %s, Tema: %s" % [level_number, idioma, modo])
		print("✅ Ruta: ", texture_path)
	else:
		# Fallback: intentar sin idioma (solo nivel y tema)
		var fallback_path = "res://Assets/Sprites/UI/Pantallas de carga/%02d_%s.png" % [level_number, modo]
		var fallback_texture = load(fallback_path)
		
		if fallback_texture:
			background.texture = fallback_texture
			print("LoadingScreen: Fallback 1 - Cargada pantalla del nivel %d - Tema: %s" % [level_number, modo])
			print("🔄 Ruta fallback: ", fallback_path)
		else:
			# Último fallback: solo nivel
			var ultimate_fallback_path = "res://Assets/Sprites/UI/Pantallas de carga/%02d.png" % level_number
			var ultimate_fallback_texture = load(ultimate_fallback_path)
			
			if ultimate_fallback_texture:
				background.texture = ultimate_fallback_texture
				print("LoadingScreen: Fallback 2 - Cargada pantalla del nivel %d" % level_number)
				print("🔄 Ruta fallback final: ", ultimate_fallback_path)
			else:
				print("❌ LoadingScreen: ERROR - No se encontró ninguna textura para el nivel ", level_number)
	
	# Configurar y mostrar el texto de continuar
	_configurar_texto_continuar(idioma)
	
	# Iniciar la secuencia de espera + input
	_iniciar_secuencia_continuar()

func _configurar_texto_continuar(idioma: String):
	# Configurar el texto según el idioma
	if continue_texts.has(idioma):
		continue_label.text = continue_texts[idioma]
	else:
		continue_label.text = continue_texts["es"]  # Fallback a español
	
	# Ocultar inicialmente
	continue_label.visible = false
	
	# Configurar estilo básico (puedes personalizar esto)
	continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	continue_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	
	# Posicionar en la parte inferior
	continue_label.position = Vector2(get_viewport().size.x / 2, get_viewport().size.y - 50)
	
	print("📝 Texto de continuar configurado: ", continue_label.text)

func _iniciar_secuencia_continuar():
	print("⏳ Esperando 3 segundos antes de permitir continuar...")
	
	# Esperar 3 segundos
	await get_tree().create_timer(3.0).timeout
	
	# Mostrar el texto de continuar
	continue_label.visible = true
	print("✅ Texto de continuar visible - Esperando input del jugador")
	
	# Esperar a que el jugador presione cualquier tecla
	await _esperar_input_jugador()
	
	# Ocultar el texto y continuar
	continue_label.visible = false
	print("🎮 Input detectado - Continuando...")

func _esperar_input_jugador():
	# Crear una señal personalizada para esperar input
	var input_signal = "input_received"
	
	# Conectar la señal de input
	get_viewport().connect("gui_input", Callable(self, "_on_gui_input"))
	
	# Esperar a que se emita la señal
	await self.input_received
	
	# Desconectar la señal
	get_viewport().disconnect("gui_input", Callable(self, "_on_gui_input"))

# Señal personalizada
signal input_received

func _on_gui_input(event):
	# Detectar cualquier input de teclado o mouse
	if event is InputEventKey or event is InputEventMouseButton:
		if event.pressed:
			print("🎮 Input detectado: ", event)
			input_received.emit()
