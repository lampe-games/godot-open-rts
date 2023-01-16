extends GridContainer

const ManagingProductionAction = preload("res://source/match/units/actions/ManagingProduction.gd")
const WorkerUnit = preload("res://source/match/units/Worker.tscn")

var unit = null


func _on_produce_worker_button_pressed():
	if unit.action != null and unit.action is ManagingProductionAction:
		unit.action.produce(WorkerUnit)
