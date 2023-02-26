extends PanelContainer

const ActionCaption = preload("res://source/match/units/traits/debug/ActionCaption.tscn")

@onready var _selected_units_check_box = find_child("SelectedUnitsCheckBox")


func _unhandled_input(event):
	if not Globals.god_mode:
		return
	if event.is_action_pressed("god_mode_delete_units"):
		for unit in get_tree().get_nodes_in_group("selected_units"):
			unit.queue_free()


func _get_requested_units():
	return (
		get_tree().get_nodes_in_group("selected_units")
		if _selected_units_check_box.button_pressed
		else get_tree().get_nodes_in_group("units")
	)


func _on_action_caption_toggle_button_pressed():
	for unit in _get_requested_units():
		var action_caption = unit.find_child("ActionCaption", true, false)
		if action_caption == null:
			unit.add_child(ActionCaption.instantiate())
		else:
			action_caption.queue_free()


func _on_debug_visuals_toggle_button_pressed():
	for unit in _get_requested_units():
		var movement_trait = unit.find_child("Movement")
		if movement_trait != null:
			movement_trait.debug_enabled = not movement_trait.debug_enabled


func _on_clear_all_button_pressed():
	for unit in _get_requested_units():
		var action_caption = unit.find_child("ActionCaption", true, false)
		if action_caption != null:
			action_caption.queue_free()
		var movement_trait = unit.find_child("Movement")
		if movement_trait != null:
			movement_trait.debug_enabled = false
