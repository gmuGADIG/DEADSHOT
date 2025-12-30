extends TutorialPopup

func _process(delta: float) -> void:
	if visible == false:
		return
	#print(SkillSet.skill_bitfield)
	if not destroying_tutorial and SkillSet.skill_bitfield != 0:
		destroying_tutorial = true
		%CampfireBlocker.queue_free()
		$VanishSound.play()
		var tween : Tween = get_tree().create_tween()
		tween.set_parallel()
		tween.tween_property(%Sun,"rotation:x",deg_to_rad(-41.6),4.0)
		tween.tween_property(%Sun,"color",Color.WHITE,4.0)
		await tween.finished
	super._process(delta)
