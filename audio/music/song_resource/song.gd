extends Resource
class_name Song

@export var loop_start: float
@export var loop_end: float
@export var song_file: Resource
@export var fade_period: float
@export var fade_in_curve: Curve
@export var fade_out_curve: Curve
## Volume adjustment in dB for mastering. 0 = no change, negative = quieter.
@export_range(-20.0, 6.0, 0.1, "suffix:dB") var amplify_db: float = 0.0

func _init(l_start: float = 0.0, l_end: float = 0.0, f_period: float = 0.2) -> void:
	loop_start = l_start
	loop_end = l_end
	fade_period = f_period
	song_file = null
	fade_in_curve = Curve.new()
	fade_out_curve = Curve.new()
	amplify_db = 0.0
