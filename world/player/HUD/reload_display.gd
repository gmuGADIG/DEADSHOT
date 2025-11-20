extends TextureProgressBar

func _ready() -> void:
	set_progress(1.0)
	Global.player_reload_progress_changed.connect(set_progress)

func set_progress(progress: float) -> void:
	value = progress
	visible = progress < 1.0
