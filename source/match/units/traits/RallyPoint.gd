extends Node3D

var target_unit = null:
	set(a_target_unit):
		if target_unit == null and a_target_unit != null:
			a_target_unit.tree_exited.connect(_on_target_unit_tree_exited)
			hide()
		elif target_unit != null and a_target_unit == null:
			target_unit.tree_exited.disconnect(_on_target_unit_tree_exited)
			_reset_position_to_parent()
			if _unit.is_in_group("selected_units"):
				show()
		target_unit = a_target_unit

@onready var _unit = get_parent()
@onready var _animation_player = find_child("AnimationPlayer")


func _ready():
	_animation_player.play("idle")
	visible = _unit.is_in_group("selected_units")
	_unit.selected.connect(_show)
	_unit.deselected.connect(hide)


func _physics_process(_delta):
	if target_unit != null:
		global_position = target_unit.global_position


func _show():
	if target_unit == null:
		show()
	else:
		var targetability = target_unit.find_child("Targetability")
		if targetability != null:
			targetability.animate()


func _reset_position_to_parent():
	global_position = _unit.global_position


func _on_target_unit_tree_exited():
	target_unit = null
