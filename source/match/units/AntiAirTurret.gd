extends "res://source/match/units/Structure.gd"

const WaitingForTargets = preload("res://source/match/units/actions/WaitingForTargets.gd")


func _ready():
	await super()
	if not is_constructed():
		await constructed
	action = WaitingForTargets.new()
