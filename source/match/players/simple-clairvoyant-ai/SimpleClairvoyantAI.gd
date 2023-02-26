# TODO: Intelligence controller
extends Node

enum ResourceRequestPriority { LOW, MEDIUM, HIGH }
enum OffensiveStructure { VEHICLE_FACTORY, AIRCRAFT_FACTORY }

@export var expected_number_of_workers = 3
@export var expected_number_of_ccs = 1
@export var expected_number_of_ag_turrets = 2
@export var expected_number_of_aa_turrets = 2
@export var primary_offensive_structure = OffensiveStructure.VEHICLE_FACTORY
@export var secondary_offensive_structure = OffensiveStructure.AIRCRAFT_FACTORY
@export var expected_number_of_battlegroups = 2
@export var expected_number_of_units_in_battlegroup = 4

var player: Resource = null

var _provisioning_ongoing = false
var _resource_requests = {
	ResourceRequestPriority.LOW: [],
	ResourceRequestPriority.MEDIUM: [],
	ResourceRequestPriority.HIGH: [],
}

@onready var _economy_controller = find_child("EconomyController")
@onready var _defense_controller = find_child("DefenseController")
@onready var _offense_controller = find_child("OffenseController")


func _ready():
	await find_parent("Match").ready
	if player == null:
		queue_free()
		return
	# TODO: cancel actions of all owned units - it will
	#       enable AI setup in runtime (e.g. on player switch)
	player.changed.connect(_on_player_resource_changed)
	_economy_controller.resources_required.connect(
		_on_resource_request.bind(_economy_controller, ResourceRequestPriority.HIGH)
	)
	_economy_controller.setup(player)
	# _defense_controller.resources_required.connect(
	# 	_on_resource_request.bind(_defense_controller, ResourceRequestPriority.MEDIUM)
	# )
	# _defense_controller.setup(player)
	_offense_controller.resources_required.connect(
		_on_resource_request.bind(_offense_controller, ResourceRequestPriority.LOW)
	)
	_offense_controller.setup(player)


func _provision(controller, resources, metadata):
	_provisioning_ongoing = true
	controller.provision(resources, metadata)
	_provisioning_ongoing = false


func _try_fulfilling_resource_requests_according_to_priorities():
	if _provisioning_ongoing:
		return
	for priority in [
		ResourceRequestPriority.HIGH, ResourceRequestPriority.MEDIUM, ResourceRequestPriority.LOW
	]:
		while (
			not _resource_requests[priority].is_empty()
			and player.has_resources(_resource_requests[priority].front()["resources"])
		):
			var resource_request = _resource_requests[priority].pop_front()
			_provision(
				resource_request["controller"],
				resource_request["resources"],
				resource_request["metadata"]
			)
		if (
			not _resource_requests[priority].is_empty()
			and not player.has_resources(_resource_requests[priority].front()["resources"])
		):
			break


func _on_player_resource_changed():
	_try_fulfilling_resource_requests_according_to_priorities()


func _on_resource_request(resources, metadata, controller, priority):
	assert(not _provisioning_ongoing)
	_resource_requests[priority].append(
		{"controller": controller, "resources": resources, "metadata": metadata}
	)
	_try_fulfilling_resource_requests_according_to_priorities()
