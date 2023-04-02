extends GridContainer

const CommandCenterUnit = preload("res://source/match/units/CommandCenter.tscn")
const VehicleFactoryUnit = preload("res://source/match/units/VehicleFactory.tscn")
const AircraftFactoryUnit = preload("res://source/match/units/AircraftFactory.tscn")
const AntiGroundTurretUnit = preload("res://source/match/units/AntiGroundTurret.tscn")
const AntiAirTurretUnit = preload("res://source/match/units/AntiAirTurret.tscn")

@onready var _ag_turret_button = find_child("PlaceAntiGroundTurretButton")
@onready var _aa_turret_button = find_child("PlaceAntiAirTurretButton")
@onready var _cc_button = find_child("PlaceCommandCenterButton")
@onready var _vehicle_factory_button = find_child("PlaceVehicleFactoryButton")
@onready var _aircraft_factory_button = find_child("PlaceAircraftFactoryButton")


func _ready():
	var ag_turret_properties = Constants.Match.Units.DEFAULT_PROPERTIES[
		AntiGroundTurretUnit.resource_path
	]
	_ag_turret_button.tooltip_text = ("{0} - {1}\n{2} HP, {3} DPS\n{4}: {5}, {6}: {7}".format(
		[
			tr("AG_TURRET"),
			tr("AG_TURRET_DESCRIPTION"),
			ag_turret_properties["hp_max"],
			ag_turret_properties["attack_damage"] * ag_turret_properties["attack_interval"],
			tr("RESOURCE_A"),
			(
				Constants
				. Match
				. Units
				. CONSTRUCTION_COSTS[AntiGroundTurretUnit.resource_path]["resource_a"]
			),
			tr("RESOURCE_B"),
			(
				Constants
				. Match
				. Units
				. CONSTRUCTION_COSTS[AntiGroundTurretUnit.resource_path]["resource_b"]
			)
		]
	))
	var aa_turret_properties = Constants.Match.Units.DEFAULT_PROPERTIES[
		AntiAirTurretUnit.resource_path
	]
	_aa_turret_button.tooltip_text = ("{0} - {1}\n{2} HP, {3} DPS\n{4}: {5}, {6}: {7}".format(
		[
			tr("AA_TURRET"),
			tr("AA_TURRET_DESCRIPTION"),
			aa_turret_properties["hp_max"],
			aa_turret_properties["attack_damage"] * aa_turret_properties["attack_interval"],
			tr("RESOURCE_A"),
			Constants.Match.Units.CONSTRUCTION_COSTS[AntiAirTurretUnit.resource_path]["resource_a"],
			tr("RESOURCE_B"),
			Constants.Match.Units.CONSTRUCTION_COSTS[AntiAirTurretUnit.resource_path]["resource_b"]
		]
	))
	_cc_button.tooltip_text = ("{0} - {1}\n{2} HP\n{3}: {4}, {5}: {6}".format(
		[
			tr("CC"),
			tr("CC_DESCRIPTION"),
			Constants.Match.Units.DEFAULT_PROPERTIES[CommandCenterUnit.resource_path]["hp_max"],
			tr("RESOURCE_A"),
			Constants.Match.Units.CONSTRUCTION_COSTS[CommandCenterUnit.resource_path]["resource_a"],
			tr("RESOURCE_B"),
			Constants.Match.Units.CONSTRUCTION_COSTS[CommandCenterUnit.resource_path]["resource_b"]
		]
	))
	_vehicle_factory_button.tooltip_text = ("{0} - {1}\n{2} HP\n{3}: {4}, {5}: {6}".format(
		[
			tr("VEHICLE_FACTORY"),
			tr("VEHICLE_FACTORY_DESCRIPTION"),
			Constants.Match.Units.DEFAULT_PROPERTIES[VehicleFactoryUnit.resource_path]["hp_max"],
			tr("RESOURCE_A"),
			(
				Constants
				. Match
				. Units
				. CONSTRUCTION_COSTS[VehicleFactoryUnit.resource_path]["resource_a"]
			),
			tr("RESOURCE_B"),
			Constants.Match.Units.CONSTRUCTION_COSTS[VehicleFactoryUnit.resource_path]["resource_b"]
		]
	))
	_aircraft_factory_button.tooltip_text = ("{0} - {1}\n{2} HP\n{3}: {4}, {5}: {6}".format(
		[
			tr("AIRCRAFT_FACTORY"),
			tr("AIRCRAFT_FACTORY_DESCRIPTION"),
			Constants.Match.Units.DEFAULT_PROPERTIES[AircraftFactoryUnit.resource_path]["hp_max"],
			tr("RESOURCE_A"),
			(
				Constants
				. Match
				. Units
				. CONSTRUCTION_COSTS[AircraftFactoryUnit.resource_path]["resource_a"]
			),
			tr("RESOURCE_B"),
			(
				Constants
				. Match
				. Units
				. CONSTRUCTION_COSTS[AircraftFactoryUnit.resource_path]["resource_b"]
			)
		]
	))


func _on_place_command_center_button_pressed():
	MatchSignals.place_structure.emit(CommandCenterUnit)


func _on_place_vehicle_factory_button_pressed():
	MatchSignals.place_structure.emit(VehicleFactoryUnit)


func _on_place_aircraft_factory_button_pressed():
	MatchSignals.place_structure.emit(AircraftFactoryUnit)


func _on_place_anti_ground_turret_button_pressed():
	MatchSignals.place_structure.emit(AntiGroundTurretUnit)


func _on_place_anti_air_turret_button_pressed():
	MatchSignals.place_structure.emit(AntiAirTurretUnit)
