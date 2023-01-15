extends GridContainer

var units = []


func _on_cancel_action_button_pressed():
	for unit in units:
		unit.action = null
