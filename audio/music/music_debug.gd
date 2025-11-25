extends Control
class_name MusicPlayerDebug

const EPS := 0.001

const default_song_path = "res://audio/music/default_song.tres"

@onready var pl: MusicPlayer = $MusicPlayer
@onready var start_edit: LineEdit = $VBoxContainer/Controls/PlayContainer/LoopStartContainer/LoopStartEdit
@onready var end_edit: LineEdit = $VBoxContainer/Controls/PlayContainer/LoopEndContainer/LoopEndEdit
@onready var delta_edit: LineEdit = $VBoxContainer/Controls/TweakContainer/FineTuneContainer/StepEdit
@onready var reset_btn: Button = $VBoxContainer/Controls/TweakContainer/FineTuneContainer/ResetBtn
@onready var s_rush_btn: Button = $VBoxContainer/Controls/TweakContainer/StartTune/StartRushBtn
@onready var s_drag_btn: Button = $VBoxContainer/Controls/TweakContainer/StartTune/StartDragBtn
@onready var e_rush_btn: Button = $VBoxContainer/Controls/TweakContainer/EndTune/EndRushBtn
@onready var e_drag_btn: Button = $VBoxContainer/Controls/TweakContainer/EndTune/EndDragBtn
@onready var play_btn: Button = $VBoxContainer/Controls/PlayContainer/ButtonsContainer/PlayButton
@onready var test_btn: Button = $VBoxContainer/Controls/PlayContainer/ButtonsContainer/TestLoopButton
@onready var stop_btn: Button = $VBoxContainer/Controls/PlayContainer/ButtonsContainer/StopButton
@onready var play_from_loop_start: Button = $VBoxContainer/Controls/PlayContainer/ButtonsContainer/PlayLoopStartButton
@onready var time_lbl: Label = $VBoxContainer/ProgressContainer/TimeLabel
@onready var time_slider: HSlider = $VBoxContainer/ProgressContainer/ProgressSlider
@onready var file_select: OptionButton = $VBoxContainer/LoadFileContainer/FileSelect
@onready var load_button: Button = $VBoxContainer/LoadFileContainer/LoadSongBtn
@onready var save_button: Button = $VBoxContainer/SaveFileContainer/SaveSongBtn
@onready var save_line_edit: LineEdit = $VBoxContainer/SaveFileContainer/FilePath
@onready var volume_slider: HSlider = $VBoxContainer/VolumeContainer/VolumeSlider

var s_lo: float
var s_hi: float
var e_lo: float
var e_hi: float

func _ready() -> void:
	_sync_fields()
	_setup_file_options()
	_connect_ui()
	_reset_search()

func _process(_d: float) -> void:
	_update_progress()

# binary search
func _reset_search() -> void:
	var d: float  = abs(delta_edit.text.to_float())
	var s0: float = start_edit.text.to_float()
	var e0: float = end_edit.text.to_float()
	s_lo = s0 - d;  s_hi = s0 + d
	e_lo = e0 - d;  e_hi = e0 + d
	_apply_midpoints()

func _apply_midpoints() -> void:
	pl.current_song.loop_start = (s_lo + s_hi) * 0.5
	pl.current_song.loop_end   = (e_lo + e_hi) * 0.5
	_sync_fields()
	_disable_when_done()

func _s_rush() -> void: s_lo = (s_lo + s_hi) * 0.5; _apply_midpoints(); _test_loop()
func _s_drag() -> void: s_hi = (s_lo + s_hi) * 0.5; _apply_midpoints(); _test_loop()
func _e_rush() -> void: e_lo = (e_lo + e_hi) * 0.5; _apply_midpoints(); _test_loop()
func _e_drag() -> void: e_hi = (e_lo + e_hi) * 0.5; _apply_midpoints(); _test_loop()

func _test_loop() -> void:
	pl.play(pl.current_song.loop_end - 3.0)

func _disable_when_done() -> void:
	var s_done: float = (s_hi - s_lo) < EPS
	var e_done: float = (e_hi - e_lo) < EPS
	s_rush_btn.disabled = s_done
	s_drag_btn.disabled = s_done
	e_rush_btn.disabled = e_done
	e_drag_btn.disabled = e_done

# ui helpers
func _sync_fields() -> void:
	start_edit.text = str(pl.current_song.loop_start)
	end_edit.text   = str(pl.current_song.loop_end)
	volume_slider.set_value_no_signal(1.0)
	
func _setup_file_options() -> void:
	for file in SongScanner.sound_files:
		file_select.add_item(file.resource_path)

func _connect_ui() -> void:
	start_edit.text_changed.connect(_on_start_changed)
	end_edit.text_changed.connect(_on_end_changed)
	delta_edit.text_changed.connect(_on_delta_changed)
	play_btn.pressed.connect(pl.play)
	stop_btn.pressed.connect(pl.stop)
	test_btn.pressed.connect(_test_loop)
	play_from_loop_start.pressed.connect(_on_loop_start_play)
	reset_btn.pressed.connect(_reset_search)
	s_rush_btn.pressed.connect(_s_rush)
	s_drag_btn.pressed.connect(_s_drag)
	e_rush_btn.pressed.connect(_e_rush)
	e_drag_btn.pressed.connect(_e_drag)
	load_button.pressed.connect(_load_file)
	save_button.pressed.connect(_save_song_to_resource)
	time_slider.value_changed.connect(_on_progress_slider_change)
	volume_slider.value_changed.connect(_on_volume_slider_change)
	
func _on_progress_slider_change(value: float) -> void:
	pl.play(value * pl.get_length())
	
func _on_volume_slider_change(value: float) -> void:
	pl.set_volume(value)
	
func _save_song_to_resource() -> void:
	var save_location: String = save_line_edit.text
	if save_location != '':
		ResourceSaver.save(pl.current_song, save_location)
	
func _on_loop_start_play() -> void:
	pl.play(pl.current_song.loop_start)
	
func _load_file() -> void:
	if file_select.selected == -1:
		return
	var song_file: Resource = load(file_select.get_item_text(file_select.selected))
	if song_file is Song:
		pl.transition_to_song(song_file)
		save_line_edit.text = file_select.get_item_text(file_select.selected)
	else:
		var song: Song = load(default_song_path)
		song.song_file = song_file
		song.loop_end = song_file.get_length()
		song.loop_start = 0
		pl.transition_to_song(song)
	_sync_fields()
	_update_progress()
	_reset_search()
	

func _on_start_changed(t: String) -> void:
	pl.current_song.loop_start = t.to_float()

func _on_end_changed(t: String) -> void:
	pl.current_song.loop_end = t.to_float()
	
func _on_delta_changed(_t: String) -> void:
	_reset_search()

# progress bar
func _update_progress() -> void:
	if not pl.is_playing():
		time_lbl.text = "--:-- / --:--"
		time_slider.set_value_no_signal(0)
		return
	var song_pos: float = pl.get_position()
	var song_len: float = pl.get_length()
	if song_len <= 0:
		time_lbl.text = "--:-- / --:--"
		time_slider.set_value_no_signal(0)
		return
	time_lbl.text = "%02d:%02d / %02d:%02d" % [
		int(song_pos / 60), int(song_pos) % 60,
		int(song_len / 60), int(song_len) % 60
	]
	time_slider.set_value_no_signal(song_pos/song_len)
