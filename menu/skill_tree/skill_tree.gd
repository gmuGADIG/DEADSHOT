extends Control

@export var skill_buttons : Array[Skill_Button]

@export var zoom_strength : float = 6
@export var zoom_offset : Vector2
@export var zoom_time : float = 0.3
var selected_skill_button : Skill_Button = null

func _ready() -> void:
	for child in $SkillButtons.get_children():
		if child is Skill_Button:
			print("child")
			skill_buttons.append(child)
			child.update_purchase_state()
			child.skill_pressed.connect(on_skill_pressed)
			child.purchase_made.connect(on_skill_purchased)
	
	##This has to happen after all the purchase states are set
	update_state()

func on_skill_pressed(skill_button : Skill_Button) -> void:
	if selected_skill_button != null:
		return
	selected_skill_button = skill_button
	$Overlay.show_skill_panel(skill_button.itemDesc)
	
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self,"scale",Vector2(zoom_strength,zoom_strength),zoom_time)
	tween.parallel().tween_property(self,"position",-zoom_strength*(skill_button.global_position+zoom_offset),zoom_time)
	#for skill_button : Skill_Button in skill_buttons:
		#skill_button.update_state()


func _on_purchase_pressed() -> void:
	selected_skill_button.attempt_purchase()


func on_skill_unselected() -> void:
	if selected_skill_button == null:
		return
	selected_skill_button = null
	$Overlay.hide_skill_panel()
	
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self,"scale",Vector2(1,1),zoom_time)
	tween.parallel().tween_property(self,"position",Vector2.ZERO,zoom_time)

func on_skill_purchased(skill : SkillSet.SkillUID) -> void:
	SkillSet.add_skill(skill)
	update_state()
	on_skill_unselected()

func update_state() -> void:
	for skill_button : Skill_Button in skill_buttons:
		skill_button.update_state()
