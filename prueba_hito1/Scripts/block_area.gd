extends Area2D

signal parry_area_contact
signal parry_area_out

func _on_area_entered(area: Area2D) -> void:
	if area.name =="Attack_area":
		emit_signal("parry_area_contact")

func _on_area_exited(area: Area2D) -> void:
	if area.name =="Attack_area":
		emit_signal("parry_area_out")
