class_name QTETarget2D
extends Node2D

var preferred_scale := Vector2.ONE

signal clicked

func _input(event: InputEvent) -> void:
	if not visible: return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var p := get_local_mouse_position()
			if maxf(absf(p.x), absf(p.y)) < (35 / 2.):
				print(p)
				clicked.emit()
