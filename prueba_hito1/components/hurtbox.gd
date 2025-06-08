class_name Hurtbox
extends Area2D
signal  damage_attempted(from_position: Vector2, damage: float)
@export var health_component: HealthComponent
@onready var combat_manager = get_node("/root/MainEscene/CombatManager")
func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var hitbox = area as Hitbox
	if hitbox:
		# Si el owner es el jugador, no aplicamos daño directamente
		if owner is Player:
			await get_tree().create_timer(0.3).timeout
			# Solo emitir la señal, CombatManager se encarga del daño
			damage_attempted.emit(hitbox.global_position, hitbox.damage)
			hitbox.damage_dealt.emit()
		# Si es enemigo, sí aplicamos daño directamente
		elif owner.has_method("recibir_damage"):
			owner.recibir_damage(hitbox.damage)
			owner.can_get_hit=false
			hitbox.damage_dealt.emit()
