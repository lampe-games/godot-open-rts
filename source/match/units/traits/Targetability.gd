extends Node3D

@onready var _unit = get_parent()


func _ready():
	_unit.input_event.connect(_on_input_event)


func _on_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_RIGHT
		and event.pressed
	):
		MatchSignals.unit_targeted.emit(_unit)
