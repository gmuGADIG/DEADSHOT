extends Resource
class_name PlayerData

@export var health := 100
@export var posX : float
@export var posY : float
@export var currentScene : String

func set_position(vec3 : Vector3) -> void:
	posX = vec3.x
	posY = vec3.z
	
func set_scene(sceneName : String) ->void:
	currentScene = sceneName
