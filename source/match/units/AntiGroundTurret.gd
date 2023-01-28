extends "res://source/match/units/Unit.gd"

const LookingForTargets = preload("res://source/match/units/actions/LookingForTargets.gd")


func _ready():
	super()
	action = LookingForTargets.new([Constants.Match.Navigation.Domain.TERRAIN])
