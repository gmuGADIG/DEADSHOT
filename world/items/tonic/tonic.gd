extends Item

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
