enum NavigationLayers {
	AIR = 1 << 0,
	TERRAIN = 1 << 1,
}

const OWNED_PLAYER_CIRCLE_COLOR = Color.GREEN
const ADVERSARY_PLAYER_CIRCLE_COLOR = Color.RED
const RESOURCE_CIRCLE_COLOR = Color.YELLOW
const DEFAULT_CIRCLE_COLOR = Color.WHITE


class Resources:
	class A:
		const COLOR = Color.BLUE

	class B:
		const COLOR = Color.RED


class Units:
	const PRODUCTION_COSTS = {
		"res://source/match/units/Worker.tscn":
		{
			"resource_a": 0,
			"resource_b": 0,
		}
	}
	const PRODUCTION_TIMES = {
		"res://source/match/units/Worker.tscn": 5.0,
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
			"resource_a": 0,
			"resource_b": 0,
		},
		"res://source/match/units/VehicleFactory.tscn":
		{
			"resource_a": 0,
			"resource_b": 0,
		},
		"res://source/match/units/AircraftFactory.tscn":
		{
			"resource_a": 0,
			"resource_b": 0,
		},
		"res://source/match/units/AntiGroundTurret.tscn":
		{
			"resource_a": 0,
			"resource_b": 0,
		},
		"res://source/match/units/AntiAirTurret.tscn":
		{
			"resource_a": 0,
			"resource_b": 0,
		},
	}
	const DEFAULT_PROPERTIES = {
		"res://source/match/units/Drone.gd":
		{
			"hp": 10,
			"hp_max": 10,
			"damage": 1,
			"damage_interval": 1.0,
		},
		"res://source/match/units/Worker.gd":
		{
			"hp": 10,
			"hp_max": 10,
		},
		"res://source/match/units/CommandCenter.gd":
		{
			"hp": 10,
			"hp_max": 10,
		},
		"res://source/match/units/VehicleFactory.gd":
		{
			"hp": 10,
			"hp_max": 10,
		},
		"res://source/match/units/AircraftFactory.gd":
		{
			"hp": 10,
			"hp_max": 10,
		},
		"res://source/match/units/AntiGroundTurret.gd":
		{
			"hp": 10,
			"hp_max": 10,
		},
		"res://source/match/units/AntiAirTurret.gd":
		{
			"hp": 10,
			"hp_max": 10,
		},
	}
	const ADHERENCE_MARGIN = 0.1
