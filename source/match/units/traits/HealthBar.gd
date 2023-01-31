@tool
extends Node3D

const BAR_AUTO_VISIBILITY_DURATION = 2.0

@export var size = Vector2(200, 20):
	set(value):
		size = value
		find_child("ActualBar").texture.width = size.x
		find_child("ActualBar").texture.height = size.y

var _bar_value_initialized = false

@onready var _unit = get_parent()
@onready var _actual_bar = find_child("ActualBar")
@onready var _visibility_timer = find_child("Timer")


func _ready():
	if Engine.is_editor_hint():
		return
	hide()
	_recalulate_bar_value()
	_unit.selected.connect(_on_unit_selected)
	_unit.deselected.connect(_on_unit_deselected)
	_unit.hp_changed.connect(_on_hp_changed)
	_visibility_timer.timeout.connect(_on_visibility_timer_timeout)


func _recalulate_bar_value():
	if _unit.hp == null or _unit.hp_max == null:
		return
	var old_value = _actual_bar.texture.gradient.get_offset(1)
	var new_value = float(_unit.hp) / _unit.hp_max
	new_value = new_value if not is_equal_approx(new_value, 1.0) else 1.1  # fixing 1px gap
	_actual_bar.texture.gradient.set_offset(1, new_value)
	if _bar_value_initialized and old_value != new_value:
		_show_for_a_while()
	_bar_value_initialized = true


func _show_for_a_while():
	if visible:
		return
	show()
	_visibility_timer.start(BAR_AUTO_VISIBILITY_DURATION)


func _on_unit_selected():
	_visibility_timer.stop()
	show()


func _on_unit_deselected():
	hide()


func _on_hp_changed():
	_recalulate_bar_value()


func _on_visibility_timer_timeout():
	hide()
