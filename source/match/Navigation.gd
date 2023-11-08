extends Node3D

const NAVIGATION_FIXING_TIMER_INTERVAL_S = 0.1

var _dummy_agent_rids = {
	Constants.Match.Navigation.Domain.AIR: null,
	Constants.Match.Navigation.Domain.TERRAIN: null,
}
var _static_obstacles = []

@onready var air = find_child("Air")
@onready var terrain = find_child("Terrain")

@onready var _match = find_parent("Match")


func _ready():
	_setup_navigation_fixing_timer()
	await _match.ready
	_setup_static_obstacles()


func get_navigation_map_rid_by_domain(domain):
	return {
		Constants.Match.Navigation.Domain.AIR: air.navigation_map_rid,
		Constants.Match.Navigation.Domain.TERRAIN: terrain.navigation_map_rid,
	}[domain]


func rebake(map):
	air.rebake(map)
	terrain.rebake()
	_clear_static_obstacles()
	_setup_static_obstacles()


func _setup_navigation_fixing_timer():
	var timer = Timer.new()
	timer.timeout.connect(_fix_navigation)
	add_child(timer)
	timer.start(NAVIGATION_FIXING_TIMER_INTERVAL_S)


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
		for edge in [
			[Vector2(0, 0), Vector2(1, 0)],
			[Vector2(1, 0), Vector2(1, 1)],
			[Vector2(1, 1), Vector2(0, 1)],
			[Vector2(0, 1), Vector2(0, 0)],
		]:
			var actual_edge = [edge[0] * _match.map.size, edge[1] * _match.map.size]
			var obstacle = NavigationServer3D.obstacle_create()
			NavigationServer3D.obstacle_set_map(obstacle, get_navigation_map_rid_by_domain(domain))
			(
				NavigationServer3D
				. obstacle_set_vertices(
					obstacle,
					[
						Vector3(actual_edge[0].x, -99, actual_edge[0].y),
						Vector3(actual_edge[0].x, 99, actual_edge[0].y),
						Vector3(actual_edge[1].x, 99, actual_edge[1].y),
						Vector3(actual_edge[1].x, -99, actual_edge[1].y),
					]
				)
			)
			NavigationServer3D.obstacle_set_avoidance_enabled(obstacle, true)
			_static_obstacles.append(obstacle)


func _fix_navigation():
	"""workarounds Godot bug #72202"""
	for domain in [
		Constants.Match.Navigation.Domain.AIR, Constants.Match.Navigation.Domain.TERRAIN
	]:
		if _dummy_agent_rids[domain] == null:
			_dummy_agent_rids[domain] = NavigationServer3D.agent_create()
			NavigationServer3D.agent_set_position(_dummy_agent_rids[domain], Vector3(-99, 0, -99))
			NavigationServer3D.agent_set_map(
				_dummy_agent_rids[domain], get_navigation_map_rid_by_domain(domain)
			)
		else:
			NavigationServer3D.free_rid(_dummy_agent_rids[domain])
			_dummy_agent_rids[domain] = null
