extends Item

var tween: Tween

func _ready() -> void:
	jump()
	body_entered.connect(on_pickup)

func jump() -> void:
	# For random direction
	var r_x := randf_range(-1, 1)
	var r_z := randf_range(-1, 1)
	
	# tween to animate
	if tween and tween.is_valid():
		tween.kill()
	
	tween = create_tween()
	scale = Vector3.ZERO
	
	# Jump to the heavens
	tween.tween_property(self, "position:y", position.y + 1, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Moves in x and z directions
	tween.parallel().tween_property(self, "position:x", position.x + r_x, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "position:z", position.z + r_z, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "scale", Vector3.ONE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Descend upon the earth and rule all evil
	tween.tween_property(self, "position:y", position.y, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	# tween to make it go in a random direction
	tween.parallel().tween_property(self, "position:x", position.x + (r_x*2), 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "position:z", position.z + (r_z*2), 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func on_pickup(body: Node3D) -> void:
	var player: Player = body as Player;
	if player:
		var player_health : Health = player.get_node("HurtboxComponent/HealthComponent");
		player_health.heal(2);
		print(player_health.health);
		
		# Reparents to current scene so sound does not dissappear when tonic is freed.
		# Sound is freed when done playing.
		var sfx: AudioStreamPlayer3D = %TonicPickupSound
		sfx.reparent(get_tree().current_scene)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)
		
		queue_free();
