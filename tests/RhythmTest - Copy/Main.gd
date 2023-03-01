extends Node2D


export var beats_per_minute := 130
onready var seconds_per_beat := 60.0 / beats_per_minute
export var beats_per_measure := 4
onready var seconds_per_measure = seconds_per_beat * beats_per_measure

signal beat( beat_data )
signal measure_change( beat_data )

var previous_beat_player_position_in_seconds := -1.0
var beat_player_position_in_seconds := 0.0

var current_beat_in_audiofile := 0

var previous_beat := -1
var current_beat := 0

var previous_measure := -1
var current_measure := 0

var previous_beat_count := beats_per_measure
var current_beat_count := 0

var time_since_last_beat := 0.0
var time_until_next_beat := seconds_per_beat

# beat_product is used to measure how "on beat" the current frame is.
var beat_product := 0.0

var loops := {
	"silence": preload( "res://130-BPM-silence.ogg" ),
	"intro": preload( "res://130-BPM-music_intro.ogg" ),
	"combat": preload( "res://130-BPM-music_combat.ogg" ),
	"boss": preload( "res://130-BPM-music_boss.ogg" ),
	"shop": preload( "res://130-BPM-music_shop.ogg" ),
	"secret_room": preload( "res://130-BPM-music_secret.ogg" ),
}

var songs := {
	"test": {
		"intro": loops.intro,
		"loops": [ loops.combat, loops.boss ] },
	"test2": {
		"loops": [ loops.secret_room, ] }
}

var current_music_player = null
var current_song_object = null
var queued_loops = []

func _get_beat_data() -> void:
	var beat_player_playback_position = $BeatPlayer.get_playback_position()
	previous_beat_player_position_in_seconds = beat_player_position_in_seconds
	beat_player_position_in_seconds = beat_player_playback_position + \
		AudioServer.get_time_since_last_mix()
	
	#This step is needed so we don't flub the beat in the play step
	var beat_play_position_in_seconds_with_output_latency = beat_player_position_in_seconds - AudioServer.get_output_latency()
	
	current_beat_in_audiofile = int(floor(beat_play_position_in_seconds_with_output_latency / seconds_per_beat)) + 1

	time_since_last_beat = fmod(beat_play_position_in_seconds_with_output_latency, seconds_per_beat) #fmod = modulus for floats
	time_until_next_beat = seconds_per_beat - time_since_last_beat

	# beat_product is used to measure how "on beat" the current frame is.
	beat_product = min( time_since_last_beat, time_until_next_beat )

	# current_measure and previous_measure attributes are sensitive to lag not 
	#	accurate without this line, however I don't believe this line is necessary 
	#	unless we actually care about tracking measures
	if previous_beat_player_position_in_seconds > beat_play_position_in_seconds_with_output_latency:
		return

	previous_beat_count = current_beat_count
	# Equivalent to: `( current_beat_count % beats_per_measure ) or beats_per_measure` in Python
	current_beat_count = wrapi(current_beat_in_audiofile, 1, beats_per_measure + 1)

func _report_beat() -> void:
	previous_beat = current_beat
	current_beat += 1

	var beat_data = { 
		"previous_beat_count": previous_beat_count,
		"current_beat_count": current_beat_count, 
		"previous_beat": previous_beat,
		"current_beat": current_beat,
		"time_since_last_beat": time_since_last_beat,
		"time_until_next_beat": time_until_next_beat,
		"beat_product": beat_product
	}
	emit_signal("beat", beat_data)

	if current_beat_count == 1:
		previous_measure = current_measure
		current_measure += 1

		beat_data["previous_measure"] = previous_measure
		beat_data["current_measure"] = current_measure
		emit_signal("measure_change", beat_data)

func _initialize_loops() -> void:
	for loop in loops.values():
		loop.loop_offset *= seconds_per_measure

func _play_music( loop_stack ) -> void:
	var time_until_end_of_current_loop := 0

	if current_music_player:
		time_until_end_of_current_loop = current_music_player.stream.get_length() - (current_music_player.get_playback_position() + \
				AudioServer.get_time_since_last_mix())

	if time_until_end_of_current_loop < seconds_per_measure / 2:
		var new_stream_player = AudioStreamPlayer.new()
		new_stream_player.set_stream( loop_stack[0] )
		queued_loops.append( 
			[ 
				current_song_object.loops[ loop_stack[1] ], # Next Song
				(loop_stack[1] + 1) % current_song_object.loops.size() # Next Next Song Index 
			] 
		)
		add_child( new_stream_player )
		current_music_player = new_stream_player
		new_stream_player.play( beat_player_position_in_seconds - seconds_per_measure )
		new_stream_player.connect("finished", new_stream_player, "queue_free")
	else:
		queued_loops.append( loop_stack )

func _ready() -> void:
	_initialize_loops()
	$BeatPlayer.stream.loop_offset = seconds_per_measure
	$BeatPlayer.play( seconds_per_measure )

func _process(_delta) -> void:
	_get_beat_data( )

	if current_beat_count != previous_beat_count:
		_report_beat()

	if queued_loops:
		_play_music( queued_loops.pop_at(0) )

func is_on_beat( timing_tolerance := 0.09 ) -> bool:
	return beat_product <= timing_tolerance

func play_music(song_object) -> void:
	current_song_object = song_object
	queued_loops = []

	if "intro" in current_song_object:
		queued_loops.append( [ song_object.intro, 0 ] )
	else:
		queued_loops.append( [ song_object.loops[0], 0 ] )

func stop_music() -> void:
	current_song_object = null
	queued_loops = []

# USAGE
func _input(event: InputEvent) -> void:
	var key = event as InputEventKey
	# Music doesn't play immediately, it waits for the next measure to jump in.
	if key and key.is_pressed(): 
		if key.get_scancode() == KEY_1:
			play_music( songs.test )
		if key.get_scancode() == KEY_2:
			play_music( songs.test2 )

		if key.get_scancode() == KEY_0:
			stop_music()

	var mouse_button = event as InputEventMouseButton
	if mouse_button and mouse_button.pressed and mouse_button.button_index == 1:
		if is_on_beat():
			$Blip/AnimationPlayer.play("Blink")
