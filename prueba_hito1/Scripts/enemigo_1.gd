extends CharacterBody2D
class_name Enemy
@export var speed := 10.0
@onready var player: Player = get_node("/root/MainEscene/Player")
@onready var pivote: Node2D = $Pivote
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var attack_area: Area2D = $Pivote/Attack_area
@onready var combat_manager: Node = $"../CombatManager"

# Variables de movimiento
var WALK_SPEED = 10.0
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
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	animation_tree.active = true
	
func _on_combat_ended(succes:bool):
	if succes:
		print("Puedes dañar al enemigo")
	else:
		print("El jugador falló")
	
func _physics_process(_delta):
	if is_in_combat:
		velocity=Vector2.ZERO
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed	

	if abs(direction.x) > 0.1:
		pivote.scale.x = sign(direction.x)

func _on_attack_area_body_entered(body):
	if body is Player and can_attack:
		can_attack=false
		is_attacking=true
		playback.travel("Enemie_attack1")
		await animation_tree.animation_finished
		
		# Buscar y dañar al componente de salud del jugador
		if body.has_node("SaludComponente"):
			var salud_componente = body.get_node("SaludComponente")
			salud_componente.recibir_damage(10.0) # Puedes ajustar la cantidad de daño
		
		is_attacking=false
		can_attack=true

func attack():
	var k=randi_range(1,3)
	var ataque="Enemie_attack"+str(k)
	current_attack_anim=ataque
	playback.travel(ataque)
	var duration= animation_tree.get_animation(ataque).length
	await get_tree().create_timer(duration).timeout # o lo que dure la animación
	playback.travel("Enemie_walk")

func take_damage():
	playback.travel("Enemie_hurt")
	await get_tree().create_timer(0.5).timeout # o lo que dure la animación
	playback.travel("Enemie_walk")
	return
