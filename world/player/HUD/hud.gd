extends Control

# This is the HUD. It will eventually tell the player everything about:
# - HP (Hearts)
# - Ammo
# - Stamina
# - Boss health bars
# It's a child of the Player so that it can quickly update the HUD. 
# For getting non-players to talk to the HUD, give the non-player object a signal and connect it to the HUD.

## The stamina bar itself, which Player tells the stamina value.
@onready var stamina_bar: ProgressBar = $StaminaContainer/ProgressBar
## The stamina bar's parent that fades in and out.
@onready var stamina_container: PanelContainer = $StaminaContainer
## The container for the Ammo tracker.
@onready var ammo_container: PanelContainer = $AmmoContainer
## The ammo tracker text label.
@onready var ammo_label: RichTextLabel = $AmmoContainer/Label

var _in_combat := false:
	set(value):
		if value == _in_combat: return # no change
		_in_combat = value
		
		if _in_combat: fade_stamina_in()
		else: fade_stamina_out()

func _ready() -> void:
	# Stamina bar is hidden by default until player enters a Combat Encounter.
	stamina_container.modulate.a = 0.0

func _process(_delta: float) -> void:
	_in_combat = Encounter.is_encounter_active()

func fade_stamina_out() -> void:
	print("Hud out")
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(stamina_container, "modulate:a", 0.0, 0.1)

func fade_stamina_in() -> void:
	print("Hud in")
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(stamina_container, "modulate:a", 1.0, 0.1)

## Updates the stamina bar with the given amount.
func update_stamina_bar(amount: float) -> void:
	stamina_bar.value = amount

## Replaces the ammo label text in the HUD with the given string. 
func update_ammo_text(text: String) -> void:
	ammo_label.text = text;
