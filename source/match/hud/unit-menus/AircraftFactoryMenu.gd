extends GridContainer

const ManagingProductionAction = preload("res://source/match/units/actions/ManagingProduction.gd")
const HelicopterUnit = preload("res://source/match/units/Helicopter.tscn")

var unit = null


func _on_produce_helicopter_button_pressed():
	if unit.action != null and unit.action is ManagingProductionAction:
		unit.action.produce(HelicopterUnit)
