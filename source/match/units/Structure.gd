extends "res://source/match/units/Unit.gd"

signal progress_changed
signal constructed

const UNDER_CONSTRUCTION_MATERIAL = preload(
	"res://source/match/resources/materials/structure_under_construction.material.tres"
)

var _under_construction = false
var progress = 0
var progress_max = 10

func mark_as_under_construction():
	assert(not _under_construction, "structure already under construction")
	_under_construction = true
	_change_geometry_material(UNDER_CONSTRUCTION_MATERIAL)
	if hp == null:
		await ready
	hp = 1


func construct( added_progress ):
	assert(_under_construction, "structure must be under construction")
	progress += added_progress
	progress_changed.emit()
	if progress >= progress_max :
		finnish_construction()
		return true
	return false


func finnish_construction():
	_under_construction = false
	_change_geometry_material(null)
	hp = hp_max
	if is_inside_tree():
		constructed.emit()

func is_constructed():
	return not _under_construction


func _change_geometry_material(material):
	for child in find_child("Geometry").find_children("*"):
		if "material_override" in child:
			child.material_override = material
