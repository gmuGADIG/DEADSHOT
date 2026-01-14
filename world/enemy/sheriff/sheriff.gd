class_name Sheriff
extends Wilder

#enum SelectedAttack{
	#WHIP,
	#STAR
#}

@export var barrage_time : float
@export var star : PackedScene
@export var slash : PackedScene

#var selected_attack : SelectedAttack = SelectedAttack.STAR

func _ready() -> void:
	super._ready()
	$FiringTimerREAL.timeout.connect(func() -> void:
		if aggro != AggroState.ATTACKING:
			barrage()
	)
	$FiringTimerREAL.start(barrage_time)
	
#func pick_target(flee : bool) -> void:
	#if not flee:
		#barrage()
	#super.pick_target(flee)

func fire() -> void:
	shoot_star()
	switch_state(AggroState.BENIGN)
	
func shoot_star() -> void:
	var new_star : = star.instantiate()
	new_star.atk_source = DamageInfo.Source.ENEMY
	add_sibling(new_star)
	new_star.fire(self, getPlayerDirection())

func do_slash() -> void:
	var new_slash : = slash.instantiate()
	new_slash.atk_source = DamageInfo.Source.ENEMY
	add_sibling(new_slash)
	new_slash.fire(self, getPlayerDirection())
	pass
