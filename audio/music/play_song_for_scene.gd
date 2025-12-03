extends Node

@export var song_name: String

## Decides whether or not to reset the song playing, if the song currently 
## playing is the song specified by [member song_name].
@export var reset_song := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if reset_song or not MainMusicPlayer.is_song_name_playing(song_name):
		MainMusicPlayer.transition_to_song_by_filename(song_name)
