extends Node3D

@export var npcs: Array[NPC]

func exclaiminate() -> void:
	for npc: NPC in npcs:
		npc.show_exclamation()
