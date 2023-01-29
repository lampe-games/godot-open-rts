extends Node


class Actions:
	const Moving = preload("res://source/match/units/actions/Moving.gd")
	const CollectingResources = preload("res://source/match/units/actions/CollectingResources.gd")
	const AutoAttacking = preload("res://source/match/units/actions/AutoAttacking.gd")


func _ready():
	MatchSignals.terrain_targeted.connect(_on_terrain_targeted)
	MatchSignals.unit_targeted.connect(_on_unit_targeted)


func _navigate_selected_units_towards_position(target_point):
	var terrain_units_to_move = get_tree().get_nodes_in_group("selected_units").filter(
		func(unit): return (
			unit.is_in_group("controlled_units")
			and unit.movement_domain == Constants.Match.Navigation.Domain.TERRAIN
			and Actions.Moving.is_applicable(unit)
		)
	)
	var air_units_to_move = get_tree().get_nodes_in_group("selected_units").filter(
		func(unit): return (
			unit.is_in_group("controlled_units")
			and unit.movement_domain == Constants.Match.Navigation.Domain.AIR
			and Actions.Moving.is_applicable(unit)
		)
	)
	var new_unit_targets = Utils.Match.Unit.Movement.crowd_moved_to_new_pivot(
		terrain_units_to_move, target_point
	)
	new_unit_targets += Utils.Match.Unit.Movement.crowd_moved_to_new_pivot(
		air_units_to_move, target_point
	)
	for tuple in new_unit_targets:
		var unit = tuple[0]
		var new_target = tuple[1]
		unit.action = Actions.Moving.new(new_target)


func _navigate_selected_units_towards_unit(target_unit):
	for unit in get_tree().get_nodes_in_group("selected_units"):
		if not unit.is_in_group("controlled_units"):
			continue
		if Actions.CollectingResources.is_applicable(unit, target_unit):
			unit.action = Actions.CollectingResources.new(target_unit)
		elif Actions.AutoAttacking.is_applicable(unit, target_unit):
			unit.action = Actions.AutoAttacking.new(target_unit)
		else:
			unit.action = null


func _on_terrain_targeted(position):
	_navigate_selected_units_towards_position(position)


func _on_unit_targeted(unit):
	_navigate_selected_units_towards_unit(unit)
