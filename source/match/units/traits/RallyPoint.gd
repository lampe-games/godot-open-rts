extends Node3D

const Unit = preload("res://source/match/units/Unit.gd")

@onready var _unit = get_parent()
@onready var _animation_player = find_child("AnimationPlayer")

var _target = null

func _ready():
	_animation_player.play("idle")
	visible = _unit.is_in_group("selected_units")
	_unit.selected.connect(show)
	_unit.deselected.connect(hide)
	MatchSignals.unit_died.connect(_restore_rally_point_position) # to unfollow when unit die
	MatchSignals.resource_depleted.connect(_restore_rally_point_position) # to unfollow when resource depleted

func _restore_rally_point_position(target):
	if(not(_target is Vector3) && target == _target):
		_target = null
		global_position = _unit.global_position

func set_target(target):
	# unselect prev rally point
	if(_target != null && not(_target is Vector3)):
		var rp_selection = _target.find_child("Selection")
		if rp_selection != null:
			rp_selection.hide_selection_circle()

	_target = target
	if _target is Vector3:
		global_position = target
	else:
		global_position = _unit.global_position
		var rp_selection = _target.find_child("Selection")
		if rp_selection != null:
			rp_selection.show_selection_circle()

func get_target():
	return _target
