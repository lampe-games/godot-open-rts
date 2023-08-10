extends "res://source/match/units/Structure.gd"

const ManagingProduction = preload("res://source/match/units/actions/ManagingProduction.gd")


func _ready():
	await super()
	if not is_constructed():
		await constructed
	action = ManagingProduction.new()


func _set_action(action_node):
	if not _action_locked and action == null:
		super(action_node)
	elif action_node != null:
		action_node.queue_free()
