@tool
extends TextureButton
class_name Skill_Button

signal skill_pressed(skill_info : SkillDesc, location : Vector2)
signal purchase_made(skill_uid : SkillSet.SkillUID)


enum State{
	UNSET,
	PURCHASED,
	AFFORDABLE,
	UNAFFORDABLE,
	LOCKED
}


@onready var skill_branch : Line2D = Line2D.new()
@export var dependencies : Array[Skill_Button]
@export var evil_dependencies : Array[Skill_Button] #it is just the opposite of regular dependecies,
# so if you have any of the dependencies unlocked you cant unlock this one
@export var itemDesc : SkillDesc

var state : State:
	set(new_val):
		state = new_val
		
		match state:
			State.UNSET:
				self_modulate = Color(1,0,0)
			State.PURCHASED:
				self_modulate = Color(1,1,1)
				skill_branch.default_color = Color(1,1,1)
				skill_branch.show()
				
				skill_branch.texture_mode = Line2D.LINE_TEXTURE_STRETCH
				skill_branch.texture = preload("res://menu/skill_tree/skill_tree_art/connectorplank1.png")
				skill_branch.width = 25
				$LockIcon.hide()
			State.AFFORDABLE:
				self_modulate = Color(1,1,1)
				skill_branch.default_color = Color(0.5,0.5,0.5)
				
				skill_branch.texture_mode = Line2D.LINE_TEXTURE_STRETCH
				skill_branch.texture = preload("res://menu/skill_tree/skill_tree_art/connectorplank1.png")
				skill_branch.width = 25
				
				skill_branch.show()
				$LockIcon.hide()
			State.UNAFFORDABLE:
				self_modulate = Color(0.5,0.5,0.5)
				skill_branch.default_color = Color(0.5,0.5,0.5)
				skill_branch.show()
				$LockIcon.hide()
			State.LOCKED:
				self_modulate = Color(0.5,0.5,0.5)
				skill_branch.hide()
				$LockIcon.show()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	%SkillBranches.add_child(skill_branch)
	#setup_popup()
	update_purchase_state()
	$Label.text = itemDesc.skill_name
	$TextureRect.texture = itemDesc.skill_image
	# Fix this, make sure line goes in correct place
	for child in dependencies:
		skill_branch.add_point(self.global_position + self.size/2)
		skill_branch.add_point(child.global_position + child.size/2)

func update_purchase_state() -> void:
	if SkillSet.has_skill(itemDesc.skill_uid):
		state = State.PURCHASED
	else:
		state = State.UNSET

func update_state() -> void:
	if state == State.PURCHASED:
		return
	
	for evil_dependency : Skill_Button in evil_dependencies:
		if evil_dependency.state == State.PURCHASED:
			state = State.LOCKED
			shake()
			return
	
	for dependency : Skill_Button in dependencies:
		if dependency.state != State.PURCHASED:
			state = State.LOCKED
			return
	
	if Global.meat_currency >= itemDesc.skill_meat_cost:
		state = State.AFFORDABLE
	else:
		state = State.UNAFFORDABLE
	
func _process(_delta:float) -> void:
	if Engine.is_editor_hint():
		$Label.text = itemDesc.skill_name
		$TextureRect.texture = itemDesc.skill_image

func _on_pressed() -> void:
	if Engine.is_editor_hint(): return
	if Input.is_action_pressed("quick_purchase"):
		attempt_purchase()
	else:
		indent()
		skill_pressed.emit(self)
	
			
	#if player level or prev skill is acheived, allow it, or deny it

func attempt_purchase() -> void:
	match state:
		State.AFFORDABLE:
			purchase()
			indent()
		State.UNAFFORDABLE, State.LOCKED:
			shake()
		State.PURCHASED:
			indent()

func purchase() -> void:
	##TODO: GRANT SKILL
	print(itemDesc.skill_name)
	Global.meat_currency -= itemDesc.skill_meat_cost
	state = State.PURCHASED
	purchase_made.emit(itemDesc.skill_uid)

func indent() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self,"scale",Vector2(0.9,0.9), 0.07)
	tween.tween_property(self,"scale",Vector2(1,1), 0.07)
	
func shake() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self,"rotation_degrees",10, 0.07)
	tween.tween_property(self,"rotation_degrees",-10, 0.07)
	tween.tween_property(self,"rotation_degrees",0, 0.07)

#func setup_popup() -> void:
	#$Skill_Popup/VBoxContainer/Name.text = itemDesc.skill_name
	#$Skill_Popup/VBoxContainer/Description.text = itemDesc.skill_description
	#$Skill_Popup/VBoxContainer/TextureRect.texture = itemDesc.skill_image
