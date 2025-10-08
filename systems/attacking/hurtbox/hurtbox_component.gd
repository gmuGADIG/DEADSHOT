class_name HurtboxComponent extends Area3D

@export var health_component : HealthComponent
@export var is_player: bool ## True if this hurtbox is on the player. Attacks will filter accordingly.

func _ready() -> void:
	assert(health_component != null, "No health component added")

func hit(damage: DamageInfo) -> void:
	# check if sources allows damage
	if is_player:
		if damage.source == DamageInfo.Source.PLAYER: return
	else:
		if damage.source == DamageInfo.Source.ENEMY: return
	
	health_component.hurt(damage.damage)
