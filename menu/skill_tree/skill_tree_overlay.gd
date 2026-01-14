extends CanvasLayer

func _ready() -> void:
	Global.meat_changed.connect(update_meat_display)
	update_meat_display()

func update_meat_display() -> void:
	$MeatDisplay/HBoxContainer/OwnedMeat.text = str(Global.meat_currency)

func show_skill_panel(skill : SkillDesc) -> void:
	$SkillPanel/VSplitContainer/Info/Name.text = skill.skill_name
	$SkillPanel/VSplitContainer/Info/HBoxContainer/Price.text = str(skill.skill_meat_cost)
	$SkillPanel/VSplitContainer/Info/Description.text = skill.skill_description
	$SkillPanel.show()
	%Anim.play("show_panel")
	
func hide_skill_panel() -> void:
	%Anim.play("hide_panel")
	await %Anim.animation_finished
	$SkillPanel.hide()
