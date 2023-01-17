extends GridContainer

const CommandCenter = preload("res://source/match/units/CommandCenter.tscn")

var unit = null


func _on_place_command_center_button_pressed():
	MatchSignals.place_building.emit(CommandCenter)
