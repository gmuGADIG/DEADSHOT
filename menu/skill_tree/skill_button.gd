extends TextureButton
class_name Skill_Button

signal purchase_made

enum State{
	UNSET,
	PURCHASED,
	AFFORDABLE,
	UNAFFORDABLE,
	LOCKED
}

@export var skillName:String
@export var description:String
@export var meatCost:int
@onready var Skill_Branch : Line2D = $Skill_Branch
@export var dependencies : Array[Skill_Button]
@export var itemDesc : Resource

var state : State:
	set(new_val):
		state = new_val
		
		match state:
			State.UNSET:
				self_modulate = Color(1,0,0)
			State.PURCHASED:
				self_modulate = Color(1,1,1)
				$Skill_Branch.default_color = Color(1,1,1)
				$Skill_Branch.show()
				$LockIcon.hide()
			State.AFFORDABLE:
				self_modulate = Color(1,1,1)
				$Skill_Branch.default_color = Color(0.5,0.5,0.5)
				$Skill_Branch.show()
				$LockIcon.hide()
			State.UNAFFORDABLE:
				self_modulate = Color(0.5,0.5,0.5)
				$Skill_Branch.default_color = Color(0.5,0.5,0.5)
				$Skill_Branch.show()
				$LockIcon.hide()
			State.LOCKED:
				self_modulate = Color(0.5,0.5,0.5)
				$Skill_Branch.hide()
				$LockIcon.show()

func _ready() -> void:
	update_purchase_state()
	
	$Label.text = skillName
	# Fix this, make sure line goes in correct place
	for child in dependencies:
		Skill_Branch.add_point(self.global_position + self.size/2)
		Skill_Branch.add_point(child.global_position + child.size/2)

func update_purchase_state() -> void:
	if Player.has_skill():
		state = State.PURCHASED
	else:
		state = State.UNSET

func update_state() -> void:
	if state == State.PURCHASED:
		return
	
	for dependency : Skill_Button in dependencies:
		if dependency.state != State.PURCHASED:
			state = State.LOCKED
			return
	
	if Global.meat_currency >= meatCost:
		state = State.AFFORDABLE
	else:
		state = State.UNAFFORDABLE
	

func _on_pressed() -> void:
	match state:
		State.AFFORDABLE:
			purchase()
			indent()
		State.UNAFFORDABLE, State.LOCKED:
			shake()
		State.PURCHASED:
			indent()
			
	#if player level or prev skill is acheived, allow it, or deny it

func purchase() -> void:
	##TODO: GRANT SKILL
	print(skillName)
	Global.meat_currency -= meatCost
	state = State.PURCHASED
	purchase_made.emit()

func indent() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self,"scale",Vector2(0.9,0.9), 0.07)
	tween.tween_property(self,"scale",Vector2(1,1), 0.07)
	
func shake() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self,"rotation_degrees",10, 0.07)
	tween.tween_property(self,"rotation_degrees",-10, 0.07)
	tween.tween_property(self,"rotation_degrees",0, 0.07)
