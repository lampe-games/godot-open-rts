extends Node3D

var _set_action_names = [null]
var _get_action_names = [null]
var _unit_group_names = [null]


func _ready():
	for group_id in range(1, 10):
		_set_action_names.append("unit_groups_set_{0}".format([group_id]))
		_get_action_names.append("unit_groups_access_{0}".format([group_id]))
		_unit_group_names.append("unit_group_{0}".format([group_id]))


func _input(event):
	for group_id in range(1, 10):
		if event.is_action_pressed(_set_action_names[group_id]):
			set_group(group_id)
			return
		if event.is_action_pressed(_get_action_names[group_id]):
			access_group(group_id)
			return


func access_group(group_id: int):
	var units_in_group = Utils.Set.from_array(
		get_tree().get_nodes_in_group(_unit_group_names[group_id])
	)
	Utils.Match.select_units(units_in_group)


func set_group(group_id: int):
	for unit in get_tree().get_nodes_in_group(_unit_group_names[group_id]):
		unit.remove_from_group(_unit_group_names[group_id])
	for unit in get_tree().get_nodes_in_group("selected_units"):
		if unit.is_in_group("controlled_units"):
			unit.add_to_group(_unit_group_names[group_id])
