extends Node3D

const DynamicCircle2D = preload("res://source/generic-scenes-and-nodes/2d/DynamicCircle2D.tscn")

const FOG_CIRCLE_COLOR = Color(0.25, 0.25, 0.25)
const SHROUD_CIRCLE_COLOR = Color(1.0, 1.0, 1.0)
const TEXTURE_UNITS_PER_WORLD_UNIT = 2

var _unit_to_circles_mapping = {}

@onready var _revealer = find_child("Revealer")
@onready var _fog_viewport = find_child("FogViewport")
@onready var _fog_viewport_container = find_child("FogViewportContainer")


func _ready():
	_revealer.hide()
	find_child("EditorOnlyCircle").queue_free()


func _physics_process(_delta):
	var units_synced = {}
	var units_to_sync = get_tree().get_nodes_in_group("revealed_units")
	for unit in units_to_sync:
		if not unit.visible:
			continue
		units_synced[unit] = 1
		if not _unit_is_mapped(unit):
			_map_unit_to_new_circles(unit)
		_sync_circles_to_unit(unit)
	for mapped_unit in _unit_to_circles_mapping:
		if not mapped_unit in units_synced:
			_cleanup_mapping(mapped_unit)


func _unit_is_mapped(unit):
	return unit in _unit_to_circles_mapping


func _map_unit_to_new_circles(unit):
	var shroud_circle = DynamicCircle2D.instantiate()
	shroud_circle.color = FOG_CIRCLE_COLOR
	shroud_circle.radius = unit.SIGHT_RANGE * TEXTURE_UNITS_PER_WORLD_UNIT
	_fog_viewport.add_child(shroud_circle)
	var fow_circle = DynamicCircle2D.instantiate()
	fow_circle.color = SHROUD_CIRCLE_COLOR
	fow_circle.radius = unit.SIGHT_RANGE * TEXTURE_UNITS_PER_WORLD_UNIT
	_fog_viewport_container.add_sibling(fow_circle)
	_unit_to_circles_mapping[unit] = [shroud_circle, fow_circle]


func _sync_circles_to_unit(unit):
	var unit_pos_3d = unit.global_transform.origin
	var unit_pos_2d = Vector2(unit_pos_3d.x, unit_pos_3d.z) * TEXTURE_UNITS_PER_WORLD_UNIT
	_unit_to_circles_mapping[unit][0].position = unit_pos_2d
	_unit_to_circles_mapping[unit][1].position = unit_pos_2d


func _cleanup_mapping(unit):
	_unit_to_circles_mapping[unit][0].queue_free()
	_unit_to_circles_mapping[unit][1].queue_free()
	_unit_to_circles_mapping.erase(unit)
