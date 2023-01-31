extends "res://source/match/units/Unit.gd"

const LookingForTargets = preload("res://source/match/units/actions/LookingForTargets.gd")


func _ready():
	super()
	action_changed.connect(_on_action_changed)
	action = LookingForTargets.new()


func _on_action_changed(new_action):
	if new_action == null:
		action = LookingForTargets.new()
