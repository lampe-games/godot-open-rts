extends Node

# requests
signal deselect_all  # TODO: rename to deselect_all_units
signal setup_and_spawn_unit(unit, transform, player_id)

# notifications
signal terrain_targeted(position)
signal unit_targeted(unit)
signal unit_selected(unit)
signal unit_deselected(unit)
signal controlled_player_changed(player_id)
