extends PanelContainer

@onready var _generic_menu = find_child("GenericMenu")


func _ready():
	_reset_menus()
	MatchSignals.unit_selected.connect(func(_unit): _reset_menus())
	MatchSignals.unit_deselected.connect(func(_unit): _reset_menus())


func _reset_menus():
	_hide_all_menus()
	if _try_showing_any_menu():
		show()
	else:
		hide()


func _hide_all_menus():
	_generic_menu.hide()


func _try_showing_any_menu():
	var selected_controlled_units = _get_selected_controlled_units()
	if selected_controlled_units.size() > 0:
		_generic_menu.units = selected_controlled_units
		_generic_menu.show()
		return true
	return false


func _get_selected_controlled_units():
	var units = []
	for unit in get_tree().get_nodes_in_group("selected_units"):
		if unit.is_in_group("controlled_units"):
			units.append(unit)
	return units
