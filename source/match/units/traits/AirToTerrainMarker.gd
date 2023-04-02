extends Node3D

const CONTROLLED_UNIT_MATERIAL = preload(
	"res://source/match/resources/materials/controlled_unit_air_to_terrain_marker.material.tres"
)
const ADVERSARY_UNIT_MATERIAL = preload(
	"res://source/match/resources/materials/adversary_unit_air_to_terrain_marker.material.tres"
)

@onready var _unit = get_parent()
@onready var _mesh_instance = find_child("MeshInstance3D")


func _ready():
	_mesh_instance.visible = _unit.is_in_group("selected_units")
	_unit.selected.connect(_on_unit_selected)
	_unit.deselected.connect(_mesh_instance.hide)


func _update_material():
	if _unit.is_in_group("controlled_units"):
		_mesh_instance.material_override = CONTROLLED_UNIT_MATERIAL
	elif _unit.is_in_group("adversary_units"):
		_mesh_instance.material_override = ADVERSARY_UNIT_MATERIAL
	else:
		assert(false, "unexpected flow")


func _on_unit_selected():
	_update_material()
	_mesh_instance.show()
