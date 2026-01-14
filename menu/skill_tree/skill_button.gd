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


@export var dependencies : Array[Skill_Button]
@export var evil_dependencies : Array[Skill_Button] #it is just the opposite of regular dependecies,
# so if you have any of the dependencies unlocked you cant unlock this one
@export var itemDesc : SkillDesc

var state : State:
	set(new_val):
		state = new_val
		
		match state:
			State.UNSET:
				modulate = Color(1,0,0)
			State.PURCHASED:
				modulate = Color(1,1,1)
				%SkillBranches.modulate = Color(1,1,1)
				%SkillBranches.show()
			State.AFFORDABLE:
				modulate = Color(1,1,1)
				%SkillBranches.modulate = Color(0.5,0.5,0.5)
				%SkillBranches.show()
				$TextureRect.texture = itemDesc.skill_image
			State.UNAFFORDABLE:
				modulate = Color(0.5,0.5,0.5)
				%SkillBranches.modulate = Color(0.5,0.5,0.5)
				%SkillBranches.show()
				$TextureRect.texture = itemDesc.skill_image
			State.LOCKED:
				modulate = Color(0.35, 0.35, 0.35)
				%SkillBranches.hide()
				$TextureRect.texture = itemDesc.skill_image

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	update_purchase_state()
	$TextureRect.texture = itemDesc.skill_image
	
	# set board texture (circle = 1 icon, square = 2 icons)
	var board := (
		preload("res://menu/skill_tree/skill_tree_icons/board_square.png")
		if itemDesc.square_icon
		else preload("res://menu/skill_tree/skill_tree_icons/board_circle.png")
	)
	texture_normal = board
	texture_disabled = board
	
	# Fix this, make sure line goes in correct place
	for child in dependencies:
		var line := Line2D.new()
		line.texture = preload("res://menu/skill_tree/skill_tree_icons/board_connector.png")
		line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
		line.add_point(Vector2.ZERO)
		line.add_point(child.global_position - self.global_position)
		%SkillBranches.add_child(line)

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
	
func _on_pressed() -> void:
	if Engine.is_editor_hint(): return
	if Input.is_action_pressed("quick_purchase"):
		attempt_purchase()
	else:
		indent()
		skill_pressed.emit(self)
	
			
	#if player level or prev skill is acheived, allow it, or deny it

# Returns whether the purchase was a success
func attempt_purchase() -> bool:
	match state:
		State.AFFORDABLE:
			purchase()
			indent()
			return true
		State.UNAFFORDABLE, State.LOCKED:
			shake()
		State.PURCHASED:
			indent()
	return false

func purchase() -> void:
	# Purchase
	Global.meat_currency -= itemDesc.skill_meat_cost
	state = State.PURCHASED
	purchase_made.emit(itemDesc.skill_uid)
	
	# Visuals
	$TextureRect.texture = itemDesc.skill_image_upgraded
	%PurchaseParticles.emitting = true
	
	# Dialogue
	play_dialogue()

func play_dialogue() -> void:
	if itemDesc.purchase_timeline != null:
		Dialog.play(itemDesc.purchase_timeline)
	else:
		const generic_timelines: Array[String] = [
			"res://writing/upgrades/upgrade_generic_1.tres",
			"res://writing/upgrades/upgrade_generic_2.tres",
			"res://writing/upgrades/upgrade_generic_3.tres",
			"res://writing/upgrades/upgrade_generic_4.tres",
			"res://writing/upgrades/upgrade_generic_5.tres",
		]
		var timeline: DialogTimeline = load(generic_timelines.pick_random())
		Dialog.play(timeline)

func indent() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self,"scale",Vector2(0.9,0.9), 0.07)
	tween.tween_property(self,"scale",Vector2(1,1), 0.07)
	
func shake() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self,"rotation_degrees",10, 0.07)
	tween.tween_property(self,"rotation_degrees",-10, 0.07)
	tween.tween_property(self,"rotation_degrees",0, 0.07)
