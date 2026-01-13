extends EnemyBase

func _ready() -> void:
	super._ready()

	%Health.killed.connect(func() -> void:
		var sfx := %JudgeDeath
		sfx.reparent(get_tree().current_scene)
		sfx.play()
	)

var reload_sound_played := false
func _process(_delta: float) -> void:
	if firing_timer.time_left > 1.0:
		reload_sound_played = false
	elif not reload_sound_played:
		%JudgeReload.play()
		reload_sound_played = true

func hostile() -> void:
	set_movement_target(player.global_position);
	should_move = not is_close_to_destination();

func attack() -> void:
	pass

func shoot_bullet() -> void:
	%JudgeShoot.play()
	var dir := global_position.direction_to(player.global_position)
	var num_bullets: int = 3
	var angle: float = TAU / 8.
	for i in num_bullets:
		var di: int = i - (num_bullets / 2)
		var theta: float = (angle / num_bullets) * di
		var new_dir := dir.rotated(Vector3.UP, theta)

		var bullet_reference: Node3D = load("res://world/enemy/Enemy Bullets/enemy_bullet.tscn").instantiate()
		add_sibling(bullet_reference)
		bullet_reference.set_speed(bullet_speed)
		bullet_reference.velocity = new_dir * bullet_speed
		bullet_reference.global_position = global_position + new_dir

func _on_firing_timer_timeout() -> void:
	enemy_fired.emit()
	shoot_bullet()
	await get_tree().create_timer(0.15, false).timeout
	shoot_bullet()
