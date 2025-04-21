class_name  Hurtbox

extends Area2D
@onready var hurtbox: Hurtbox = $"."

signal entro

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D):
	var hitbox = area as Hitbox
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
		hitbox.damage_dealt.emit()
