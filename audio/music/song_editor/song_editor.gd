extends Control
class_name SongEditor

## Song Resource Editor
## Features:
## - Visual timeline with draggable loop markers
## - Inline curve editors for crossfade
## - Fine-tune controls with arrow key support

# Node references
@onready var music_player: MusicPlayer = $MusicPlayer
@onready var song_scanner: Node = $SongScanner
@onready var timeline: SongTimeline = %Timeline
@onready var file_dropdown: OptionButton = %FileDropdown
@onready var time_display: Label = %TimeDisplay

# Playback controls
@onready var play_btn: Button = %PlayBtn
@onready var stop_btn: Button = %StopBtn
@onready var preview_loop_btn: Button = %PreviewLoopBtn
@onready var volume_slider: HSlider = %VolumeSlider

# Fine tune controls
@onready var loop_start_spin: SpinBox = %LoopStartSpin
@onready var loop_end_spin: SpinBox = %LoopEndSpin
@onready var fade_period_spin: SpinBox = %FadePeriodSpin
@onready var gain_slider: HSlider = %GainSlider
@onready var gain_label: Label = %GainValueLabel

# Curve editors
@onready var fade_in_curve_edit: SongCurveEditor = %FadeInCurve
@onready var fade_out_curve_edit: SongCurveEditor = %FadeOutCurve
@onready var reset_fade_in_btn: Button = %ResetFadeInBtn
@onready var reset_fade_out_btn: Button = %ResetFadeOutBtn

# Save section
@onready var save_path_edit: LineEdit = %SavePathEdit
@onready var save_btn: Button = %SaveBtn

# Toast notification
@onready var toast: PanelContainer = %Toast
@onready var toast_label: Label = %ToastLabel
var _toast_timer: float = 0.0

func _ready() -> void:
	_setup_file_dropdown()
	_connect_signals()
	_sync_ui_from_song()

func _process(delta: float) -> void:
	_update_playhead()
	_update_toast(delta)

func _setup_file_dropdown() -> void:
	file_dropdown.clear()
	file_dropdown.add_item("-- Select Audio File --")
	for file: Resource in song_scanner.sound_files:
		file_dropdown.add_item(file.resource_path)

func _connect_signals() -> void:
	file_dropdown.item_selected.connect(_on_file_selected)
	timeline.loop_start_changed.connect(_on_timeline_loop_start_changed)
	timeline.loop_end_changed.connect(_on_timeline_loop_end_changed)
	timeline.seek_requested.connect(_on_timeline_seek)
	timeline.marker_selected.connect(_on_marker_selected)
	play_btn.pressed.connect(_on_play_pressed)
	stop_btn.pressed.connect(_on_stop_pressed)
	preview_loop_btn.pressed.connect(_on_preview_loop_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	loop_start_spin.value_changed.connect(_on_loop_start_spin_changed)
	loop_end_spin.value_changed.connect(_on_loop_end_spin_changed)
	fade_period_spin.value_changed.connect(_on_fade_period_changed)
	gain_slider.value_changed.connect(_on_gain_changed)
	reset_fade_in_btn.pressed.connect(_on_reset_fade_in)
	reset_fade_out_btn.pressed.connect(_on_reset_fade_out)
	save_btn.pressed.connect(_on_save_pressed)

func _on_file_selected(index: int) -> void:
	if index <= 0:
		return
	
	var file_path: String = file_dropdown.get_item_text(index)
	var resource: Resource = load(file_path)
	
	if resource is Song:
		music_player.current_song = resource.duplicate()
		save_path_edit.text = file_path
	elif resource is AudioStream:
		var song := Song.new()
		song.song_file = resource
		song.loop_info = LoopInfo.new()
		song.loop_info.loop_start = 0.0
		song.loop_info.loop_end = resource.get_length()
		music_player.current_song = song
		save_path_edit.text = file_path.get_basename() + "_song.tres"
	
	# Ensure loop_info exists for editing
	_ensure_loop_info()
	_sync_ui_from_song()
	_setup_curve_editors()

func _ensure_loop_info() -> void:
	var song: Song = music_player.current_song
	if song and not song.loop_info:
		song.loop_info = LoopInfo.new()
		if song.song_file and song.song_file is AudioStream:
			song.loop_info.loop_end = song.song_file.get_length()

func _sync_ui_from_song() -> void:
	if not music_player.current_song or not music_player.current_song.loop_info:
		return
	
	var song: Song = music_player.current_song
	var loop_info: LoopInfo = song.loop_info
	var length: float = 0.0
	if song.song_file and song.song_file is AudioStream:
		length = song.song_file.get_length()
	
	timeline.set_song_length(length)
	timeline.set_loop_start(loop_info.loop_start)
	timeline.set_loop_end(loop_info.loop_end)
	timeline.set_fade_period(loop_info.fade_period)
	
	loop_start_spin.max_value = length
	loop_end_spin.max_value = length
	fade_period_spin.max_value = length * 0.5
	
	loop_start_spin.set_value_no_signal(loop_info.loop_start)
	loop_end_spin.set_value_no_signal(loop_info.loop_end)
	fade_period_spin.set_value_no_signal(loop_info.fade_period)
	gain_slider.set_value_no_signal(song.amplify_db)
	_update_gain_label(song.amplify_db)

func _setup_curve_editors() -> void:
	if not music_player.current_song or not music_player.current_song.loop_info:
		return
	
	var loop_info: LoopInfo = music_player.current_song.loop_info
	fade_in_curve_edit.set_curve(loop_info.fade_in_curve)
	fade_out_curve_edit.set_curve(loop_info.fade_out_curve)


func _update_playhead() -> void:
	var pos := music_player.get_position()
	var length := music_player.get_length()
	
	timeline.set_playhead_position(pos)
	
	if length > 0:
		time_display.text = "%s / %s" % [_format_time(pos), _format_time(length)]
	else:
		time_display.text = "--:-- / --:--"
	
	_update_curve_playheads(pos)

func _format_time(seconds: float) -> String:
	var mins := int(seconds) / 60
	var secs := int(seconds) % 60
	return "%d:%02d" % [mins, secs]

func _update_curve_playheads(pos: float) -> void:
	if not music_player.current_song or not music_player.current_song.loop_info:
		fade_in_curve_edit.set_playhead(-1.0)
		fade_out_curve_edit.set_playhead(-1.0)
		return
	
	var loop_info: LoopInfo = music_player.current_song.loop_info
	var fade_start := loop_info.loop_end - loop_info.fade_period
	
	if pos >= fade_start and pos < loop_info.loop_end and loop_info.fade_period > 0:
		var t := (pos - fade_start) / loop_info.fade_period
		t = clampf(t, 0.0, 1.0)
		fade_in_curve_edit.set_playhead(t)
		fade_out_curve_edit.set_playhead(t)
	else:
		fade_in_curve_edit.set_playhead(-1.0)
		fade_out_curve_edit.set_playhead(-1.0)

func _on_timeline_loop_start_changed(value: float) -> void:
	if music_player.current_song and music_player.current_song.loop_info:
		music_player.current_song.loop_info.loop_start = value
		loop_start_spin.set_value_no_signal(value)

func _on_timeline_loop_end_changed(value: float) -> void:
	if music_player.current_song and music_player.current_song.loop_info:
		music_player.current_song.loop_info.loop_end = value
		loop_end_spin.set_value_no_signal(value)

func _on_timeline_seek(seek_position: float) -> void:
	if music_player.is_playing():
		music_player.seek(seek_position)
	else:
		music_player.play_song(music_player.current_song, seek_position, 0.0)

func _on_marker_selected(_marker: String) -> void:
	pass

func _on_play_pressed() -> void:
	if music_player.is_playing():
		music_player.stop()
	music_player.play_song(music_player.current_song, 0.0, 0.0)

func _on_stop_pressed() -> void:
	music_player.stop()

func _on_preview_loop_pressed() -> void:
	if not music_player.current_song or not music_player.current_song.loop_info:
		return
	var preview_start := maxf(0.0, music_player.current_song.loop_info.loop_end - 3.0)
	if music_player.is_playing():
		music_player.seek(preview_start)
	else:
		music_player.play_song(music_player.current_song, preview_start, 0.0)

func _on_volume_changed(value: float) -> void:
	music_player.set_volume(value)

func _on_loop_start_spin_changed(value: float) -> void:
	if music_player.current_song and music_player.current_song.loop_info:
		music_player.current_song.loop_info.loop_start = value
		timeline.set_loop_start(value)

func _on_loop_end_spin_changed(value: float) -> void:
	if music_player.current_song and music_player.current_song.loop_info:
		music_player.current_song.loop_info.loop_end = value
		timeline.set_loop_end(value)

func _on_fade_period_changed(value: float) -> void:
	if music_player.current_song and music_player.current_song.loop_info:
		music_player.current_song.loop_info.fade_period = value
		timeline.set_fade_period(value)

func _on_gain_changed(value: float) -> void:
	if music_player.current_song:
		music_player.current_song.amplify_db = value
		music_player.refresh_amplify()
		_update_gain_label(value)

func _update_gain_label(value: float) -> void:
	var sign_str: String = "+" if value > 0 else ""
	gain_label.text = "%s%.1f dB" % [sign_str, value]

func _on_save_pressed() -> void:
	var path := save_path_edit.text.strip_edges()
	if path.is_empty():
		_show_toast("Enter a save path", Color(1.0, 0.6, 0.4))
		return
	
	if not path.begins_with("res://"):
		path = "res://audio/music/" + path
	
	if not path.ends_with(".tres"):
		path += ".tres"
	
	var err := ResourceSaver.save(music_player.current_song, path)
	if err == OK:
		_show_toast("Saved!", Color(0.4, 0.8, 0.5))
		save_path_edit.text = path
	else:
		_show_toast("Save failed: " + str(err), Color(1.0, 0.4, 0.4))

func _on_reset_fade_in() -> void:
	if music_player.current_song and music_player.current_song.loop_info:
		var curve: Curve = LoopInfo.new().fade_in_curve
		music_player.current_song.loop_info.fade_in_curve = curve
		fade_in_curve_edit.set_curve(curve)

func _on_reset_fade_out() -> void:
	if music_player.current_song and music_player.current_song.loop_info:
		var curve: Curve = LoopInfo.new().fade_out_curve
		music_player.current_song.loop_info.fade_out_curve = curve
		fade_out_curve_edit.set_curve(curve)

func _show_toast(message: String, color: Color = Color(0.9, 0.9, 0.9)) -> void:
	toast_label.text = message
	toast_label.add_theme_color_override("font_color", color)
	toast.visible = true
	toast.modulate.a = 1.0
	_toast_timer = 2.0

func _update_toast(delta: float) -> void:
	if _toast_timer > 0:
		_toast_timer -= delta
		if _toast_timer <= 0.5:
			toast.modulate.a = _toast_timer / 0.5
		if _toast_timer <= 0:
			toast.visible = false
