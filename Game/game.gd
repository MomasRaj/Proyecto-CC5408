extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer


@export var music: AudioStream

func _ready() -> void:
	music_player.stream = music
	music_player.play()
