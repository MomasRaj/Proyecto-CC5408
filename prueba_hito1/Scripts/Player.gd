class_name Player
extends CharacterBody2D

# Estados
enum State { IDLE, MOVING, ATTACKING, BLOCKING, HURT, DEAD, AIR }
var state = State.IDLE

# Variables de movimiento
var WALK_SPEED = 100.0
var RUN_SPEED = 300.0
var JUMP_VELOCITY = -400.0
var GRAVITY = 900.0
var MAX_SPEED = 200.0
var ATTACK_SPEED = 30

# Variables de combate
var is_in_combat:bool =false
var is_blocking: bool = false
var parry_area_contact: bool = false
var is_hurt: bool= false
var knockback_strength := 300
var can_attack : bool = true
var dead: bool = false

# Cooldowns
var ATTACK_COOLDOWN = 0.7
var PARRY_COOLDOWN = 0.5
var hurt_duration := 0.6
# Doble salto
var salto = 0
# Airdash
var AIRDASH_SPEED = 550
var air_dash = 1
var is_air_dashing: bool = false
# Direccion dash
var last_direction = 0
# Velocidad aire
var AIR_VELOCITY = 0
# Resitencia aire
var AIR_RESISTANCE = 200

@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer


# Referencias a nodos
@onready var player: Player = $"."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var pivote: Node2D = $Pivote
@onready var combat_manager: Node = $"../CombatManager"
@onready var block_area: Area2D = $Pivote/Sprite2D/BlockArea

# referencias a la salud
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D

func _ready():
	combat_manager.combat_started.connect(_on_combat_started)
	combat_manager.combat_ended.connect(_on_combat_ended)
	animation_tree.active = true
	health_component.health_changed.connect(_on_health_changed)
	health_bar.value = health_component.health
	health_bar.max_value = health_component.max_health
	health_component.died.connect(death)
	animation_tree.animation_finished.connect(_on_AnimationTree_animation_finished)

func _on_combat_started():
	is_in_combat=true
	is_blocking=false

func _on_combat_ended(_success: bool,_enemy):
	is_in_combat = false
	is_blocking = false

func _physics_process(delta):
	match state:
		State.IDLE, State.MOVING:
			handle_movement(delta)
		State.ATTACKING:
			pass
		State.HURT:
			move_and_slide()
		State.DEAD:
			pass
		State.AIR:
			handle_air_movement(delta)
		State.BLOCKING:
			pass

func handle_movement(delta):
	var direction = Input.get_axis("entry_left", "entry_right")
	
	if direction != 0:
		last_direction = direction
		pivote.scale.x = sign(direction)

	MAX_SPEED = RUN_SPEED if Input.is_action_pressed("entry_run") else WALK_SPEED
	velocity.x = direction * MAX_SPEED

	if Input.is_action_just_pressed("entry_jump"):
		velocity.y = JUMP_VELOCITY
		salto += 1
		state = State.AIR
		playback.travel("Jump")
		return

	if Input.is_action_just_pressed("entry_attack") and is_on_floor() and can_attack:
		can_attack = false
		state = State.ATTACKING
		velocity.x = 0
		playback.travel("Attack1")
		attack_cooldown_timer.start(ATTACK_COOLDOWN)
		return
	
	if is_in_combat and (Input.is_action_just_pressed("parry_random1") or Input.is_action_just_pressed("parry_random2") or Input.is_action_just_pressed("parry_random3") or Input.is_action_just_pressed("parry_random4")):
		state = State.BLOCKING
		#velocity.x=0
		playback.travel("Parry")
		return
	
	if direction == 0:
		playback.travel("Idle")
		state = State.IDLE
	else:
		playback.travel("Run" if MAX_SPEED == RUN_SPEED else "Walk")
		state = State.MOVING

	if not is_on_floor():
		velocity.y += GRAVITY * delta
		state = State.AIR

	move_and_slide()

func handle_air_movement(delta):
	var direction = Input.get_axis("entry_left", "entry_right")
	if direction != 0:
		last_direction = direction
		pivote.scale.x = sign(direction)

	# Dash en el aire
	if Input.is_action_just_pressed("entry_run") and air_dash < 2:
		AIR_VELOCITY = last_direction * AIRDASH_SPEED
		is_air_dashing = true
		air_dash += 1

	# Si está haciendo air dash, conservar velocidad y aplicar resistencia
	if is_air_dashing:
		AIR_VELOCITY -= AIR_RESISTANCE * delta * sign(AIR_VELOCITY)
		if abs(AIR_VELOCITY) < 10:
			AIR_VELOCITY = 0
			is_air_dashing = false
		velocity.x = AIR_VELOCITY
	else:
		# Movimiento horizontal normal en el aire
		MAX_SPEED = RUN_SPEED if Input.is_action_pressed("entry_run") else WALK_SPEED
		velocity.x = direction * MAX_SPEED

	# Doble salto
	if salto < 3 and Input.is_action_just_pressed("entry_jump"):
		velocity.y = JUMP_VELOCITY
		salto += 1

	# Gravedad
	velocity.y += GRAVITY * delta

	# Animación
	if velocity.y < 0:
		playback.travel("Jump")
	else:
		playback.travel("Fall")

	move_and_slide()

	# Reinicio de estado al tocar el piso
	if is_on_floor():
		state = State.IDLE
		salto = 1
		air_dash = 1
		is_air_dashing = false


func _on_AnimationTree_animation_finished(anim_name):
	if anim_name == "Attack1" and state == State.ATTACKING:
		state = State.IDLE
	elif anim_name == "Parry" and state == State.BLOCKING:
		state= State.IDLE
		is_blocking = false

func take_damage(from_position: Vector2):
	if is_hurt or is_blocking:
		return
	is_hurt = true
	state = State.HURT
	playback.travel("Hurt")
	var knockback_dir = (global_position - from_position).normalized()
	velocity = knockback_dir * knockback_strength
	await get_tree().create_timer(hurt_duration).timeout
	velocity = Vector2.ZERO
	is_hurt = false
	state = State.IDLE

func hide_label():
	if player.has_node("PromptUI"):
		if player.get_node("PromptUI").has_node("PromptLabel"):
			player.get_node("PromptUI").get_node("PromptLabel").hide()

func recibir_damage(_damage: float) -> void:
	if is_blocking or is_hurt or dead:
		return
	if health_component.health <= 0:
		death()

func death() -> void:
	if dead:
		return
	dead = true
	state = State.DEAD
	collision_shape_2d.disabled = true
	set_physics_process(false)
	set_collision_layer(0)
	set_collision_mask(0)
	playback.travel("Muerte")
	await animation_tree.animation_finished
	animation_tree.active = false
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1)
	await get_tree().create_timer(1).timeout
	queue_free()
	get_tree().reload_current_scene()

func _on_health_changed(value: float) -> void:
	health_bar.value = value

func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true
