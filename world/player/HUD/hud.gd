extends Control

# This is the HUD. It will eventually tell the player everything about:
# - HP (Hearts)
# - Ammo
# - Stamina
# - Boss health bars
# It's a child of the Player so that it can quickly update the HUD. 
# For getting non-players to talk to the HUD, give the non-player object a signal and connect it to the HUD.

@export var stamina_bar: ProgressBar ## The stamina bar itself, which Player tells the stamina value.
@export var stamina_container: PanelContainer ## The stamina bar's parent that fades in and out.

func _ready() -> void:
	# Stamina bar is hidden by default until player enters a Combat Encounter.
	$StaminaContainer.modulate.a = 0.0

func fade_stamina_out() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(stamina_container, "modulate:a", 0.0, 0.1)

func fade_stamina_in() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(stamina_container, "modulate:a", 1.0, 0.1)

func update_stamina_bar(amount: float) -> void:
	stamina_bar.value = amount
