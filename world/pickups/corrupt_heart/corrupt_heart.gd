class_name CorruptHeart
extends Node3D

@export var health : Health

@export var death_animation_time : float = 3.0

@export var blood_burst_packed : PackedScene
@export var final_burst_packed : PackedScene

var dying : bool = false
var death_time : float
func _ready() -> void:
	MainMusicPlayer.fade_out()
	health.killed.connect(on_death)
	$AnimationPlayer.play("corrupt_heart")

func _process(delta: float) -> void:
	if dying:
		death_time += delta
		$Sprite3D.position.x = 0.1*sin(death_time*50)

func on_death() -> void:
	dying = true
	$AnimationPlayer.play("death")
	
	# Remove encounter metadata so the encounter can end while animating
	remove_meta("encounter_object")
	
	##Steady stream of blood
	var blood_burst : GPUParticles3D = blood_burst_packed.instantiate()
	blood_burst.lifetime = death_animation_time
	add_sibling(blood_burst)
	blood_burst.global_position = $BloodEmitCenter.global_position
	blood_burst.emitting = true
	
	
	var tween : Tween = get_tree().create_tween().set_parallel(true)
	
	tween.tween_property($Sprite3D,"scale", Vector3(0.85,0.85,0.85),death_animation_time).set_trans(Tween.TRANS_BOUNCE)
	
	await get_tree().create_timer(death_animation_time-$HeartSwishSound.stream.get_length()).timeout
	$HeartSwishSound.play()
	#await get_tree().create_timer(death_animation_time).timeout
	await $HeartSwishSound.finished
	
	##Final Burst of blood
	var final_burst : GPUParticles3D = final_burst_packed.instantiate()
	add_sibling(final_burst)
	final_burst.global_position = $BloodEmitCenter.global_position
	final_burst.emitting = true
	Player.instance.health_component.modify_max_health(2)
	queue_free()
	
