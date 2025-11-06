extends PanelContainer
class_name Skill_Popup

@export var skillName : String
@export_multiline var info : String

@onready var skillIcon : TextureRect = $VBoxContainer/TextureRect
@onready var skillInfo : Label = $VBoxContainer/Label
