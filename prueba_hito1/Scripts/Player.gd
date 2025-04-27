class_name  Player
extends CharacterBody2D
# Variables de movimiento
var WALK_SPEED = 200.0
var RUN_SPEED = 350.0
var JUMP_VELOCITY = -300.0
var GRAVITY = 900.0
var MAX_SPEED = 200.0
var ATTACK_SPEED=30

# Variables de combate
var is_in_combat:bool =false
var is_blocking: bool = false

# Cooldowns
var ATTACK_COOLDOWN = 0.6
var PARRY_COOLDOWN = 0.5

# Referencias a nodos
@onready var player: Player = $"."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var pivote: Node2D = $Pivote
@onready var combat_manager: Node = $"../CombatManager"
@onready var block_area: Area2D = $Pivote/Sprite2D/BlockArea


signal parry_zone_contact

func _ready():
	block_area.area_entered.connect(_on_block_area_area_entered)
	combat_manager.combat_started.connect(_on_combat_started)
	combat_manager.combat_ended.connect(_on_combat_ended)
	animation_tree.active = true

func _input(_event):
	if is_in_combat:
		if Input.is_action_pressed("entry_parry_initiate"):
			if not is_blocking:
				is_blocking=true
				combat_manager.set_player_blocking(is_blocking)
		elif is_blocking:
			is_blocking=false
			combat_manager.set_player_blocking(is_blocking)
		
		if is_blocking:
			for i in range(1,5):
				if Input.is_action_just_pressed("parry_random%d"%i):
					combat_manager.register_input(i)

func _on_combat_started():
	is_in_combat=true
	is_blocking=false

func _on_combat_ended(success: bool):
	is_in_combat = false
	is_blocking = false
	if success:
		print("¡Secuencia bloqueada con éxito! El enemigo ahora puede recibir daño.")
	else:
		print("Fallaste la secuencia. El enemigo te golpea.")

func _physics_process(delta):
	var direction = Input.get_axis("entry_left","entry_right")
	
	if Input.is_action_pressed("entry_run"):
		MAX_SPEED = RUN_SPEED
	else:
		MAX_SPEED = WALK_SPEED
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	# Salto
	if is_on_floor() and not is_blocking and not is_in_combat:
		if Input.is_action_just_pressed("entry_jump"):
			velocity.y=JUMP_VELOCITY

	if Input.is_action_just_pressed("entry_attack") and not is_blocking and not is_in_combat and is_on_floor():
		playback.travel("Attack1")
		return
	if Input.is_action_pressed("entry_parry_initiate") and (Input.is_action_just_pressed("parry_random1") or Input.is_action_just_pressed("parry_random2") or Input.is_action_just_pressed("parry_random3") or Input.is_action_just_pressed("parry_random4") or Input.is_action_just_pressed("entry_parry_initiate")):
		playback.travel("Parry")
		return
	velocity.x = direction*MAX_SPEED
	move_and_slide()

	if is_on_floor():
		if direction!=0:
			pivote.scale.x=sign(direction)
		if abs(velocity.x)==RUN_SPEED:
			playback.travel("Run")
		elif abs(velocity.x)==WALK_SPEED:
			playback.travel("Walk")
		elif abs(velocity.x)==0:
			playback.travel("Idle")
	else:
		if velocity.y<0:
			playback.travel("Jump")

func take_damage():
	playback.travel("Hurt")
	return

func hide_label():
	if player.has_node("PromptUI"):
		if player.get_node("PromptUI").has_node("PromptLabel"):
			player.get_node("PromptUI").get_node("PromptLabel").hide()


func _on_block_area_area_entered(area: Area2D) -> void:
	if area.name == "Attack_area":
		print("Área de ataque detectada")
		emit_signal("parry_zone_contact")
