@tool
extends Node3D

@export var size = Vector2(200, 20):
	set(value):
		size = value
		find_child("SubViewport").size = size
		find_child("ActualBar").size = size

@onready var _unit = get_parent()


func _ready():
	if Engine.is_editor_hint():
		return
	hide()
	_unit.selected.connect(_on_unit_selected)
	_unit.deselected.connect(_on_unit_deselected)


func _on_unit_selected():
	show()


func _on_unit_deselected():
	hide()
