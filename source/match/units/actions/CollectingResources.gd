extends Node


static func is_applicable(source_unit, target_unit):
	return source_unit.is_in_group("worker_units") and target_unit.is_in_group("resource_units")

# TODO: implement
