extends Node3D

@export var particle : PackedScene

func spawn() -> void:
	var new_particles : GPUParticles3D = particle.instantiate()
	add_child(new_particles)
	new_particles.global_position = global_position
	new_particles.emitting = true
