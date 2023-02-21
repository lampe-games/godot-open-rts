# priorities:
# 1. enough workers | ResourceGathering | Economy: CC, Workers
# 2. basic AA/AG defence | Defence: X AG Y AA
# 3. offense | Offense
# -------------------
# TODO: design a way for allocating resources as per priorities
extends Node

@export var player: Resource = null
@export var expected_number_of_workers = 3
@export var expected_number_of_ccs = 1
@export var expected_number_of_ag_turrets = 2
@export var expected_number_of_aa_turrets = 2

var _provisioning_ongoing = false
var _resource_requests = []

@onready var _economy_controller = find_child("EconomyController")
@onready var _defense_controller = find_child("DefenseController")


func _ready():
	await find_parent("Match").ready
	if player == null:
		queue_free()
		return
	# TODO: cancel actions of all owned units - it will
	#       enable AI setup in runtime (e.g. on player switch)
	player.changed.connect(_on_player_resource_changed)
	_economy_controller.resources_required.connect(_on_resource_request.bind(_economy_controller))
	_economy_controller.setup(player)
	_defense_controller.setup(player)


func _provision(controller, resources, metadata):
	_provisioning_ongoing = true
	controller.provision(resources, metadata)
	_provisioning_ongoing = false


func _on_player_resource_changed():
	if _provisioning_ongoing:
		return
	while (
		not _resource_requests.is_empty()
		and player.has_resources(_resource_requests.front()["resources"])
	):
		var resource_request = _resource_requests.pop_front()
		_provision(
			resource_request["controller"],
			resource_request["resources"],
			resource_request["metadata"]
		)


func _on_resource_request(resources, metadata, controller):
	if player.has_resources(resources):
		_provision(controller, resources, metadata)
	else:
		_resource_requests.append(
			{"controller": controller, "resources": resources, "metadata": metadata}
		)
