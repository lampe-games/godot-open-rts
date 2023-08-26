extends "res://source/match/units/Structure.gd"

const WaitingForTargets = preload("res://source/match/units/actions/WaitingForTargets.gd")


func _ready():
	await super()
	find_child("Geometry").visible = visible
	visibility_changed.connect(func(): find_child("Geometry").visible = visible)
	if not is_constructed():
		await constructed
	action = WaitingForTargets.new()


func _set_action(action_node):
	if not _action_locked and action == null:
		super(action_node)
	elif action_node != null:
		action_node.queue_free()
