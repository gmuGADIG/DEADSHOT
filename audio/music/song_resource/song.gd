extends Resource
class_name Song

@export var song_file: Resource
## If set, the song will loop using these settings. If null, the song plays once.
@export var loop_info: LoopInfo
## Volume adjustment in dB for mastering. 0 = no change, negative = quieter.
@export_range(-20.0, 6.0, 0.1, "suffix:dB") var amplify_db: float = 0.0
