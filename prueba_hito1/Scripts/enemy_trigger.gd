extends Area2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"
@onready var player: Player = get_node("/root/MainEscene/Player")
@onready var combat_manager = get_node("/root/MainEscene/CombatManager")

var timer := Timer.new()
var enemigos_en_contacto: Array = []

@export var MAX_COMBAT_DISTANCE := 120.0

func _ready() -> void:
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.timeout.connect(_on_block_time_over)
	add_child(timer)

	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node2D) -> void:
	if body is Enemy and not enemigos_en_contacto.has(body):
		enemigos_en_contacto.append(body)
		if not timer.is_stopped():
			timer.stop()
		timer.start()

func _on_body_exited(body: Node2D) -> void:
	if body is Enemy:
		enemigos_en_contacto.erase(body)

func _on_block_time_over() -> void:
	# Filtrar enemigos que están vivos y cercanos al jugador
	var enemigos_validos := enemigos_en_contacto.filter(func(e):
		return not e.dead and player.global_position.distance_to(e.global_position) <= MAX_COMBAT_DISTANCE
	)

	if enemigos_validos.size() > 0:
		combat_manager.start_combat(enemigos_validos.duplicate())
