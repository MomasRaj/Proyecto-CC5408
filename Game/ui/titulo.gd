extends MarginContainer


@onready var start: Button = $PanelContainer/MarginContainer/VBoxContainer/Start
@onready var credits: Button = $PanelContainer/MarginContainer/VBoxContainer/Credits
@onready var quit: Button = $PanelContainer/MarginContainer/VBoxContainer/Quit



func _ready() -> void:
	start.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/caballero.tscn"))
	quit.pressed.connect(func(): get_tree().quit())
	credits.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/credits.tscn"))
