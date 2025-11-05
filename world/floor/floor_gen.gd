@tool
extends Path3D

@export var material: FloorMaterial:
	set(value):
		material = value
		update_material()

func _ready() -> void:
	generate()
	update_material()

func _on_curve_changed() -> void:
	generate()

func _get_configuration_warnings() -> PackedStringArray:
	if curve == null: return ["Missing a curve. Press 'Create Curve' at the top."]
	if not is_on_plane(): return ["Points must fall on a plane."]
	else: return []

func update_material() -> void:
	if not is_node_ready(): return
	
	var edge_mat: StandardMaterial3D = %Trim.material
	var fill_mat: StandardMaterial3D = %Floor.material
	
	if material == null:
		edge_mat.albedo_texture = null
		edge_mat.normal_texture = null
		fill_mat.albedo_texture = null
		fill_mat.normal_texture = null
	else:
		edge_mat.albedo_texture = material.edge
		edge_mat.normal_texture = material.edge_normal
		fill_mat.albedo_texture = material.fill
		fill_mat.normal_texture = material.fill_normal
		
	

func generate() -> void:
	if curve == null:
		%Floor.polygon = PackedVector2Array()
		return
		
	
	update_configuration_warnings()
	
	#- Generate Floor -#
	var polygon: PackedVector2Array = %Floor.polygon
	var curve_points := curve.get_baked_points()
	polygon.resize(curve_points.size())
	for i in range(curve_points.size()):
		var point := curve_points[i]
		polygon[i] = Vector2(point.x, -point.z)
	%Floor.polygon = polygon

func is_on_plane() -> bool:
	for i in range(curve.point_count):
		var point := curve.get_point_position(i)
		if point.y != 0: return false
	return true
