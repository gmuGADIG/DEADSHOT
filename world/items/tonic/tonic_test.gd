extends Item

func on_pickup(body: Node3D) -> void:
	var player: Player = body as Player;
	if player:
		print("I GOT EATEN!");
		queue_free();
