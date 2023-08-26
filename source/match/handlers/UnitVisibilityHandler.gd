extends Node3D

# TODO: recalculate visibility of new units as they are created to remove "blink" effect


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
		var should_be_visible = false
		for revealed_unit in revealed_units:
			if (
				(revealed_unit.global_position * Vector3(1, 0, 1)).distance_to(
					unit.global_position * Vector3(1, 0, 1)
				)
				<= revealed_unit.sight_range
			):
				should_be_visible = true
				break
		unit.visible = should_be_visible
