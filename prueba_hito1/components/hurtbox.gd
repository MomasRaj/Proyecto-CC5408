# Hurtbox.gd
class_name Hurtbox
extends Area2D

signal damage_attempted(from_position: Vector2, damage: float, enemy: Enemy)

@export var health_component: HealthComponent
@onready var combat_manager: Node = null

func _ready() -> void:
	area_entered.connect(_on_area_entered)

	if owner is Player:
		combat_manager = get_node("/root/MainEscene/CombatManager")

func _on_area_entered(area: Area2D) -> void:
	var hitbox := area as Hitbox
	if hitbox == null:
		return

	if owner is Player or owner is Area2D:
		# Esperar antes de emitir el intento de daño para permitir parry
		await get_tree().create_timer(0.3).timeout
		if combat_manager and combat_manager.in_combat:
			var enemy := hitbox.owner as Enemy
			if enemy == null:
				return  # Si el owner no es Enemy, no seguimos
			if enemy.can_get_hit:
				enemy.recibir_damage(hitbox.damage)
			else:
				damage_attempted.emit(hitbox.global_position, hitbox.damage, enemy)
		hitbox.damage_dealt.emit()

	elif owner.has_method("recibir_damage"):
		owner.recibir_damage(hitbox.damage)
		hitbox.damage_dealt.emit()
