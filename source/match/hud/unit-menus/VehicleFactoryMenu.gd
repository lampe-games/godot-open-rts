extends GridContainer

const ManagingProductionAction = preload("res://source/match/units/actions/ManagingProduction.gd")
const TankUnit = preload("res://source/match/units/Tank.tscn")

var unit = null


func _on_produce_tank_button_pressed():
	if unit.action != null and unit.action is ManagingProductionAction:
		unit.action.produce(TankUnit)
