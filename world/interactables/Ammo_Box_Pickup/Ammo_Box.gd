extends Area3D



@export var Num_Of_Ammo_In_Box: int
#@export var Num_Of_Ammo_In_Box: int
func _on_body_entered(body: Node3D) -> void:
	# player will pick up ammo when it collides
	if body is Player:
		Num_Of_Ammo_In_Box=randf_range(5,21)
		Player.instance.get_node(Player.gun_name).reserve_ammo+=Num_Of_Ammo_In_Box
		#print("Ammo Box Picked Up and got: ")
		#print(Num_Of_Ammo_In_Box)
		#print(Player.instance.get_node(Player.gun_name).reserve_ammo)
		
		print("Ammo Box Picked Up and got " + str(Num_Of_Ammo_In_Box)+" Ammo")
		print("You Have "+str(Player.instance.get_node(Player.gun_name).reserve_ammo)+" Ammo")
		
		queue_free()
