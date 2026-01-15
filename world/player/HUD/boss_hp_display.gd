extends Control

func _ready() -> void:
	Global.boss_spawned.connect(_on_boss_spawned)

func _process(delta: float) -> void:
	# Set chains
	%Chain1.set_point_position(1, %Marker1.global_position - %Chain1.global_position)
	%Chain2.set_point_position(1, %Marker2.global_position - %Chain2.global_position)
	
	# Set health decay bar
	%HealthDecay.value = max(%HealthBar.value, %HealthDecay.value - .1 * delta)

func _on_boss_spawned(boss: EnemyBase) -> void:
	%Anim.play("show")
	_set_hp(1.0)
	
	boss.health.damaged.connect(func() -> void:
		_set_hp(boss.health.health / boss.health.max_health)
	)
	
	boss.health.killed.connect(_on_boss_killed)

func _on_boss_killed() -> void:
	%Anim.play("hide")

func _set_hp(hp_ratio: float) -> void:
	%HealthBar.value = hp_ratio
