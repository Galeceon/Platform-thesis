# MainMenu.gd
extends BaseMenu  # ← Hereda de BaseMenu en lugar de CanvasLayer

func _ready():
	super._ready()  # Llama al _ready del BaseMenu
	# Tu código específico del MainMenu aquí

func _on_start_button_pressed():
	print("Start game!")
	# Tu lógica aquí
