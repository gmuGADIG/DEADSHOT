extends CharacterBody3D

func _on_damage_area_body_entered(body: Node3D) -> void:
	if body is Player:
		body.hurt(1)

func _physics_process(_delta: float) -> void:
	if $DamageArea.has_overlapping_bodies():
		for y: Node3D in $DamageArea.get_overlapping_bodies():
			if y is Player:
				y.hurt(1)
