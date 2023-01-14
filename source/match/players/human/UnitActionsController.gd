extends Node


class Actions:
	const Moving = preload("res://source/match/units/actions/Moving.gd")
	const CollectingResources = preload("res://source/match/units/actions/CollectingResources.gd")


func _ready():
	MatchSignals.terrain_targeted.connect(_on_terrain_targeted)
	MatchSignals.unit_targeted.connect(_on_unit_targeted)


func _on_terrain_targeted(position):
	_navigate_selected_units_towards_position(position)


func _on_unit_targeted(unit):
	_navigate_selected_units_towards_unit(unit)


func _navigate_selected_units_towards_position(target_point):
	for unit in get_tree().get_nodes_in_group("selected_units"):
		if unit.is_in_group("controlled_units") and Actions.Moving.is_applicable(unit):
			unit.action = Actions.Moving.new(target_point)


func _navigate_selected_units_towards_unit(target_unit):
	for unit in get_tree().get_nodes_in_group("selected_units"):
		if not unit.is_in_group("controlled_units"):
			continue
		if Actions.CollectingResources.is_applicable(unit, target_unit):
			unit.action = Actions.CollectingResources.new(target_unit)
		else:
			unit.action = null
