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
	var selected_controlled_units = []
	for unit in get_tree().get_nodes_in_group("selected_units"):
		if unit.is_in_group("controlled_units") and Actions.Moving.is_applicable(unit):
			selected_controlled_units.append(unit)
	var new_unit_targets = Utils.Match.Unit.Movement.crowd_moved_to_new_pivot(
		selected_controlled_units, target_point
	)
	for tuple in new_unit_targets:
		var unit = tuple[0]
		var new_target = tuple[1]
		unit.action = Actions.Moving.new(new_target)
	# # 	if unit.movement.is_movable():
	# # 		StageSignals.emit_signal("set_unit_action", unit, UnitActions.Movement.new(new_target))
	# for unit in get_tree().get_nodes_in_group("selected_units"):
	# 	if unit.is_in_group("controlled_units") and Actions.Moving.is_applicable(unit):
	# 		unit.action = Actions.Moving.new(target_point)


func _navigate_selected_units_towards_unit(target_unit):
	for unit in get_tree().get_nodes_in_group("selected_units"):
		if not unit.is_in_group("controlled_units"):
			continue
		if Actions.CollectingResources.is_applicable(unit, target_unit):
			unit.action = Actions.CollectingResources.new(target_unit)
		else:
			unit.action = null
