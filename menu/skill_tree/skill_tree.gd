extends Control

@export var skill_buttons : Array[Skill_Button]

func _ready() -> void:
	for child in $SkillButtons.get_children():
		if child is Skill_Button:
			print("child")
			skill_buttons.append(child)
			child.update_purchase_state()
			child.purchase_made.connect(on_purchase_made)
	
	##This has to happen after all the purchase states are set
	for skill_button : Skill_Button in skill_buttons:
		skill_button.update_state()

func on_purchase_made() -> void:
	for skill_button : Skill_Button in skill_buttons:
		skill_button.update_state()
