extends CharacterBody2D
class_name Enemy
signal enemy_died

# Estados
enum State { IDLE, MOVING, ATTACKING, HURT, DEAD, KNOCKBACK }
var state = State.IDLE

@onready var player: Player = get_node("/root/MainEscene/Player")
@onready var pivote: Node2D = $Pivote
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var attack_area: Area2D = $Pivote/Attack_area
@onready var combat_manager: Node = $"../CombatManager"
@onready var parry_notify_area: Area2D = $Pivote/ParryNotifyArea
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var max_detection_range := 500.0
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_component: HealthComponent = $HealthComponent


# Variables de movimiento y combate
@export var WALK_SPEED = 20
var GRAVITY = 900.0
var knockback_strength = 100
var min_distance_to_player = 50
var dead: bool = false
var can_attack := true
var is_attacking := false
var can_get_hit := false
var knockback := false
var is_in_combat := false
var current_attack_anim = ""

func _ready():
	add_to_group("enemies")
	combat_manager.combat_ended.connect(_on_combat_ended)
	animation_tree.active = true
	parry_notify_area.body_entered.connect(_on_notify_parry)
	parry_notify_area.body_exited.connect(_on_notify_parry_end)
	health_component.health_changed.connect(_on_health_changed)
	health_bar.value = health_component.health
	health_bar.max_value = health_component.max_health
	health_component.died.connect(death)

func _physics_process(delta):
	if dead:
		return

	var to_player = player.global_position - global_position
	var distance = to_player.length()
	if distance <= max_detection_range and state == State.IDLE:
		state = State.MOVING

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	match state:
		State.IDLE:
			handle_idle()
		State.MOVING:
			handle_moving()
		State.ATTACKING:
			pass
		State.HURT, State.KNOCKBACK:
			handle_knockback()
		State.DEAD:
			pass

	move_and_slide()
	_update_animation()
	_update_direction()

func handle_idle():
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	if distance > max_detection_range:
		velocity.x = 0
		return
	if distance > min_distance_to_player:
		state = State.MOVING
		velocity.x = sign(to_player.x) * WALK_SPEED
	else:
		velocity.x = 0

func handle_moving():
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	if distance > max_detection_range:
		state = State.IDLE
		velocity.x = 0
		return

	if distance <= min_distance_to_player:
		state = State.IDLE
		velocity.x = 0
	else:
		velocity.x = sign(to_player.x) * WALK_SPEED

func handle_knockback():
	if knockback:
		move_and_slide()

func _update_animation():
	var new_animation = ""

	if dead:
		new_animation = "Enemy_muerte"
	elif state == State.ATTACKING:
		new_animation = current_attack_anim
	elif state in [State.HURT, State.KNOCKBACK]:
		new_animation = "Enemy_hurt"
	elif abs(velocity.x) > 0.1:
		new_animation = "Enemy_walk"
	else:
		new_animation = "Enemy_Idle"

	if current_attack_anim != new_animation:
		playback.travel(new_animation)
		current_attack_anim = new_animation

func _update_direction():
	var to_player = player.global_position - global_position
	if abs(to_player.x) > 0.1:
		pivote.scale.x = sign(to_player.x)

func attack():
	if dead or not can_attack or is_attacking:
		return
	is_attacking = true
	state = State.ATTACKING
	var k = randi_range(1, 3)
	var ataque = "Enemy_attack" + str(k)
	current_attack_anim = ataque
	playback.travel(ataque)
	var duration = animation_tree.get_animation(ataque).length
	await get_tree().create_timer(duration).timeout
	is_attacking = false
	state = State.IDLE

func take_damage():
	if can_get_hit and not dead:
		state = State.HURT
		playback.travel("Enemy_hurt")
		await get_tree().create_timer(1).timeout
		if not dead:
			state = State.IDLE

func recibir_damage(damage: float) -> void:
	if can_get_hit:
		can_get_hit = false
		knockback = true
		health_component.take_damage_v2(damage)
		var knockback_dir = (global_position - player.position).normalized()
		velocity = knockback_dir * knockback_strength
		if health_component.health <= 0:
			death()
		else:
			state = State.HURT
			playback.travel("Enemy_hurt")
			await animation_tree.animation_finished
			knockback = false
			state = State.IDLE
	else:
		state = State.IDLE
		print("CANT GET HIT")
		if $AnimationPlayer.has_animation("Enemy_parry"):
			playback.travel("Enemy_parry")
			audio_stream_player_2d.play()
			await animation_tree.animation_finished
		state = State.IDLE

func death() -> void:
	if dead:
		return
	dead = true
	state = State.DEAD
	enemy_died.emit()
	collision_shape_2d.call_deferred("set_disabled", true)
	parry_notify_area.call_deferred("set_monitoring", false)
	attack_area.call_deferred("set_monitoring", false)
	set_physics_process(false)
	set_collision_layer(0)
	set_collision_mask(0)
	health_bar.visible = false
	playback.travel("Enemy_muerte")
	await animation_tree.animation_finished
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1)
	await tween.finished
	queue_free()

func _on_combat_ended(success: bool,source_enemy):
	if source_enemy != self:
		return
	if success:
		print("Puedes dañar al enemigo")
	else:
		print("El jugador falló")

func _on_notify_parry(_body: Node):
	# Ya no agregamos a combat_manager.enemy_list aquí
	pass

func _on_notify_parry_end(_body: Node):
	# Ya no quitamos de combat_manager.enemy_list aquí
	pass

func _on_health_changed(value: float) -> void:
	health_bar.value = value
