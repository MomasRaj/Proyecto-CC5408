extends CanvasLayer
@onready var label: Label = $Label

func show_message(text: String,win:bool):
	label.text =text
	label.show()
	if win:
		label.modulate=Color(0,1,0)
	else:
		label.modulate=Color(1,0,0)

	await get_tree().create_timer(2.0).timeout
	# Opcional: recargar escena o ir a menú
	get_tree().change_scene_to_file("res://ui/Titulo.tscn")
