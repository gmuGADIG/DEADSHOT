extends CanvasItem

func _ready() ->void:
	hide()

func _process(delta: float) ->void:
	if(Input.is_key_pressed(KEY_ENTER)):
		show()
