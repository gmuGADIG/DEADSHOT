extends TextureProgressBar

func _ready() -> void:
	set_progress(1.0)
	pass # todo: connect to "reload progress changed" signal

func set_progress(progress: float) -> void:
	value = progress
	visible = progress < 1.0
