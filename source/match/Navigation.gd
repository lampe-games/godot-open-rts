extends Node3D

var _static_obstacles = []

@onready var air = find_child("Air")
@onready var terrain = find_child("Terrain")

@onready var _match = find_parent("Match")


func _ready():
	await _match.ready
	_setup_static_obstacles()


func get_navigation_map_rid_by_domain(domain):
	return {
		Constants.Match.Navigation.Domain.AIR: air.navigation_map_rid,
		Constants.Match.Navigation.Domain.TERRAIN: terrain.navigation_map_rid,
	}[domain]


func rebake(map):
	var obstacles = get_tree().get_nodes_in_group("terrain_navigation_input")
	for obstacle in obstacles:
		if obstacle.name.to_lower() != "terrain":
			obstacle.remove_from_group("terrain_navigation_input")
	air.rebake(map)
	terrain.rebake(false)
	for obstacle in obstacles:
		obstacle.add_to_group("terrain_navigation_input")
	_clear_static_obstacles()
	_setup_static_obstacles()
	
func update_terrain():
	terrain.rebake(true)
	print("update_terrain")

func _clear_static_obstacles():
	for static_obstacle in _static_obstacles:
		NavigationServer3D.free_rid(static_obstacle)
	_static_obstacles = []


func _setup_static_obstacles():
	if not _static_obstacles.is_empty():
		return
	for domain in [
		Constants.Match.Navigation.Domain.AIR, Constants.Match.Navigation.Domain.TERRAIN
	]:
		var obstacle = NavigationServer3D.obstacle_create()
		NavigationServer3D.obstacle_set_map(obstacle, get_navigation_map_rid_by_domain(domain))
		var obstacle_y = {
			Constants.Match.Navigation.Domain.AIR: Constants.Match.Air.Y,
			Constants.Match.Navigation.Domain.TERRAIN: 0,
		}[domain]
		NavigationServer3D.obstacle_set_position(obstacle, Vector3(0, obstacle_y, 0))
		var obstacle_vertices = [
			Vector3(0, 0, 0),
			Vector3(0, 0, _match.map.size.y),
			Vector3(_match.map.size.x, 0, _match.map.size.y),
			Vector3(_match.map.size.x, 0, 0),
		]
		NavigationServer3D.obstacle_set_vertices(obstacle, obstacle_vertices)
		NavigationServer3D.obstacle_set_avoidance_enabled(obstacle, true)
		_static_obstacles.append(obstacle)
