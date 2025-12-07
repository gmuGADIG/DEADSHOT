class_name Campfire
extends Interactable

const MUSIC_DUCK_VOLUME: float = 0.5
const MUSIC_DUCK_FADE_TIME: float = 0.75

var extinguish: bool = false ## Boolean if campfire is interacted with
var _previous_music_volume: float = 1.0
var _is_ducking_music: bool = false

func _ready() -> void:
	if Save.save_data.object_save_data.has_campfire(self):
		extinguish = true # Extinguishes campfire
		%Sprite.play('extinguished')
		%Light.visible = false
		%CampfireAmbienceSound.stop()
	else:
		%Sprite.play('lit')
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	call_deferred("_refresh_player_overlap")

func interact()->void:
	if CampfireMenu.instance != null:
		return # menu's already open; ignore
	
	if not extinguish:
		# save game and heal player to max hp
		Save.save_game()
		Player.instance.health_component.heal(Player.instance.health_component.max_health)
		Save.save_data.object_save_data.add_campfire(self)
			
	# open campfire menu
	var menu := preload("res://menu/campfire_menu/campfire_menu.tscn").instantiate()
	add_child(menu)
	await menu.tree_exited
	
	# extinguish after the menu closes
	if not extinguish:
		extinguish = true
		%Sprite.play('extinguished')
		%Light.visible = false
		stop_ambience()
		_restore_music_volume()

func stop_ambience() -> void:
	var tween := create_tween()
	tween.tween_property(%CampfireAmbienceSound, "volume_linear", 0.0, 1.0)
	await tween.finished
	%CampfireAmbienceSound.stop()

func _refresh_player_overlap() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			_apply_music_duck()
			return

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_apply_music_duck()

func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_restore_music_volume()

func _apply_music_duck() -> void:
	if extinguish:
		return
	
	var current_volume: float = MainMusicPlayer.get_loudness()
	if current_volume <= MUSIC_DUCK_VOLUME + 0.001:
		_is_ducking_music = false
		return
	
	_previous_music_volume = MainMusicPlayer.get_loudness()
	MainMusicPlayer.set_loudness(MUSIC_DUCK_VOLUME, MUSIC_DUCK_FADE_TIME)
	_is_ducking_music = true

func _restore_music_volume() -> void:
	if not _is_ducking_music:
		return
	
	MainMusicPlayer.set_loudness(_previous_music_volume, MUSIC_DUCK_FADE_TIME)
	_is_ducking_music = false
