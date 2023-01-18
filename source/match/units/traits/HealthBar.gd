# TODO: dynamic show/hide on hp changes
@tool
extends Node3D

@export var size = Vector2(200, 20):
	set(value):
		size = value
		find_child("SubViewport").size = size
		find_child("ActualBar").size = size

@onready var _unit = get_parent()
@onready var _actual_bar = find_child("ActualBar")


func _ready():
	if Engine.is_editor_hint():
		return
	hide()
	_recalulate_bar_value()
	_unit.selected.connect(_on_unit_selected)
	_unit.deselected.connect(_on_unit_deselected)
	_unit.hp_changed.connect(_on_hp_changed)


func _recalulate_bar_value():
	_actual_bar.value = (
		float(_unit.hp) / _unit.hp_max if _unit.hp != null and _unit.hp_max != null else 0
	)


func _on_unit_selected():
	show()


func _on_unit_deselected():
	hide()


func _on_hp_changed():
	_recalulate_bar_value()
