extends CharacterBody2D
class_name Enemy
@onready var player: Player = get_node("/root/MainEscene/Player")
@onready var pivote: Node2D = $Pivote
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var attack_area: Area2D = $Pivote/Attack_area
@onready var combat_manager: Node = $"../CombatManager"
@onready var parry_notify_area: Area2D = $Pivote/ParryNotifyArea

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

func _ready():
	combat_manager.combat_ended.connect(_on_combat_ended)
	animation_tree.active = true
	parry_notify_area.body_entered.connect(_on_notify_parry)
	parry_notify_area.body_exited.connect(_on_notify_parry_end)
	
func _on_combat_ended(succes:bool):
	if succes:
		print("Puedes dañar al enemigo")
	else:
		print("El jugador falló")
	
func _physics_process(delta):
	var direction = sign(player.global_position.x - global_position.x)
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
	
	velocity.x = direction * WALK_SPEED
	
	move_and_slide()
	if abs(direction) > 0.1:
		pivote.scale.x = sign(direction)

func attack():
	var k=randi_range(1,3)
	var ataque="Enemy_attack"+str(k)
	current_attack_anim=ataque
	playback.travel(ataque)
	var duration= animation_tree.get_animation(ataque).length
	await get_tree().create_timer(duration).timeout 
	playback.travel("Enemy_walk")

func take_damage():
	playback.travel("Enemy_hurt")
	await get_tree().create_timer(1).timeout
	playback.travel("Enemy_Idle")
	return
	
func _on_notify_parry(body: Node):
	var player_ = body as Player
	if player_:
		combat_manager.enemy_list.append(self)

func _on_notify_parry_end(body:Node):
	var player_ = body as Player
	if player_:
		combat_manager.enemy_list.erase(self)
