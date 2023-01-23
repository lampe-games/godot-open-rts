extends "res://source/match/units/Unit.gd"

const ManagingProduction = preload("res://source/match/units/actions/ManagingProduction.gd")


func _ready():
	super()
	action = ManagingProduction.new()
