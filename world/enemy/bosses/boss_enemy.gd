class_name BossEnemy extends EnemyBase

#region Variables
@export var phase_1_action_names : Array[StringName]
@export var phase_2_action_names : Array[StringName] ## Might end up unused

@export var action_player : AnimationPlayer
#endregion

#region Behaviour Functions
func _ready() -> void:
	super._ready()
	pick_action()

func pick_action() -> void: ##TODO: Override this
	pass
	
func action_finished(anim_name: StringName) -> void:
	pick_action()

func hostile() -> void:
	pass

func attack() -> void:
	pass

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	pass #Override base enemy behavior
#endregion
