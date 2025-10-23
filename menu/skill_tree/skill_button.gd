extends TextureButton
class_name Skill_Button

@export var skillName:String
@export var description:String
@export var meatCost:int
@onready var Skill_Branch : Line2D = $Skill_Branch
@export var dependencies : Array[Skill_Button]
@export var itemDesc : Resource

func _ready() -> void:
	$Label.text = skillName
	# Fix this, make sure line goes in correct place
	for child in dependencies:
		Skill_Branch.add_point(self.global_position + self.size/2)
		Skill_Branch.add_point(child.global_position + child.size/2)


func _on_pressed() -> void:
	print(skillName)
	#if player level or prev skill is acheived, allow it, or deny it
