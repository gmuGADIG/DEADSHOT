## Apply this script to an Area3D, with the layer set to Interactable.
## Implement the `interact() -> void` function.
@abstract
extends Area3D
class_name Interactable 

# these aren't implemented
#func focus() -> void
#func unfocus() -> void

@abstract
func interact() -> void
