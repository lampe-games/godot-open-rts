extends Node3D

const CommandCenter = preload("res://source/match/units/CommandCenter.tscn")

@export var settings: Resource = null


func _ready():
	_spawn_initial_player_units()


func _spawn_initial_player_units():
	var spawn_points = find_child("SpawnPoints").get_children()
	for player_id in range(settings.players.size()):
		var command_center = CommandCenter.instantiate()
		command_center.color = settings.players[player_id].color
		command_center.global_transform = spawn_points[player_id].global_transform
		add_child(command_center)
