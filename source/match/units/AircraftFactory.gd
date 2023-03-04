extends "res://source/match/units/Structure.gd"

const ManagingProduction = preload("res://source/match/units/actions/ManagingProduction.gd")


func _ready():
	await super()
	if not is_constructed():
		await constructed
	action = ManagingProduction.new()
