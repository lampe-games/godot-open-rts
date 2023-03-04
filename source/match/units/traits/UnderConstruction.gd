extends Node

const UNDER_CONSTRUCTION_MATERIAL = preload(
	"res://source/match/resources/materials/structure_under_construction.material.tres"
)

@onready var _unit = get_parent()


func _ready():
	_change_geometry_material(UNDER_CONSTRUCTION_MATERIAL)
	if _unit.hp == null:
		await _unit.ready
	_unit.hp = 1


func _exit_tree():
	_change_geometry_material(null)
	_unit.hp = _unit.hp_max
	if _unit.is_inside_tree():
		# neither emitting directly from here nor immediately as parent is busy setting up children
		_unit.emit_constructed.call_deferred()


func _change_geometry_material(material):
	for child in _unit.find_child("Geometry").find_children("*"):
		if "material_override" in child:
			child.material_override = material
