class_name CampfireMenu
extends Control

static var instance: CampfireMenu

func _init() -> void:
	instance = self

func _on_close_pressed() -> void:
	queue_free()
