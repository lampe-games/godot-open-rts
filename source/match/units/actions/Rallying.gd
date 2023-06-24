extends "res://source/match/units/actions/Action.gd"


static func is_applicable(unit):
	return unit.find_child("RallyPoint") != null


static func _set_rally_point(unit, rally_point: Vector3):
	var rally_node = unit.find_child("RallyPoint")
	rally_node.global_position = rally_point
