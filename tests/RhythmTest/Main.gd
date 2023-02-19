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

var music := {
	"silence": preload( "res://130-BPM-silence.ogg" ),
	"intro": preload( "res://130-BPM-music_intro.ogg" ),
	"combat": preload( "res://130-BPM-music_combat.ogg" ),
	"boss": preload( "res://130-BPM-music_boss.ogg" ),
	"shop": preload( "res://130-BPM-music_shop.ogg" ),
	"secret_room": preload( "res://130-BPM-music_secret.ogg" ),
}

var queued_music = []

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

func _initialize_music() -> void:
	for song in music.values():
		song.loop_offset *= seconds_per_measure

func _play_music_helper(music_player1, music_player2, music_file) -> void:
	var time_until_end_of_current_loop := 0.0
	if music_player2.stream:
		music_player2.stream.set_loop(false)
		if music_player2.stream == music_file:
			if music_player2.playing: # Not exactly sure why this branch is necessary but you can't enqueue the same loop twice without it.
				queued_music.insert(0, music_file)
			return
		time_until_end_of_current_loop = music_player2.stream.get_length() - (music_player2.get_playback_position() + \
				AudioServer.get_time_since_last_mix())

	if time_until_end_of_current_loop < seconds_per_measure / 2:
		music_player1.stream = music_file
		music_player1.stream.set_loop(true)
		music_player1.play( beat_player_position_in_seconds - seconds_per_measure )
	else:
		queued_music.insert(0, music_file)

func _play_music(music_file) -> void:
	if not $MusicPlayer.playing:
		_play_music_helper($MusicPlayer, $MusicPlayer2, music_file)
	else:
		_play_music_helper($MusicPlayer2, $MusicPlayer, music_file)

func _ready() -> void:
	_initialize_music()
	$BeatPlayer.stream.loop_offset = seconds_per_measure
	$BeatPlayer.play( seconds_per_measure )

func _process(_delta) -> void:
	_get_beat_data( )

	if current_beat_count != previous_beat_count:
		_report_beat()

	if queued_music:
		_play_music(queued_music.pop_at(0))

#		print("C: %s M: %s B: %s T: %s" % [current_beat_count, current_measure, current_beat_in_audiofile, time_since_last_beat ])

func is_on_beat( timing_tolerance := 0.09 ) -> bool:
	return beat_product <= timing_tolerance

func play_music(music_file) -> void:
	queued_music.append(music_file)
	
func stop_music() -> void:
	if $MusicPlayer.stream:
		$MusicPlayer.stream.set_loop(false)
	if $MusicPlayer2.stream:
		$MusicPlayer2.stream.set_loop(false)


#BUG! Wont queue transition tracks properly while audio is playing i.e. 4 then 1 will not work and instead sound like 4 then 3
#		but 4 then 5 then 1 works for some reason... Need to figure out a good way to clear the unused music player's audio stream.
#		silence track?
#	  After a closer inspection of this bug, it appears that the transition track is getting queued properly but
#	    the main track is immediately overwriting and replacing it on the very next frame without giving it a chance to play
#		for some reason.

# USAGE
func _input(event: InputEvent) -> void:
	var key = event as InputEventKey
	# Music doesn't play immediately, it waits for the next measure to jump in.
	if key and key.is_pressed() and key.get_scancode() == KEY_1:
		play_music( music.intro )
		play_music( music.combat )
	if key and key.is_pressed() and key.get_scancode() == KEY_2:
		play_music( music.boss )
	if key and key.is_pressed() and key.get_scancode() == KEY_3:
		play_music( music.combat )
	if key and key.is_pressed() and key.get_scancode() == KEY_4:
		play_music( music.shop )
	if key and key.is_pressed() and key.get_scancode() == KEY_5:
		play_music( music.secret_room )

	if key and key.is_pressed() and key.get_scancode() == KEY_0:
		stop_music()

	var mouse_button = event as InputEventMouseButton
	if mouse_button and mouse_button.pressed and mouse_button.button_index == 1:
		if is_on_beat():
			$Blip/AnimationPlayer.play("Blink")
