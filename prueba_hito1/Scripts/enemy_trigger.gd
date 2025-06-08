extends Area2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"
@onready var player: Player = get_node("/root/MainEscene/Player")
var timer:= Timer.new()
@onready var combat_manager =get_node("/root/MainEscene/CombatManager")

func _ready() -> void:
	timer.wait_time=1.0
	timer.one_shot=true
	timer.timeout.connect(_on_block_time_over)
	add_child(timer)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		timer.start()
		print("Enemigo detectado!")

func _on_block_time_over():
	combat_manager.start_combat()
