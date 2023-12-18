extends Node3D

const SparklingAnimation = preload("res://source/match/utils/SparklingAnimation.tscn")

var _animation = null

@onready var _unit = get_parent()


func enable():
	if not _animation == null:
		return
	_animation = SparklingAnimation.instantiate()
	_animation.transform.origin = Vector3(
		0, 0, -_unit.radius - Constants.Match.Units.ADHERENCE_MARGIN_M
	)
	add_child(_animation, true)


func disable():
	if _animation == null:
		return
	_animation.queue_free()
	_animation = null
