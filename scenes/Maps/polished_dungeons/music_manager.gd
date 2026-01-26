extends AudioStreamPlayer3D

@export var boss_level: bool = false

const BOSS_MUSIC := preload("res://assets/audio/music/dark-fight-music-boss-2-252590.mp3")
const NORMAL_MUSIC := [
	preload("res://assets/audio/music/dark-fantasy-ambient-dungeon-synth-248213.mp3"),
	preload("res://assets/audio/music/dark-fantasy-ambient-dungeon-synth-music-281592.mp3"),
	preload("res://assets/audio/music/mystical-music-54294.mp3")
]

var selected_track: AudioStream

func _ready() -> void:
	volume_db = -15
	_select_music()
	finished.connect(_on_music_finished)
	play()

func _select_music() -> void:
	if boss_level:
		selected_track = BOSS_MUSIC
	else:
		selected_track = NORMAL_MUSIC.pick_random()

	stream = selected_track

func _on_music_finished() -> void:
	play()
