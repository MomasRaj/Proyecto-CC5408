extends CharacterBody2D

@export var max_speed = 400
@export var acceleration = 1000
@export var gravity = 1000
@export var jump_speed = 600
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")
@onready var pivot: Node2D = $pivot
@onready var timer: Timer = $timer
@onready var jump_player: AudioStreamPlayer = $JumpPlayer
@onready var itbox: CollisionShape2D = $pivot/Hitbox/CollisionShape2D
@onready var salto: CollisionShape2D = $pivot/Salto/CollisionShape2D
@onready var hitbox: Hitbox = $pivot/Hitbox
@onready var alto: Hitbox = $pivot/Salto

static var xd = false
static var counter = 0
static var sonido = 1

func _ready() -> void:
	animation_tree.active = true
	itbox.disabled = true
	salto.disabled = true
	hitbox.damage_dealt.connect(_on_damage_dealt)
	alto.damage_dealt.connect(_on_alto_damage_dealt)
	
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_speed
		counter=0
	if not is_on_floor() and counter == 0 and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_speed
		counter=1
	if xd:
		velocity.y = -jump_speed
		jump_player.play()
		xd = false
	var move_input = Input.get_axis("move_left","move_right")
	velocity.x = move_toward(velocity.x , max_speed * move_input , acceleration * delta)
	move_and_slide()

#animacion
	if is_on_floor():
		salto.disabled = true
		counter = 0
		sonido = 1
		if move_input:
			playback.travel("run")
		else:
			playback.travel("idle")
	else:
		if velocity.y < 0:
			salto.disabled = false
			playback.travel("Jump")
			if sonido == 1:
				jump_player.play()
				sonido = 2
			if counter == 1 and Input.is_action_just_pressed("jump"):
				playback.travel("jump_Start")
				if sonido == 2:
					jump_player.play()
					sonido = 3
				counter = 2
		else:
			playback.travel("Fall")
	if move_input != 0 and not playback.get_current_node() == "Attack":
		pivot.scale.x = sign(move_input) * 3.358

	if Input.is_action_just_pressed("attack") and is_on_floor():
		playback.travel("Attack")
		itbox.disabled = false
		$timer.start()
	if Input.is_action_just_pressed("shotgun"):
		playback.travel("Shotgun")
func _on_timer_timeout():
	itbox.disabled = true

func _on_damage_dealt() -> void:
	pass
		
func _on_alto_damage_dealt() -> void:
	xd = true
	
func take_damage(damage: int) -> void:
	queue_free()
