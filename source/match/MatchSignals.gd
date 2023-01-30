extends Node

# requests
signal deselect_all_units
signal setup_and_spawn_unit(unit, transform, player)
signal place_building(building_prototype)

# notifications
signal terrain_targeted(position)
signal unit_targeted(unit)
signal unit_selected(unit)
signal unit_deselected(unit)
signal unit_died(unit)
signal controlled_player_changed(player)
