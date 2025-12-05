extends Node
class_name MusicPlayer

signal song_changed(new_song: Song)
signal transition_finished
signal fade_out_finished
signal song_finished

@export var bus_name: String = "Music"
@export var song_transition_curve: Curve

const FULL_DB: float = 0.0
const MUTE_DB: float = -64.0
const VOLUME_TRANSITION_TIME: float = 0.2
const DEFAULT_TRANSITION_TIME: float = 1.0
const DEFAULT_FADE_OUT_DURATION: float = 2.0

@onready var players: Array[AudioStreamPlayer] = [$AudioStreamPlayerA, $AudioStreamPlayerB]

var active_idx: int = 0
var current_song: Song
var _in_loop_crossfade: bool = false
var _is_song_transition: bool = false
var _transition_time_elapsed: float = 0.0
var _current_transition_duration: float = 1.0
var _volume_tween: Tween
var _fade_out_tween: Tween
var _target_volume: float = 1.0
var _is_paused: bool = false
var _song_stack: Array[Dictionary] = []
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
	elif current_song:
		if current_song.loop_info and (_any_playing() or _song_ended()):
			_handle_loop_crossfade()
		elif not current_song.loop_info and _song_ended():
			song_finished.emit()
			current_song = null

# =============================================================================
# PUBLIC API
# =============================================================================

func play_song(song: Song, at_point: float = 0.0, transition_time: float = DEFAULT_TRANSITION_TIME) -> void:
	_kill_tween(_fade_out_tween)
	
	if _is_song_transition or _in_loop_crossfade:
		_inactive().stop()
		_inactive().stream = null
		_in_loop_crossfade = false
		_is_song_transition = false
		_active().volume_db = FULL_DB
	
	current_song = song
	
	if transition_time > 0.0 and _any_playing():
		_start_song_transition(song, at_point, transition_time)
	else:
		_reset_players()
		active_idx = 0
		var active := _active()
		active.stream = song.song_file if song else null
		active.volume_db = FULL_DB
		active.play(at_point)
		_set_player_amplify(active_idx, song)
		song_changed.emit(song)

func push_song(song: Song, at_point: float = 0.0, transition_time: float = DEFAULT_TRANSITION_TIME) -> void:
	if current_song:
		_song_stack.push_back({"song": current_song, "position": get_position()})
	play_song(song, at_point, transition_time)

func pop_song(fade_out_time: float = DEFAULT_FADE_OUT_DURATION, delay: float = 0.0, fade_in_time: float = 0.0) -> void:
	if _song_stack.is_empty():
		if fade_out_time > 0:
			fade_out(fade_out_time)
		else:
			stop()
		return
	
	var previous: Dictionary = _song_stack.pop_back()
	_do_pop_sequence(previous["song"], previous["position"], fade_out_time, delay, fade_in_time)

func stop() -> void:
	_reset_players()

func fade_out(duration: float = DEFAULT_FADE_OUT_DURATION) -> void:
	_inactive().stop()
	_kill_tween(_fade_out_tween)
	_fade_out_tween = create_tween()
	_fade_out_tween.tween_property(_active(), "volume_db", MUTE_DB, duration)
	_fade_out_tween.finished.connect(_on_fade_out_finished)

func clear_stack() -> void:
	_song_stack.clear()

func get_stack_size() -> int:
	return _song_stack.size()

func peek_stack() -> Dictionary:
	return _song_stack.back() if not _song_stack.is_empty() else {}

func seek(position: float) -> void:
	if not current_song:
		return
	var active := _active()
	if _is_paused:
		active.stream_paused = false
		active.seek(position)
		active.stream_paused = true
	elif active.playing:
		active.seek(position)
	else:
		active.play(position)

func pause() -> void:
	if _is_paused:
		return
	_is_paused = true
	for player in players:
		player.stream_paused = true

func resume() -> void:
	if not _is_paused:
		return
	_is_paused = false
	for player in players:
		player.stream_paused = false

func is_playing() -> bool:
	return not _is_paused and (_active().playing or _active().stream_paused)

func is_paused() -> bool:
	return _is_paused

func get_position() -> float:
	return _active().get_playback_position()

func get_length() -> float:
	var stream := _active().stream
	return stream.get_length() if stream else 0.0

func get_current_song() -> Song:
	return current_song

func set_volume(level: float) -> void:
	level = clampf(level, 0.0, 1.0)
	_target_volume = level
	var target_db := MUTE_DB if level == 0.0 else linear_to_db(level)
	
	_kill_tween(_volume_tween)
	_volume_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for player in players:
		_volume_tween.tween_property(player, "volume_db", target_db, VOLUME_TRANSITION_TIME)

func get_volume() -> float:
	return _target_volume

func refresh_amplify() -> void:
	_set_player_amplify(active_idx, current_song)

# =============================================================================
# INTERNAL
# =============================================================================

func _get_player_bus_name(idx: int) -> String:
	return "%s_%d" % [bus_name, idx]

func _setup_player_buses() -> void:
	var parent_idx := AudioServer.get_bus_index(bus_name)
	if parent_idx == -1:
		push_warning("MusicPlayer: Bus '%s' not found, creating it" % bus_name)
		parent_idx = AudioServer.bus_count
		AudioServer.add_bus()
		AudioServer.set_bus_name(parent_idx, bus_name)
	
	for i in 2:
		var child_name := _get_player_bus_name(i)
		var child_idx := AudioServer.get_bus_index(child_name)
		
		if child_idx == -1:
			child_idx = AudioServer.bus_count
			AudioServer.add_bus(child_idx)
			AudioServer.set_bus_name(child_idx, child_name)
			AudioServer.set_bus_send(child_idx, bus_name)
			var effect := AudioEffectAmplify.new()
			effect.volume_db = 0.0
			AudioServer.add_bus_effect(child_idx, effect)
		
		_bus_indices.append(child_idx)
		for j in AudioServer.get_bus_effect_count(child_idx):
			var effect := AudioServer.get_bus_effect(child_idx, j)
			if effect is AudioEffectAmplify:
				_amplify_effects.append(effect)
				break

func _set_player_amplify(player_idx: int, song: Song) -> void:
	if player_idx < _amplify_effects.size():
		_amplify_effects[player_idx].volume_db = song.amplify_db if song else 0.0

func _start_song_transition(song: Song, at_point: float, duration: float) -> void:
	_is_song_transition = true
	_transition_time_elapsed = 0.0
	_current_transition_duration = duration
	var inactive_idx := 1 - active_idx
	var inactive := _inactive()
	inactive.stream = song.song_file if song else null
	inactive.volume_db = MUTE_DB
	_set_player_amplify(inactive_idx, song)
	inactive.play(at_point)

func _handle_song_transition(delta: float) -> void:
	_transition_time_elapsed += delta
	var t := minf(_transition_time_elapsed / _current_transition_duration, 1.0)
	var fade_in_amt := song_transition_curve.sample(t) if song_transition_curve else t
	var fade_out_amt := song_transition_curve.sample(1.0 - t) if song_transition_curve else (1.0 - t)
	
	_inactive().volume_db = MUTE_DB + (-MUTE_DB) * fade_in_amt
	_active().volume_db = MUTE_DB + (-MUTE_DB) * fade_out_amt
	
	if _transition_time_elapsed >= _current_transition_duration:
		_active().stop()
		_active().stream = null
		active_idx = 1 - active_idx
		_is_song_transition = false
		_active().volume_db = FULL_DB
		transition_finished.emit()
		song_changed.emit(current_song)

func _do_pop_sequence(song: Song, at_position: float, fade_out_time: float, delay: float, fade_in_time: float) -> void:
	# Update current_song immediately so that if push_song is called during
	# the fade-out, it will save the correct song (the one we're transitioning to)
	# rather than the one that's fading out.
	current_song = song
	
	if fade_out_time > 0 and _any_playing():
		_inactive().stop()
		_kill_tween(_fade_out_tween)
		_fade_out_tween = create_tween()
		_fade_out_tween.tween_property(_active(), "volume_db", MUTE_DB, fade_out_time)
		await _fade_out_tween.finished
		stop()
	else:
		stop()
	
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	if fade_in_time > 0:
		_reset_players()
		active_idx = 0
		var active := _active()
		current_song = song
		active.stream = song.song_file if song else null
		active.volume_db = MUTE_DB
		active.play(at_position)
		_set_player_amplify(active_idx, song)
		var tween := create_tween()
		tween.tween_property(active, "volume_db", FULL_DB, fade_in_time)
		await tween.finished
		song_changed.emit(song)
	else:
		play_song(song, at_position, 0.0)

func _on_fade_out_finished() -> void:
	fade_out_finished.emit()
	stop()

func _handle_loop_crossfade() -> void:
	var loop_info: LoopInfo = current_song.loop_info
	var active := _active()
	var inactive := _inactive()
	var pos := active.get_playback_position()
	var loop_start := loop_info.loop_start
	var loop_end := loop_info.loop_end
	var fade_period := loop_info.fade_period
	var song_length := active.stream.get_length() if active.stream else 0.0
	
	# Simple loop (no crossfade) when fade is negligible and loop ends at track end
	if fade_period < 0.01 and song_length > 0 and loop_end >= song_length - 0.1:
		if pos >= loop_end - 0.05 or not active.playing:
			active.play(loop_start)
		return
	
	var fade_start := loop_end - fade_period
	var new_loop_start := maxf(0.0, loop_start - fade_period)

	# Start crossfade
	if pos >= fade_start and not _in_loop_crossfade:
		_in_loop_crossfade = true
		inactive.stream = current_song.song_file
		inactive.volume_db = MUTE_DB
		_set_player_amplify(1 - active_idx, current_song)
		inactive.play(new_loop_start)

	# Apply crossfade volumes
	if _in_loop_crossfade:
		var t := clampf((pos - fade_start) / fade_period, 0.0, 1.0)
		var out_amp := sqrt(maxf(0.0, loop_info.fade_out_curve.sample(t)))
		var in_amp := sqrt(maxf(0.0, loop_info.fade_in_curve.sample(t)))
		active.volume_db = linear_to_db(out_amp) if out_amp > 0.0001 else MUTE_DB
		inactive.volume_db = linear_to_db(in_amp) if in_amp > 0.0001 else MUTE_DB

	# Complete loop
	if pos >= loop_end or not active.playing:
		if not _in_loop_crossfade:
			inactive.stream = current_song.song_file
			inactive.volume_db = MUTE_DB
			_set_player_amplify(1 - active_idx, current_song)
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

func _kill_tween(tween: Tween) -> void:
	if tween and tween.is_running():
		tween.kill()

func _active() -> AudioStreamPlayer:
	return players[active_idx]

func _inactive() -> AudioStreamPlayer:
	return players[1 - active_idx]

func _any_playing() -> bool:
	return players[0].playing or players[1].playing

func _song_ended() -> bool:
	var active := _active()
	return active.stream != null and not active.playing
