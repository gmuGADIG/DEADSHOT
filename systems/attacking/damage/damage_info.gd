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

@export var damage: float
@export var source: Source
@export var knockback: KnockbackStrength
@export var direction: Vector3

func _init(dmg: float, src: Source, knockback_str: KnockbackStrength = KnockbackStrength.NONE, dir: Vector3 = Vector3.ZERO) -> void:
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
