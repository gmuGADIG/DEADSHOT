extends Item

func on_pickup(body: Node3D) -> void:
	var player: Player = body as Player;
	if player:
		var player_health : Health = player.get_node("HurtboxComponent/HealthComponent");
		player_health.heal(2);
		print(player_health.health);
		queue_free();
