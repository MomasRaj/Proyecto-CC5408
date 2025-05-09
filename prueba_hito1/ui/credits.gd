extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var volver: Button = $Volver


func _ready() -> void:
	volver.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/Titulo.tscn"))
	

func _process(delta: float) -> void:
	v_box_container.position.y -= 20 * delta
