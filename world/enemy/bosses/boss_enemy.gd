class_name BossEnemy extends EnemyBase

#region Variables
@export var phase_1_action_names : Array[StringName]
@export var phase_2_action_names : Array[StringName] ## Might end up unused

@export var action_player : AnimationPlayer


var last_action : StringName
#endregion

#region Behaviour Functions
func _ready() -> void:
	super._ready()
	pick_action()

func pick_action() -> void: ##TODO: Override this
	pass
	
func action_finished(anim_name: StringName) -> void:
	last_action = anim_name
	pick_action()

func hostile() -> void:
	pass

func attack() -> void:
	pass
	
func death() -> void:
	# save that this enemy died
	
	# drop stuff
	drop_tonic()
	if spawn_on_killed != null:
		var spawn := spawn_on_killed.instantiate()
		add_sibling(spawn)
		spawn.global_position = global_position
		
	var die_sound := $BossDeathSound
	if die_sound:
		die_sound.reparent(get_tree().current_scene)
		die_sound.play()
	
	# free
	queue_free()

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	pass #Override base enemy behavior
#endregion
