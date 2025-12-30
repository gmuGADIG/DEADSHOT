@tool
extends Path3D

@export_tool_button("Update") var update_button := generate
@export var auto_update := true
@export var curve_interval := 2.0 ## Higher number = lower resolution edges and better performance

@export var material: FloorMaterial:
	set(value):
		material = value
		update_material()

func _ready() -> void:
	generate()
	update_material()

func _on_curve_changed() -> void:
	if auto_update: generate()

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
		edge_mat.uv1_scale.y = material.edge_scale
		edge_mat.uv1_offset.y = material.edge_offset
		edge_mat.albedo_texture = material.edge
		edge_mat.normal_texture = material.edge_normal
		fill_mat.albedo_texture = material.fill
		fill_mat.normal_texture = material.fill_normal

func flatten() -> void:
	for i in range(curve.point_count):
		var point := curve.get_point_position(i)
		if point.y != 0:
			curve.set_point_position(i, Vector3(point.x, 0, point.z))

func generate() -> void:
	if curve == null:
		%Floor.polygon = PackedVector2Array()
		return
	
	flatten()
	
	if curve.bake_interval != curve_interval: # necessary check to avoid recomputing points
		curve.bake_interval = curve_interval
		
	#- Generate Floor -#
	var polygon: PackedVector2Array = %Floor.polygon
	var curve_points := curve.get_baked_points()
	polygon.resize(curve_points.size())
	for i in range(curve_points.size()):
		var point := curve_points[i]
		polygon[i] = Vector2(point.x, -point.z)
	%Floor.polygon = polygon
