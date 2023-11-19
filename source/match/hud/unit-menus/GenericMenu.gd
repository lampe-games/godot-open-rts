extends GridContainer

const Structure = preload("res://source/match/units/Structure.gd")

var units = []


func _on_cancel_action_button_pressed():
	if len(units) == 1 and units[0] is Structure and units[0].is_under_construction():
		units[0].cancel_construction()
		return
	for unit in units:
		unit.action = null
