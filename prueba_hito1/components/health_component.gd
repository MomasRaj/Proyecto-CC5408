class_name HealthComponent
extends Node

signal died
signal health_changed(value)
signal player_died

@export var max_health: float = 100

var _health: float = max_health

@export var health: float:
	get: return _health
	set(value):
		if _health == value:
			return
		_health = clamp(value, 0, max_health)
		health_changed.emit(_health)
		if _health == 0:
			died.emit()

func take_damage_v2(damage: float) -> void:
	health -= damage
	if health <= 0.0:
		player_died.emit()
