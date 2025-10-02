class_name DamageComponent extends Node

enum Source{
	PLAYER,
	ENEMY,
	NEUTRAL
}

@export var damage : int
@export var source : Source
@export var knockback : float
@export var stun_time : float
