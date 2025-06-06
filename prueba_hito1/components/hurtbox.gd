class_name Hurtbox
extends Area2D

@export var health_component: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D) -> void:
	var hitbox = area as Hitbox
	if hitbox:
		# Si el owner es el jugador, no aplicamos daño directamente
		if owner is Player:
			# Solo emitir la señal, CombatManager se encarga del daño
			hitbox.damage_dealt.emit()
		
		# Si es enemigo, sí aplicamos daño directamente
		elif owner.has_method("recibir_damage"):
			owner.recibir_damage(hitbox.damage)
			hitbox.damage_dealt.emit()
