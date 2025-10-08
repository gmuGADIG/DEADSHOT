class_name DamageInfo
extends Resource

enum Source {
	PLAYER, ## Hurts enemies
	ENEMY, ## Hurts players
	NEUTRAL, ## Hurts both players and enemies
}

enum KnockbackStrength {
	NONE,
	NORMAL,
	STRONG
}

var damage: int
var source: Source
var knockback: KnockbackStrength
var direction: Vector3

func _init(dmg: int, src: Source, knockback_str: KnockbackStrength, dir: Vector3) -> void:
	self.damage = dmg
	self.source = src
	self.knockback = knockback_str
	self.direction = dir
