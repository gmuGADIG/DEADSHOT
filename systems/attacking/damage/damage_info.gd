class_name DamageInfo
extends Resource

enum Source {
	PLAYER,
	ENEMY,
	HAZARD,
}

enum KnockbackStrength {
	NONE,
	NORMAL,
	STRONG
}

@export var damage: int
@export var source: Source
@export var knockback: KnockbackStrength
@export var direction: Vector3

func _init(dmg: int, src: Source, knockback_str: KnockbackStrength, dir: Vector3) -> void:
	self.damage = dmg
	self.source = src
	self.knockback = knockback_str
	self.direction = dir.normalized()

func get_knockback() -> Vector3:
	var result := direction
	match knockback:
		KnockbackStrength.NONE: result *= 0
		KnockbackStrength.NORMAL: result *= 1.0
		KnockbackStrength.STRONG: result *= 2.0
	return result
