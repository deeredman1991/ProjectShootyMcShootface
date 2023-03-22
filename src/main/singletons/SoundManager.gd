extends Node


export var beats_per_minute := 130
onready var seconds_per_beat := 60.0 / beats_per_minute
export var beats_per_measure := 4
onready var seconds_per_measure = seconds_per_beat * beats_per_measure

var beat_player = null
var conductor = null

var music := {
	"beat": preload( "res://assets/audio/music/beat/main_beat.ogg" ),
	"boss": {
		"intro": preload( "res://assets/audio/music/boss/intro.ogg" ),
		"loops": [
			preload( "res://assets/audio/music/boss/loop_segment0.ogg" ),
			preload( "res://assets/audio/music/boss/loop_segment1.ogg" )
		]
	},
	"combat": {
		"intro": preload( "res://assets/audio/music/combat/intro2.ogg" ),
		"loops": [
			preload( "res://assets/audio/music/combat/loop_segment0.ogg" ),
			preload( "res://assets/audio/music/combat/loop_segment1.ogg" ),
			preload( "res://assets/audio/music/combat/loop_segment2.ogg" ),
			preload( "res://assets/audio/music/combat/loop_segment3.ogg" )
		]
	},
	"secret_room": {
		"intro": preload( "res://assets/audio/music/secret_room/intro.ogg" ),
		"loops": [
			preload( "res://assets/audio/music/secret_room/loop_segment0.ogg" ),
			preload( "res://assets/audio/music/secret_room/loop_segment1.ogg" ),
			preload( "res://assets/audio/music/secret_room/loop_segment2.ogg" )
		]
	},
	"shop": {
		"intro": preload( "res://assets/audio/music/shop/intro.ogg" ),
		"loops": [
			preload( "res://assets/audio/music/shop/loop_segment0.ogg" ),
			preload( "res://assets/audio/music/shop/loop_segment1.ogg" ),
			preload( "res://assets/audio/music/shop/loop_segment2.ogg" ),
			preload( "res://assets/audio/music/shop/loop_segment3.ogg" )
		]
	},
	"treasure_room": {
		"intro": preload( "res://assets/audio/music/shop/intro.ogg" ),
		"loops": [
			preload( "res://assets/audio/music/treasure_room/loop_segment0.ogg" ),
			preload( "res://assets/audio/music/treasure_room/loop_segment1.ogg" )
		]
	},
}

func start_beat():
	beat_player.play( SoundManager.seconds_per_measure )

func _initialize_music() -> void:
	for song_key in music:
		if song_key == "beat":
			beat_player.set_stream( SoundManager.music.beat )
			beat_player.stream.loop_offset = SoundManager.seconds_per_measure
			continue

		var song = music[song_key]
		if "intro" in song:
			song.intro.loop_offset = ( song.intro.loop_offset + 1 ) * seconds_per_measure
			song.intro.set_loop(false)
		for loop in song.loops:
			loop.loop_offset = (loop.loop_offset + 1) * seconds_per_measure
			loop.set_loop(false)
			
func _ready() -> void:
	_initialize_music()
