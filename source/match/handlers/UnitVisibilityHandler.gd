extends Node3D

# TODO: re-use dummies: show/hide them instead of re-creating

const Structure = preload("res://source/match/units/Structure.gd")

var _units_processed_at_least_once = {}
var _structure_to_dummy_mapping = {}

# TODO: handle dummies properly when changing player visibility
#       -> dummies are not removed when created and switching player


func _ready():
	MatchSignals.unit_spawned.connect(_recalculate_unit_visibility)
	MatchSignals.unit_died.connect(_on_unit_died)


func _physics_process(_delta):
	var units_to_process = get_tree().get_nodes_in_group("units")

	var revealed_units = units_to_process.filter(
		func(unit): return unit.is_in_group("revealed_units")
	)
	for unit in revealed_units:
		unit.show()

	var non_revealed_units = units_to_process.filter(
		func(unit): return not unit.is_in_group("revealed_units")
	)
	# TODO: check the performance of this O(N^2) algorithm vs the reading of FoW texture
	for unit in non_revealed_units:
		_recalculate_unit_visibility(unit, revealed_units)


func _recalculate_unit_visibility(unit, revealed_units = null):
	if unit.is_in_group("revealed_units"):
		unit.show()
		_units_processed_at_least_once[unit] = true
		return
	var should_be_visible = false
	if revealed_units == null:
		revealed_units = get_tree().get_nodes_in_group("units").filter(
			func(unit): return unit.is_in_group("revealed_units")
		)
	for revealed_unit in revealed_units:
		if (
			revealed_unit.sight_range != null
			and (
				(revealed_unit.global_position * Vector3(1, 0, 1)).distance_to(
					unit.global_position * Vector3(1, 0, 1)
				)
				<= revealed_unit.sight_range
			)
		):
			should_be_visible = true
			break
	if (
		unit in _units_processed_at_least_once
		and unit is Structure
		and unit.visible != should_be_visible
	):
		if unit.visible:
			_create_dummy_structure(unit)
		else:
			_try_removing_dummy_structure(unit)
	unit.visible = should_be_visible
	_units_processed_at_least_once[unit] = true


func _create_dummy_structure(unit):
	if unit in _structure_to_dummy_mapping:
		return
	var dummy = unit.find_child("Geometry").duplicate()
	dummy.global_transform = unit.find_child("Geometry").global_transform
	add_child(dummy)
	_structure_to_dummy_mapping[unit] = dummy


func _try_removing_dummy_structure(unit):
	if unit in _structure_to_dummy_mapping:
		_structure_to_dummy_mapping[unit].queue_free()
		_structure_to_dummy_mapping.erase(unit)


func _on_unit_died(unit):
	_units_processed_at_least_once.erase(unit)
	_structure_to_dummy_mapping.erase(unit)
