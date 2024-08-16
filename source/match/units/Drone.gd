extends "res://source/match/units/Unit.gd"

func _ready():
	await super()
	find_child("Movement").domain = Constants.Match.Navigation.Domain.AIR
