extends Node

# requests
signal deselect_all_units
signal setup_and_spawn_unit(unit, transform, player)
signal place_structure(structure_prototype)
signal schedule_navigation_rebake(domain)
signal navigate_unit_to_rally_point(unit, rally_point)  # currently, only for human players

# notifications
signal match_started
signal match_aborted
signal match_finished_with_victory
signal match_finished_with_defeat
signal terrain_targeted(position)
signal unit_spawned(unit)
signal unit_targeted(unit)
signal unit_selected(unit)
signal unit_deselected(unit)
signal unit_damaged(unit)
signal unit_died(unit)
signal unit_production_started(unit_prototype, producer_unit)
signal unit_production_finished(unit, producer_unit)
signal unit_construction_finished(unit)
signal not_enough_resources_for_production(player)
signal not_enough_resources_for_construction(player)
