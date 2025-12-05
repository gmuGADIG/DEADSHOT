extends Node
class_name MusicPlayer

## Emitted when a new song starts playing (after any transition completes).
signal song_changed(new_song: Song)
## Emitted when a crossfade transition finishes.
signal transition_finished
## Emitted when a fade_out completes (before stop is called).
signal fade_out_finished

@export var bus_name: String = "Music"
@export var song_transition_curve: Curve

const FULL_DB: float = 0.0
const MUTE_DB: float = -64.0
const VOLUME_TRANSITION_TIME: float = 0.2
const DEFAULT_TRANSITION_TIME: float = 1.0
const DEFAULT_FADE_OUT_DURATION: float = 2.0

@onready var players: Array[AudioStreamPlayer] = [$AudioStreamPlayerA, $AudioStreamPlayerB]
var active_idx: int = 0

var _current_song: Song

var current_song: Song:
	get: return _current_song
	set(value): _current_song = value

var _in_loop_crossfade: bool = false
var _is_song_transition: bool = false
var _transition_time_elapsed: float = 0.0
var _current_transition_duration: float = 1.0  # Duration for current transition
var _volume_tween: Tween
var _fade_out_tween: Tween
var _target_volume: float = 1.0  # Track target volume for get_volume()
var _is_paused: bool = false

# Song stack for push/pop functionality
var _song_stack: Array[Dictionary] = []  # [{song: Song, position: float}, ...]

# Per-player buses
var _bus_indices: Array[int] = []
var _amplify_effects: Array[AudioEffectAmplify] = []

func _ready() -> void:
	_setup_player_buses()
	for i in players.size():
		players[i].bus = _get_player_bus_name(i)
		players[i].volume_db = MUTE_DB

func _process(delta: float) -> void:
	if _is_paused:
		return
	if _is_song_transition:
		_handle_song_transition(delta)
	elif _current_song and (_any_playing() or _should_be_looping()):
		_handle_loop_crossfade()

# =============================================================================
# PUBLIC API
# =============================================================================

## Play a song, optionally crossfading from the current song.
## transition_time: Duration of crossfade in seconds. If 0, starts immediately with no transition.
func play_song(song: Song, at_point: float = 0.0, transition_time: float = DEFAULT_TRANSITION_TIME) -> void:
	if _fade_out_tween != null and _fade_out_tween.is_running():
		_fade_out_tween.kill()
	
	# Cancel any in-progress crossfades before starting new playback
	if _is_song_transition or _in_loop_crossfade:
		_inactive().stop()
		_inactive().stream = null
		_in_loop_crossfade = false
		_is_song_transition = false
		_active().volume_db = FULL_DB
	
	_current_song = song
	
	# If transition requested and something is playing, crossfade
	if transition_time > 0.0 and _any_playing():
		_start_song_transition(song, at_point, transition_time)
	else:
		# Hard start: stop everything and play immediately
		_reset_players()
		active_idx = 0
		var active: AudioStreamPlayer = _active()
		if song:
			active.stream = song.song_file
		else:
			active.stream = null
		active.volume_db = FULL_DB
		active.play(at_point)
		_set_player_amplify(active_idx, song)
		song_changed.emit(song)

## Push current song onto the stack and play a new song.
## Saves the current song and playback position so it can be restored with pop_song().
func push_song(song: Song, at_point: float = 0.0, transition_time: float = DEFAULT_TRANSITION_TIME) -> void:
	# Save current state to stack
	if _current_song:
		_song_stack.push_back({
			"song": _current_song,
			"position": get_position()
		})
	
	play_song(song, at_point, transition_time)

## Pop the previous song from the stack and resume it.
## fade_out_time: How long to fade out the current song (0 = instant stop)
## delay: Seconds of silence before resuming the previous song
## fade_in_time: How long to fade in the resumed song (0 = instant start)
func pop_song(fade_out_time: float = DEFAULT_FADE_OUT_DURATION, delay: float = 0.0, fade_in_time: float = 0.0) -> void:
	if _song_stack.is_empty():
		# Nothing to pop, just fade out
		if fade_out_time > 0:
			fade_out(fade_out_time)
		else:
			stop()
		return
	
	var previous: Dictionary = _song_stack.pop_back()
	var previous_song: Song = previous["song"]
	var previous_position: float = previous["position"]
	
	# Start the async pop sequence
	_do_pop_sequence(previous_song, previous_position, fade_out_time, delay, fade_in_time)

## Immediately stop all playback.
func stop() -> void:
	_reset_players()

## Gradually fade out the music, then stop.
func fade_out(duration: float = DEFAULT_FADE_OUT_DURATION) -> void:
	# Stop inactive players
	for player in players:
		if player != players[active_idx]:
			player.stop()
	
	if _fade_out_tween != null and _fade_out_tween.is_running():
		_fade_out_tween.kill()
	
	_fade_out_tween = create_tween()
	_fade_out_tween.tween_property(players[active_idx], "volume_db", MUTE_DB, duration)
	_fade_out_tween.finished.connect(_on_fade_out_finished)

## Clear the song stack without affecting current playback.
func clear_stack() -> void:
	_song_stack.clear()

## Get the number of songs on the stack.
func get_stack_size() -> int:
	return _song_stack.size()

## Peek at the top of the stack without popping.
## Returns {song: Song, position: float} or empty dictionary if stack is empty.
func peek_stack() -> Dictionary:
	if _song_stack.is_empty():
		return {}
	return _song_stack.back()

## Seek to a specific position in the current song.
func seek(position: float) -> void:
	if not _current_song:
		return
	var active: AudioStreamPlayer = _active()
	# If paused, we need to unpause, seek, then re-pause
	if _is_paused:
		active.stream_paused = false
		active.seek(position)
		active.stream_paused = true
	elif active.playing:
		active.seek(position)
	else:
		active.play(position)

## Pause playback.
func pause() -> void:
	if _is_paused:
		return
	_is_paused = true
	for player in players:
		player.stream_paused = true

## Resume playback after pausing.
func resume() -> void:
	if not _is_paused:
		return
	_is_paused = false
	for player in players:
		player.stream_paused = false

## Returns true if music is currently playing (not paused or stopped).
func is_playing() -> bool:
	return not _is_paused and (_active().playing or _active().stream_paused)

## Returns true if music is paused.
func is_paused() -> bool:
	return _is_paused

## Get the current playback position in seconds.
func get_position() -> float:
	return _active().get_playback_position()

## Get the total length of the current song in seconds.
func get_length() -> float:
	var s: AudioStream = _active().stream
	if s != null and s.has_method("get_length"):
		return s.get_length()
	return 0.0

## Get the currently loaded song.
func get_current_song() -> Song:
	return _current_song

## Set the volume level (0.0 to 1.0, where 0 is silent and 1 is full volume).
func set_volume(level: float) -> void:
	level = clampf(level, 0.0, 1.0)
	_target_volume = level

	var target_db: float
	if level == 0.0:
		target_db = MUTE_DB
	else:
		target_db = linear_to_db(level)

	if _volume_tween and _volume_tween.is_valid():
		_volume_tween.kill()

	_volume_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	for player in players:
		_volume_tween.tween_property(
			player, "volume_db",
			target_db,
			VOLUME_TRANSITION_TIME
		)

## Get the current volume level (0.0 to 1.0).
func get_volume() -> float:
	return _target_volume

# =============================================================================
# INTERNAL
# =============================================================================

func _get_player_bus_name(idx: int) -> String:
	return bus_name + "_" + str(idx)

func _setup_player_buses() -> void:
	var parent_bus_idx := AudioServer.get_bus_index(bus_name)
	if parent_bus_idx == -1:
		push_warning("MusicPlayer: Bus '%s' not found, creating it" % bus_name)
		parent_bus_idx = AudioServer.bus_count
		AudioServer.add_bus()
		AudioServer.set_bus_name(parent_bus_idx, bus_name)
	
	# Create two child buses, one for each player
	for i in 2:
		var child_bus_name := _get_player_bus_name(i)
		var child_idx := AudioServer.get_bus_index(child_bus_name)
		
		if child_idx == -1:
			# Create the child bus
			child_idx = AudioServer.bus_count
			AudioServer.add_bus(child_idx)
			AudioServer.set_bus_name(child_idx, child_bus_name)
			AudioServer.set_bus_send(child_idx, bus_name)
			
			# Add amplify effect
			var effect := AudioEffectAmplify.new()
			effect.volume_db = 0.0
			AudioServer.add_bus_effect(child_idx, effect)
		
		_bus_indices.append(child_idx)
		
		# Find the amplify effect on this bus
		for j in AudioServer.get_bus_effect_count(child_idx):
			var effect := AudioServer.get_bus_effect(child_idx, j)
			if effect is AudioEffectAmplify:
				_amplify_effects.append(effect)
				break

func _set_player_amplify(player_idx: int, song: Song) -> void:
	if player_idx < _amplify_effects.size():
		_amplify_effects[player_idx].volume_db = song.amplify_db if song else 0.0

## Called by song editor for real-time amplify adjustment
func refresh_amplify() -> void:
	_set_player_amplify(active_idx, _current_song)

func _start_song_transition(song: Song, at_point: float, duration: float) -> void:
	_is_song_transition = true
	_transition_time_elapsed = 0.0
	_current_transition_duration = duration
	var inactive_idx := 1 - active_idx
	var inactive: AudioStreamPlayer = _inactive()
	if song:
		inactive.stream = song.song_file
	else:
		inactive.stream = null
	inactive.volume_db = MUTE_DB
	_set_player_amplify(inactive_idx, song)  # Set amplify before crossfade starts
	inactive.play(at_point)

func _handle_song_transition(delta: float) -> void:
	if not _is_song_transition:
		return
	_transition_time_elapsed += delta
	var t: float = minf(_transition_time_elapsed / _current_transition_duration, 1.0)
	var fade_in_amount: float = song_transition_curve.sample(t) if song_transition_curve else t
	# Fade out curve sampled in reverse (so the curve has the same shape as the fade in)
	var fade_out_amount: float = song_transition_curve.sample(1.0 - t) if song_transition_curve else (1.0 - t)
	var inactive: AudioStreamPlayer = _inactive()
	var active: AudioStreamPlayer = _active()
	inactive.volume_db = MUTE_DB + (-MUTE_DB) * fade_in_amount
	active.volume_db = MUTE_DB + (-MUTE_DB) * fade_out_amount
	if _transition_time_elapsed >= _current_transition_duration:
		active.stop()
		active.stream = null
		active_idx = 1 - active_idx
		_is_song_transition = false
		_active().volume_db = FULL_DB
		transition_finished.emit()
		song_changed.emit(_current_song)

func _do_pop_sequence(song: Song, at_position: float, fade_out_time: float, delay: float, fade_in_time: float) -> void:
	# Fade out current song
	if fade_out_time > 0 and _any_playing():
		# Stop inactive players
		for player in players:
			if player != players[active_idx]:
				player.stop()
		
		if _fade_out_tween != null and _fade_out_tween.is_running():
			_fade_out_tween.kill()
		
		_fade_out_tween = create_tween()
		_fade_out_tween.tween_property(players[active_idx], "volume_db", MUTE_DB, fade_out_time)
		await _fade_out_tween.finished
		stop()
	else:
		stop()
	
	# Wait for delay
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	# Resume previous song
	if fade_in_time > 0:
		# Fade in from silence
		_reset_players()
		active_idx = 0
		var active: AudioStreamPlayer = _active()
		_current_song = song
		if song:
			active.stream = song.song_file
		active.volume_db = MUTE_DB
		active.play(at_position)
		
		var fade_in_tween := create_tween()
		fade_in_tween.tween_property(active, "volume_db", FULL_DB, fade_in_time)
		_set_player_amplify(active_idx, song)
		await fade_in_tween.finished
		song_changed.emit(song)
	else:
		play_song(song, at_position, 0.0)

func _on_fade_out_finished() -> void:
	fade_out_finished.emit()
	stop()

func _handle_loop_crossfade() -> void:
	if not _current_song:
		return
	
	var active: AudioStreamPlayer = _active()
	var pos: float = active.get_playback_position()
	var loop_start: float = _current_song.loop_start
	var loop_end: float = _current_song.loop_end
	var fade_period: float = _current_song.fade_period
	
	var song_length := active.stream.get_length() if active.stream else 0.0
	var loop_ends_at_track_end := song_length > 0 and loop_end >= song_length - 0.1
	
	if fade_period < 0.01 and loop_ends_at_track_end:
		if pos >= loop_end - 0.05 or not active.playing:
			active.play(loop_start)
		return
	
	# Crossfade loop logic
	var inactive: AudioStreamPlayer = _inactive()
	var fade_start: float = loop_end - fade_period
	var new_loop_start: float = maxf(0.0, loop_start - fade_period)

	if pos >= fade_start and not _in_loop_crossfade:
		_in_loop_crossfade = true
		inactive.stream = _current_song.song_file
		inactive.volume_db = MUTE_DB
		_set_player_amplify(1 - active_idx, _current_song)  # Set amplify on incoming loop player
		inactive.play(new_loop_start)

	if _in_loop_crossfade:
		var t: float = clampf((pos - fade_start) / fade_period, 0.0, 1.0)
		var fade_out_amp: float = sqrt(maxf(0.0, _current_song.fade_out_curve.sample(t)))
		var fade_in_amp: float = sqrt(maxf(0.0, _current_song.fade_in_curve.sample(t)))
		active.volume_db = linear_to_db(fade_out_amp) if fade_out_amp > 0.0001 else MUTE_DB
		inactive.volume_db = linear_to_db(fade_in_amp) if fade_in_amp > 0.0001 else MUTE_DB

	if pos >= loop_end or not active.playing:
		if not _in_loop_crossfade:
			inactive.stream = _current_song.song_file
			inactive.volume_db = MUTE_DB
			_set_player_amplify(1 - active_idx, _current_song)
			inactive.play(new_loop_start)
		active.stop()
		active.stream = null
		active_idx = 1 - active_idx
		_in_loop_crossfade = false
		_active().volume_db = FULL_DB
		_inactive().volume_db = MUTE_DB

func _reset_players() -> void:
	for player in players:
		player.stop()
		player.stream = null
		player.volume_db = MUTE_DB
		player.stream_paused = false
	_in_loop_crossfade = false
	_is_song_transition = false
	_is_paused = false

func _active() -> AudioStreamPlayer:
	return players[active_idx]

func _inactive() -> AudioStreamPlayer:
	return players[1 - active_idx]

func _any_playing() -> bool:
	for player in players:
		if player.playing:
			return true
	return false

func _should_be_looping() -> bool:
	# If the active player has a stream but isn't playing, it stopped naturally and needs to loop
	var active: AudioStreamPlayer = _active()
	return active.stream != null and not active.playing
