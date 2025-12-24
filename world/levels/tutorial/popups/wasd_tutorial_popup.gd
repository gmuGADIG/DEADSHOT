extends TutorialPopup

func _process(delta: float) -> void:
	if visible == false:
		return
	if not destroying_tutorial and not Player.instance.velocity.is_zero_approx():
		destroying_tutorial = true
		$VanishSound.play()
	super._process(delta)
