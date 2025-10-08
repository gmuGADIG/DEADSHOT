class_name HurtboxComponent extends Area3D

@export var health_component : HealthComponent
@export var allowed_damage_sources : Array[DamageInfo.Source]

func _ready() -> void:
	assert(health_component != null, "No health component added")

func hit(dmg: DamageInfo) -> void:
	if dmg.source in allowed_damage_sources:
		health_component.hurt(dmg.damage)
