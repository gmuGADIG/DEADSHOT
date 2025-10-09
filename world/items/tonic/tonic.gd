class_name Tonic extends Item

## When the tonic is picked up, it instantly restores
## one heart to the player.
func on_pickup(body: Node3D) -> void:
	var player: Player = body as Player;
	if player:
		# healing here
		queue_free();
