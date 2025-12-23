class_name Slash
extends Area3D

@export var atk_damage: int = 1
@export var atk_source: DamageInfo.Source
@export var atk_knockback: DamageInfo.KnockbackStrength
##the amount of time the slash exists (to be scaled once animation is added)
@export var time: int 

@onready var hitDestroy := $CollisionShape3D

func fire(gun: Node3D, direction: Vector3) -> void:
	global_position = gun.global_position  + (direction * 2)
	
func _process(_delta: float) -> void:
	time -= 1
	if(time <= 0):
		queue_free()
		
func _on_area_entered(area: Area3D) -> void:
	print("huzah")
	if area is Hurtbox:
		var hurtbox: Hurtbox = area
		var dmg := DamageInfo.new(atk_damage, atk_source,atk_knockback, Vector3(0,0,0))
		var did_dmg := hurtbox.hit(dmg)
		
		if(did_dmg):
			print("hit")
			
	
