class_name PickupText
extends Node3D

func _ready() -> void:
	await %Anim.animation_finished
	queue_free()

func set_ammo(amount: int) -> void:
	%Label.text = "+%d Bullets" % amount

func set_meat(amount: int) -> void:
	%Label.text = "+%d Meat" % amount

func set_hp() -> void:
	%Label.text = "+HP"
