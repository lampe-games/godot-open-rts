extends Area3D

const ResourceDecayAnimation = preload("res://source/match/utils/ResourceDecayAnimation.tscn")

var radius = null:
	set = _ignore,
	get = _get_radius


func _enter_tree():
	tree_exiting.connect(_animate_decay)


func _ignore(_value):
	pass


func _get_radius():
	return find_child("MovementObstacle").radius


func _animate_decay():
	var decay_animation = ResourceDecayAnimation.instantiate()
	decay_animation.global_transform = global_transform
	get_parent().add_child.call_deferred(decay_animation)
