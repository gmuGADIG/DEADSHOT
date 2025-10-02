class_name HurtboxComponent extends Area3D



@export var health_component : HealthComponent
@export var allowed_damage_sources : Array[DamageComponent.Source]

func _ready() -> void:
	assert(health_component != null, "No health component added")



func hit(damage_component: DamageComponent) -> void:
	if allowed_damage_sources.has(damage_component.source):
		health_component.hurt(damage_component.damage)
