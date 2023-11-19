extends Node3D

const SIGHT_COMPENSATION = 2.0  # compensates for blurry edges of FoW

const Structure = preload("res://source/match/units/Structure.gd")

var _units_processed_at_least_once = {}
var _structure_to_dummy_mapping = {}
var _orphaned_dummies = []


func _ready():
	MatchSignals.unit_spawned.connect(_recalculate_unit_visibility)
	MatchSignals.unit_died.connect(_on_unit_died)


func _physics_process(_delta):
	var all_units = get_tree().get_nodes_in_group("units")
	var revealed_units = all_units.filter(func(unit): return unit.is_in_group("revealed_units"))
	for unit in all_units:
		_recalculate_unit_visibility(unit, revealed_units)
	for orphaned_dummy in _orphaned_dummies:
		_recalcuate_orphaned_dummy_existence(orphaned_dummy, revealed_units)


func _is_disabled():
	return not visible


func _recalculate_unit_visibility(unit, revealed_units = null):
	if unit.is_in_group("revealed_units") or _is_disabled():
		_update_unit_visibility(unit, true)
		return

	var should_be_visible = false
	if revealed_units == null:
		revealed_units = get_tree().get_nodes_in_group("units").filter(
			func(a_unit): return a_unit.is_in_group("revealed_units")
		)
	for revealed_unit in revealed_units:
		if (
			revealed_unit.is_revealing()
			and revealed_unit.sight_range != null
			and (
				(revealed_unit.global_position * Vector3(1, 0, 1)).distance_to(
					unit.global_position * Vector3(1, 0, 1)
				)
				<= revealed_unit.sight_range + SIGHT_COMPENSATION
			)
		):
			should_be_visible = true
			break
	_update_unit_visibility(unit, should_be_visible)


func _update_unit_visibility(unit, should_be_visible):
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


func _recalcuate_orphaned_dummy_existence(orphaned_dummy, revealed_units = null):
	var should_exist = true
	if revealed_units == null:
		revealed_units = get_tree().get_nodes_in_group("units").filter(
			func(unit): return unit.is_in_group("revealed_units")
		)
	for revealed_unit in revealed_units:
		if (
			revealed_unit.is_revealing()
			and revealed_unit.sight_range != null
			and (
				(revealed_unit.global_position * Vector3(1, 0, 1)).distance_to(
					orphaned_dummy.global_position * Vector3(1, 0, 1)
				)
				<= revealed_unit.sight_range + SIGHT_COMPENSATION
			)
		):
			should_exist = false
			break
	if not should_exist:
		_orphaned_dummies.erase(orphaned_dummy)
		orphaned_dummy.queue_free()


func _on_unit_died(unit):
	_units_processed_at_least_once.erase(unit)
	if unit in _structure_to_dummy_mapping:
		var orphaned_dummy = _structure_to_dummy_mapping[unit]
		_structure_to_dummy_mapping.erase(unit)
		_orphaned_dummies.append(orphaned_dummy)
		_recalcuate_orphaned_dummy_existence(orphaned_dummy)
