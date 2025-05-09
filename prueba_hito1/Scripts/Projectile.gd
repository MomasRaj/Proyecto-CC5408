extends Area2D

@export var speed: float = 300.0
@export var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_area_entered(area):
	queue_free()
