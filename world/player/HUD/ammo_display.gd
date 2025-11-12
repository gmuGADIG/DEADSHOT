extends Control

var current_ammo := 0
var current_reserve := 0

func _ready() -> void:
	Global.player_ammo_changed.connect(_on_ammo_changed)
	Global.player_ammo_reserve_changed.connect(_on_ammo_reserve_changed)

func _on_ammo_changed(ammo: int) -> void:
	current_ammo = ammo
	display_ammo()
	
func _on_ammo_reserve_changed(reserve: int) -> void:
	current_reserve = reserve
	display_ammo()
	
func display_ammo() -> void:
	%AmmoLabel.text = "%d / %d" % [current_ammo, current_reserve]
