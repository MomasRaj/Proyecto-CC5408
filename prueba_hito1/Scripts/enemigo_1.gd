extends CharacterBody2D
class_name Enemy
@onready var player: Player = get_node("/root/MainEscene/Player")
@onready var pivote: Node2D = $Pivote
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var attack_area: Area2D = $Pivote/Attack_area
@onready var combat_manager: Node = $"../CombatManager"
@onready var parry_notify_area: Area2D = $Pivote/ParryNotifyArea
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


# Variables de movimiento
var WALK_SPEED = 0
var RUN_SPEED = 200.0
var JUMP_VELOCITY = -300.0
var GRAVITY = 900.0
var MAX_SPEED = 200.0
var ATTACK_SPEED=30
var can_attack := true
var is_attacking:= false
var is_in_combat:=false
var current_attack_anim: String= ""
var can_get_hit := false
var dead: bool = false
var knockback_strength = 100
var knockback: bool = false
# referencias a la salud
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_component: HealthComponent = $HealthComponent

@onready var Hitbox_damage: Hitbox = $Pivote/Attack_area

func _ready():
	combat_manager.combat_ended.connect(_on_combat_ended)
	animation_tree.active = true
	parry_notify_area.body_entered.connect(_on_notify_parry)
	parry_notify_area.body_exited.connect(_on_notify_parry_end)
	
	health_component.health_changed.connect(_on_health_changed)
	health_bar.value = health_component.health
	health_bar.max_value = health_component.max_health
	health_component.died.connect(death)
	
func _on_combat_ended(succes:bool):
	if succes:
		print("Puedes dañar al enemigo")
	else:
		print("El jugador falló")
	
func _physics_process(delta):
	if dead:
		return
	var direction = sign(player.global_position.x - global_position.x)
	
	
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
	
	if !knockback:
		velocity.x = direction * WALK_SPEED
	
	move_and_slide()
	if abs(direction) > 0.1:
		pivote.scale.x = sign(direction)

func attack():
	if dead or not can_attack:
		return
	var k=randi_range(1,3)
	var ataque="Enemy_attack"+str(k)
	current_attack_anim=ataque
	playback.travel(ataque)
	var duration= animation_tree.get_animation(ataque).length
	await get_tree().create_timer(duration).timeout 
	playback.travel("Enemy_walk")

func take_damage():
	if can_get_hit:
		if dead:
			return
		playback.travel("Enemy_hurt")
		await get_tree().create_timer(1).timeout
		if dead:
			return
		
		playback.travel("Enemy_Idle")
		
		return
	else:
		pass
func _on_notify_parry(body: Node):
	#if dead:
		#return
	var player_ = body as Player
	if player_:
		combat_manager.enemy_list.append(self)

func _on_notify_parry_end(body:Node):
	var player_ = body as Player
	if player_:
		combat_manager.enemy_list.erase(self)

func recibir_damage(damage: float) -> void:
	if can_get_hit:
		knockback = true
		health_component.take_damage_v2(damage)
		var knockback_dir = (global_position -player.position).normalized()
		velocity = knockback_dir * knockback_strength
		if health_component.health <= 0:
			death()
		else:
			playback.travel("Enemy_hurt")  # Opcional, animación de golpe
			await animation_tree.animation_finished
			knockback = false
	else:
		playback.travel("Enemy_parry")
		audio_stream_player_2d.play()
	

func death() -> void:
	
	if dead:
		return # Ya está muerto, no hacer nada
	
	dead = true
	
	# Desactivar lógica de combate y dañod
	collision_shape_2d.disabled = true
	parry_notify_area.monitoring = false
	attack_area.monitoring = false
	set_physics_process(false)
	
	set_collision_layer(0)
	set_collision_mask(0)
	
	# Ocultar barra de vida de inmediato
	health_bar.visible = false
	
	playback.travel("Enemy_muerte")
	await animation_tree.animation_finished
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1)
	await tween.finished

	queue_free()

	
func _on_health_changed(value: float) -> void:
	health_bar.value = value
