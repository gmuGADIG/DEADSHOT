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
var player: Player

var _in_combat := false:
	set(value):
		if value == _in_combat: return # no change
		_in_combat = value
		
		if _in_combat: player.enter_combat()
		else: player.exit_combat()

func _ready() -> void:
	player =  get_tree().get_first_node_in_group("player")
	print("LOOK HERE: " + player.to_string())
	# Stamina bar is hidden by default until player enters a Combat Encounter.
	$StaminaContainer.modulate.a = 0.0

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

func update_stamina_bar(amount: float) -> void:
	stamina_bar.value = amount
