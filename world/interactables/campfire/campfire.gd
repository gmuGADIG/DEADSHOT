class_name Campfire
extends Interactable

const MUSIC_DUCK_VOLUME: float = 0.1
const MUSIC_DUCK_FADE_TIME: float = 0.75

var extinguish: bool = false ## Boolean if campfire is interacted with
var _player_inside: bool = false
var _previous_music_volume: float = 1.0
var _duck_target_volume: float = 1.0
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

		# extinguish campfire
		extinguish = true
		
		Save.save_data.object_save_data.add_campfire(self)
		%Sprite.play('extinguished')
		%Light.visible = false
		stop_ambience()
		_restore_music_volume()
			
	# open campfire menu
	var menu := preload("res://menu/campfire_menu/campfire_menu.tscn").instantiate()
	add_child(menu)
	await menu.tree_exited

func stop_ambience() -> void:
	var tween := create_tween()
	tween.tween_property(%CampfireAmbienceSound, "volume_linear", 0.0, 1.0)
	await tween.finished
	%CampfireAmbienceSound.stop()

func _refresh_player_overlap() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			_player_inside = true
			_apply_music_duck()
			return

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = true
	_apply_music_duck()

func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = false
	_restore_music_volume()

func _apply_music_duck() -> void:
	if extinguish:
		return
	
	_previous_music_volume = MainMusicPlayer.get_volume()
	_duck_target_volume = min(_previous_music_volume, MUSIC_DUCK_VOLUME)
	var should_duck := (_previous_music_volume - _duck_target_volume) > 0.001
	if not should_duck:
		_is_ducking_music = false
		return
	
	MainMusicPlayer.set_volume(_duck_target_volume, MUSIC_DUCK_FADE_TIME)
	_is_ducking_music = true

func _restore_music_volume() -> void:
	if not _is_ducking_music:
		return
	
	var current_volume: float = MainMusicPlayer.get_volume()
	if current_volume < _duck_target_volume - 0.01:
		_is_ducking_music = false
		return
	
	MainMusicPlayer.set_volume(_previous_music_volume, MUSIC_DUCK_FADE_TIME)
	_is_ducking_music = false
