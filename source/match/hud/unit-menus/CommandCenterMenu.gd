extends GridContainer

const WorkerUnit = preload("res://source/match/units/Worker.tscn")

var unit = null

@onready var _worker_button = find_child("ProduceWorkerButton")


func _ready():
	_worker_button.tooltip_text = ("{0} - {1}\n{2} HP\n{3}: {4}, {5}: {6}".format(
		[
			tr("WORKER"),
			tr("WORKER_DESCRIPTION"),
			Constants.Match.Units.DEFAULT_PROPERTIES[WorkerUnit.resource_path]["hp_max"],
			tr("RESOURCE_A"),
			Constants.Match.Units.PRODUCTION_COSTS[WorkerUnit.resource_path]["resource_a"],
			tr("RESOURCE_B"),
			Constants.Match.Units.PRODUCTION_COSTS[WorkerUnit.resource_path]["resource_b"]
		]
	))


func _on_produce_worker_button_pressed():
	unit.production_queue.produce(WorkerUnit)
