extends GridContainer

const CommandCenter = preload("res://source/match/units/CommandCenter.tscn")
const VehicleFactory = preload("res://source/match/units/VehicleFactory.tscn")
const AircraftFactory = preload("res://source/match/units/AircraftFactory.tscn")
const AntiGroundTurret = preload("res://source/match/units/AntiGroundTurret.tscn")
const AntiAirTurret = preload("res://source/match/units/AntiAirTurret.tscn")


func _on_place_command_center_button_pressed():
	MatchSignals.place_building.emit(CommandCenter)


func _on_place_vehicle_factory_button_pressed():
	MatchSignals.place_building.emit(VehicleFactory)


func _on_place_aircraft_factory_button_pressed():
	MatchSignals.place_building.emit(AircraftFactory)


func _on_place_anti_ground_turret_button_pressed():
	MatchSignals.place_building.emit(AntiGroundTurret)


func _on_place_anti_air_turret_button_pressed():
	MatchSignals.place_building.emit(AntiAirTurret)
