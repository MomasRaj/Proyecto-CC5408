class_name GeneralInputHandler
extends Node

@export var _characterName : String
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@export var move_data : MoveData
@export var projectile_scene: PackedScene
@export var player: Player 

var _waitAmountOfFrames : int = 20
var _elapsedWaitTime : float


var _registeredKeyInputs : Array
var _moveSetDictionary : Dictionary

var _isAttacking : bool = false
var _isCrouching : bool = false
var _isJumping : bool = false

func _ready() -> void:
	if move_data:
		_moveSetDictionary = move_data.Moves
	animation_tree.active = true
	
func _process(delta):
	if(_isAttacking): return
	
	
	TranslateInput()
	
	if(_registeredKeyInputs.size() > 0):
		_elapsedWaitTime += delta
		if(_elapsedWaitTime >= delta * _waitAmountOfFrames):
			PerformComboMove()

func TranslateInput() -> void:
	var key : String = ""
	
	if(Input.is_action_just_pressed("entry_left")): key = "L"
	elif(Input.is_action_just_pressed("entry_right")): key = "R"
	elif(Input.is_action_just_pressed("entry_jump")): key = "U"
	elif(Input.is_action_just_pressed("entry_down")): key = "D"
	elif(Input.is_action_just_pressed("entry_attack")) : key = "A"
	elif(Input.is_action_just_pressed("entry_kick")) : key = "K"
	elif(Input.is_action_just_pressed("entry_punch")) : key = "P"
	
	if(key == ""): return
	
	PerformMove(key)
	_elapsedWaitTime = 0
	if key=="U":
		pass
	else:
		_registeredKeyInputs.append(key)

func PerformMove(key : String):
	if(!_moveSetDictionary.has(key)):
		return
	
func PerformComboMove():
	if move_data == null:
		print("Error: move_data no está asignado.")
		_registeredKeyInputs.clear()
		return
		
	for combo_keys in move_data.Specials.keys():
		if _match_combo(combo_keys):
			PlaySpecialMove(move_data.Specials[combo_keys])
			_registeredKeyInputs.clear()
			return
	
	_registeredKeyInputs.clear()

func _match_combo(combo_keys: Array) -> bool:
	if combo_keys.size() != _registeredKeyInputs.size():
		return false
	
	for i in range(combo_keys.size()):
		if combo_keys[i] != _registeredKeyInputs[i]:
			return false
		
	return true
	

func PlaySpecialMove(move_name: String) -> void:
	print("Executing Special Move: %s" % move_name)
	player.play_special_move(move_name)
		
	_isAttacking = true
	
	if move_name == "Proyectile":
		ShootProjectile()
		
	await get_tree().create_timer(0.5).timeout
	_isAttacking = false
	
	
func ShootProjectile() -> void:
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		var spawn_position = get_parent().global_position
		spawn_position.y -= 50
		projectile.position = spawn_position
		projectile.direction = Vector2.RIGHT 
		get_tree().current_scene.add_child(projectile)
