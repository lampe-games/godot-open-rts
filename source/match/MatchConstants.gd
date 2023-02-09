const OWNED_PLAYER_CIRCLE_COLOR = Color.GREEN
const ADVERSARY_PLAYER_CIRCLE_COLOR = Color.RED
const RESOURCE_CIRCLE_COLOR = Color.YELLOW
const DEFAULT_CIRCLE_COLOR = Color.WHITE


class Navigation:
	enum Domain { AIR, TERRAIN }


class Air:
	const PLANE = Plane(Vector3.UP, 1.5)


class Terrain:
	const PLANE = Plane(Vector3.UP, 0)


class Resources:
	class A:
		const COLOR = Color.BLUE
		const MATERIAL_PATH = "res://source/match/resources/materials/resource_a.material.tres"
		const COLLECTING_TIME_S = 1.0

	class B:
		const COLOR = Color.RED
		const MATERIAL_PATH = "res://source/match/resources/materials/resource_b.material.tres"
		const COLLECTING_TIME_S = 2.0


class Units:
	# TODO: drone
	const PRODUCTION_COSTS = {
		"res://source/match/units/Worker.tscn":
		{
			"resource_a": 1,
			"resource_b": 1,
		},
		"res://source/match/units/Helicopter.tscn":
		{
			"resource_a": 1,
			"resource_b": 1,
		},
		"res://source/match/units/Tank.tscn":
		{
			"resource_a": 1,
			"resource_b": 1,
		},
	}
	const PRODUCTION_TIMES = {
		"res://source/match/units/Worker.tscn": 0.75,
		"res://source/match/units/Helicopter.tscn": 0.75,
		"res://source/match/units/Tank.tscn": 0.75,
	}
	const BUILDING_BLUEPRINTS = {
		"res://source/match/units/CommandCenter.tscn":
		"res://source/match/units/building-blueprints/CommandCenter.tscn",
		"res://source/match/units/VehicleFactory.tscn":
		"res://source/match/units/building-blueprints/VehicleFactory.tscn",
		"res://source/match/units/AircraftFactory.tscn":
		"res://source/match/units/building-blueprints/AircraftFactory.tscn",
		"res://source/match/units/AntiGroundTurret.tscn":
		"res://source/match/units/building-blueprints/AntiGroundTurret.tscn",
		"res://source/match/units/AntiAirTurret.tscn":
		"res://source/match/units/building-blueprints/AntiAirTurret.tscn",
	}
	const CONSTRUCTION_COSTS = {
		"res://source/match/units/CommandCenter.tscn":
		{
			"resource_a": 1,
			"resource_b": 1,
		},
		"res://source/match/units/VehicleFactory.tscn":
		{
			"resource_a": 1,
			"resource_b": 1,
		},
		"res://source/match/units/AircraftFactory.tscn":
		{
			"resource_a": 1,
			"resource_b": 1,
		},
		"res://source/match/units/AntiGroundTurret.tscn":
		{
			"resource_a": 1,
			"resource_b": 1,
		},
		"res://source/match/units/AntiAirTurret.tscn":
		{
			"resource_a": 1,
			"resource_b": 1,
		},
	}
	const DEFAULT_PROPERTIES = {
		"res://source/match/units/Drone.gd":
		{
			"sight_range": 10.0,
			"hp": 10,
			"hp_max": 10,
		},
		"res://source/match/units/Worker.gd":
		{
			"sight_range": 10.0,
			"hp": 10,
			"hp_max": 10,
			"resources_max": 2,
		},
		"res://source/match/units/Helicopter.gd":
		{
			"sight_range": 10.0,
			"hp": 10,
			"hp_max": 10,
			"attack_damage": 1,
			"attack_interval": 1.0,
			"attack_range": 5.0,
			"attack_domains": [Navigation.Domain.TERRAIN, Navigation.Domain.AIR],
		},
		"res://source/match/units/Tank.gd":
		{
			"sight_range": 10.0,
			"hp": 10,
			"hp_max": 10,
			"attack_damage": 1,
			"attack_interval": 1.0,
			"attack_range": 5.0,
			"attack_domains": [Navigation.Domain.TERRAIN],
		},
		"res://source/match/units/CommandCenter.gd":
		{
			"sight_range": 10.0,
			"hp": 10,
			"hp_max": 10,
		},
		"res://source/match/units/VehicleFactory.gd":
		{
			"sight_range": 10.0,
			"hp": 10,
			"hp_max": 10,
		},
		"res://source/match/units/AircraftFactory.gd":
		{
			"sight_range": 10.0,
			"hp": 10,
			"hp_max": 10,
		},
		"res://source/match/units/AntiGroundTurret.gd":
		{
			"sight_range": 10.0,
			"hp": 10,
			"hp_max": 10,
			"attack_damage": 1,
			"attack_interval": 1.0,
			"attack_range": 8.0,
			"attack_domains": [Navigation.Domain.TERRAIN],
		},
		"res://source/match/units/AntiAirTurret.gd":
		{
			"sight_range": 10.0,
			"hp": 10,
			"hp_max": 10,
			"attack_damage": 1,
			"attack_interval": 1.0,
			"attack_range": 8.0,
			"attack_domains": [Navigation.Domain.AIR],
		},
	}
	const PROJECTILES = {
		"res://source/match/units/Helicopter.gd":
		"res://source/match/units/projectiles/Rocket.tscn",
		"res://source/match/units/Tank.gd": "res://source/match/units/projectiles/CannonShell.tscn",
		"res://source/match/units/AntiGroundTurret.gd":
		"res://source/match/units/projectiles/CannonShell.tscn",
		"res://source/match/units/AntiAirTurret.gd":
		"res://source/match/units/projectiles/Rocket.tscn"
	}
	const ADHERENCE_MARGIN = 0.1
