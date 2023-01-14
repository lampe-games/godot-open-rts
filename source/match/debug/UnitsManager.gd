extends PanelContainer

const ActionCaption = preload("res://source/match/units/traits/debug/ActionCaption.tscn")

@onready var _selected_units_check_box = find_child("SelectedUnitsCheckBox")


func _on_action_caption_toggle_button_pressed():
	var units = (
		get_tree().get_nodes_in_group("selected_units")
		if _selected_units_check_box.button_pressed
		else get_tree().get_nodes_in_group("units")
	)
	for unit in units:
		var action_caption = unit.find_child("ActionCaption", true, false)
		if action_caption == null:
			unit.add_child(ActionCaption.instantiate())
		else:
			action_caption.queue_free()
