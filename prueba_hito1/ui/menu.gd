extends MarginContainer

@onready var resume: Button = $PanelContainer/MarginContainer/VBoxContainer/Resume
@onready var retry: Button = $PanelContainer/MarginContainer/VBoxContainer/Retry
@onready var main_menu: Button = $"PanelContainer/MarginContainer/VBoxContainer/Main menu"
@onready var quit: Button = $PanelContainer/MarginContainer/VBoxContainer/Quit
@onready var sound: Button = $PanelContainer/MarginContainer/VBoxContainer/Sound
@onready var moves: Button = $PanelContainer/MarginContainer/VBoxContainer/Moves

func _ready() -> void:
	quit.pressed.connect(func(): get_tree().quit())
	retry.pressed.connect(_on_retry_pressed)
	main_menu.pressed.connect(_on_main_menu_pressed)
	resume.pressed.connect(_on_resume_pressed)
	sound.pressed.connect(_on_sound_pressed) 
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		get_tree().paused = not get_tree().paused
		visible = get_tree().paused

func _on_sound_pressed() -> void:
	var menu_volumen = get_parent().get_node("Control")
	menu_volumen.show()
	hide()
	
func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/Titulo.tscn")
