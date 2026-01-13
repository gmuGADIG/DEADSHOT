extends Node3D

var tween : Tween

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body is Player:
		return
	
	print("Currecny Colletced")
	Global.meat_currency += 10
	print(Global.meat_currency)
	
	var label_instance := Label3D.new()
	label_instance.text = "Meat +10"
	label_instance.font_size = 100
	label_instance.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	body.add_child(label_instance)
	if tween and tween.is_valid():
		tween.kill()
	
	tween = label_instance.create_tween()
	tween.tween_property(label_instance, "position", Vector3(0, 3, 0), 0.75).set_ease(Tween.EASE_OUT)
	tween.finished.connect(label_instance.queue_free)
	
	# Play the meat pickup sound
	var pickup_sound := preload("res://audio/streams/meat_pickup_sound.tscn").instantiate()
	add_sibling(pickup_sound)
	queue_free()
