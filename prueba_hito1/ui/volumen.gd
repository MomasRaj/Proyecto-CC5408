extends Control

@onready var control: Control = $"."
@onready var volver: Button = $PanelContainer/MarginContainer/VBoxContainer/Volver
@onready var moves: Label = $PanelContainer/MarginContainer/VBoxContainer/Moves



func _ready() -> void:
	volver.pressed.connect(_on_volver_pressed)
	
	

func _process(delta: float) -> void:
	pass

func _on_volver_pressed() -> void:
	hide()
	var menu_principal = get_parent().get_node("Main menu")
	menu_principal.show()
