extends Node2D
@onready var box: Hitbox = $Hitbox
@onready var collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hurtbox: CollisionShape2D = $Hurtbox/CollisionShape2D

func take_damage(damage: int) -> void:
	queue_free()
	
func _area_entrered (area: Area2D):
	var hitbox = area as Hitbox
	collision_shape_2d.disabled = false

func _ready() -> void:
	hurtbox.disabled = true

func _physics_process(delta: float) -> void:
	pass
