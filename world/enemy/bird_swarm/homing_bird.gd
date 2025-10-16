class_name HomingBird
extends Bullet

@export var homingBirdSpeed: float = 6.0
var home_direction: Vector3

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func fire(gun: Node3D, direction: Vector3) -> void:
	global_position = gun.global_position
	velocity = direction * homingBirdSpeed
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	home_direction = Player.instance.global_position - self.global_position;
	velocity = home_direction * homingBirdSpeed
	global_position.x += velocity.x * delta
	global_position.z += velocity.z * delta

func _on_area_entered(area: Area3D) -> void:
	print(area)
	if area is Hurtbox:
		var hurtbox : Hurtbox = area
		var dmg := DamageInfo.new(atk_damage, atk_source, atk_knockback, velocity.normalized())
		var did_damage := hurtbox.hit(dmg)
		
		if did_damage:
			queue_free()
