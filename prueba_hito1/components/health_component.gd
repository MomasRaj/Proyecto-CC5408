class_name HealthComponent
extends Node

signal died
signal health_changed(value)

@export var health: float = 100:
	set(value):
		if health == value:
			return
		health = clamp(value, 0, max_health)
		health_changed.emit(health)
		if health == 0:
			died.emit()
@export var max_health: float = 100

func take_damage_v2(damage: float) -> void:
	health -= damage
