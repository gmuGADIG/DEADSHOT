@tool
extends Path3D

func _ready() -> void:
	generate()

func _on_curve_changed() -> void:
	generate()

func _get_configuration_warnings() -> PackedStringArray:
	if curve == null: return ["Missing a curve. Press 'Create Curve' at the top."]
	if not is_on_plane(): return ["Points must fall on a plane."]
	else: return []

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
