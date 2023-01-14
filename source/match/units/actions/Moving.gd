extends Node

var _target_position = null
var _action_finished = false

@onready var _unit = get_parent()
@onready var _movement_trait = _unit.find_child("Movement")


static func is_applicable(unit):
	return unit.find_child("Movement") != null


func _init(target_position):
	_target_position = target_position


func _ready():
	_movement_trait.move(_target_position)
	_movement_trait.navigation_finished.connect(_on_movement_finished)  # TODO: use custom signal


func _exit_tree():
	if not _action_finished:
		_movement_trait.stop()


func _on_movement_finished():
	assert(_action_finished == false)
	_action_finished = true
	queue_free()
