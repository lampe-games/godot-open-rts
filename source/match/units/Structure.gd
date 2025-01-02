extends "res://source/match/units/Unit.gd"

signal constructed

const UNDER_CONSTRUCTION_MATERIAL = preload(
	"res://source/match/resources/materials/structure_under_construction.material.tres"
)

var _construction_progress = 1.0

@onready var production_queue = find_child("ProductionQueue"):
	set(_value):
		pass


func is_revealing():
	return super() and is_constructed()


func mark_as_under_construction():
	assert(not is_under_construction(), "structure already under construction")
	_construction_progress = 0.0
	_change_geometry_material(UNDER_CONSTRUCTION_MATERIAL)
	if hp == null:
		await ready
	hp = 1


func construct(progress):
	assert(is_under_construction(), "structure must be under construction")

	var expected_hp_before_progressing = int(_construction_progress * float(hp_max - 1))
	_construction_progress += progress
	var expected_hp_after_progressing = int(_construction_progress * float(hp_max - 1))
	if expected_hp_after_progressing > expected_hp_before_progressing:
		hp += 1
	if _construction_progress >= 1.0:
		_finish_construction()


func cancel_construction():
	var scene_path = get_script().resource_path.replace(".gd", ".tscn")
	var construction_cost = Constants.Match.Units.CONSTRUCTION_COSTS[scene_path]
	player.add_resources(construction_cost)
	queue_free()


func is_constructed():
	return _construction_progress >= 1.0


func is_under_construction():
	return not is_constructed()


func _finish_construction():
	_change_geometry_material(null)
	if is_inside_tree():
		constructed.emit()
		MatchSignals.unit_construction_finished.emit(self)


func _change_geometry_material(material):
	for child in find_child("Geometry").find_children("*"):
		if "material_override" in child:
			child.material_override = material
