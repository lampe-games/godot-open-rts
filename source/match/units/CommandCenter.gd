extends "res://source/match/units/Unit.gd"

const ManagingProduction = preload("res://source/match/units/actions/ManagingProduction.gd")

const SIGHT_RANGE = 10.0


func _ready():
	super()
	action = ManagingProduction.new()
