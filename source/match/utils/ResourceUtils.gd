static func find_resource_unit_closest_to_unit_yet_no_further_than(
	unit, distance_max, filter_predicate = null
):
	var resource_units = unit.get_tree().get_nodes_in_group("resource_units")
	if filter_predicate != null:
		resource_units = resource_units.filter(filter_predicate)
	var resource_units_sorted_by_distance = (
		resource_units
		. map(
			func(resource_unit): return {
				"distance":
				(unit.global_position * Vector3(1, 0, 1)).distance_to(
					resource_unit.global_position * Vector3(1, 0, 1)
				),
				"unit": resource_unit
			}
		)
		. filter(func(tuple): return tuple["distance"] <= distance_max)
	)
	resource_units_sorted_by_distance.sort_custom(func(a, b): return a["distance"] < b["distance"])
	return (
		resource_units_sorted_by_distance[0]["unit"]
		if not resource_units_sorted_by_distance.is_empty()
		else null
	)
