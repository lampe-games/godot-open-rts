# priorities:
# 1. enough workers | ResourceGathering | Economy: CC, Workers
# 2. basic AA/AG defence | Defence: X AG Y AA
# 3. offense | Offense
# -------------------
# TODO: design a way for allocating resources as per priorities
# TODO: on resource request from controller: provision or enqueue if no resources
# TODO: on new resources: provision if smth in queue
extends Node

@export var player: Resource = null

@onready var _economy_controller = find_child("EconomyController")


func _ready():
	await find_parent("Match").ready
	if player == null:
		queue_free()
		return
	print("hello from AI ", self, " for player ", player)
	_economy_controller.resources_required.connect(_on_resource_request.bind(_economy_controller))
	_economy_controller.setup(player)
	# TODO: cancel actions of all owned units - it will
	#       enable AI setup in runtime (e.g. on player switch)


func _on_resource_request(controller, resources):
	print("_on_resource_request", controller, resources)
