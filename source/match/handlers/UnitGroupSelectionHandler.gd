extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("unit_groups_set_1"):
		set_group(1)
	elif event.is_action_pressed("unit_groups_set_2"):
		set_group(2)
	elif event.is_action_pressed("unit_groups_set_3"):
		set_group(3)
	elif event.is_action_pressed("unit_groups_set_4"):
		set_group(4)
	elif event.is_action_pressed("unit_groups_set_5"):
		set_group(5)
	elif event.is_action_pressed("unit_groups_set_6"):
		set_group(6)
	elif event.is_action_pressed("unit_groups_set_7"):
		set_group(7)
	elif event.is_action_pressed("unit_groups_set_8"):
		set_group(8)
	elif event.is_action_pressed("unit_groups_set_9"):
		set_group(9)
	elif event.is_action_pressed("unit_groups_access_1"):
		access_group(1)
	elif event.is_action_pressed("unit_groups_access_2"):
		access_group(2)
	elif event.is_action_pressed("unit_groups_access_3"):
		access_group(3)
	elif event.is_action_pressed("unit_groups_access_4"):
		access_group(4)
	elif event.is_action_pressed("unit_groups_access_5"):
		access_group(5)
	elif event.is_action_pressed("unit_groups_access_6"):
		access_group(6)
	elif event.is_action_pressed("unit_groups_access_7"):
		access_group(7)
	elif event.is_action_pressed("unit_groups_access_8"):
		access_group(8)
	elif event.is_action_pressed("unit_groups_access_9"):
		access_group(9)

func access_group(group_id:int):
	var unit_group = Utils.Set.new()
	for unit in get_tree().get_nodes_in_group("unit_group_"+str(group_id)):
		if unit != null:
			unit_group.add(unit)
	Utils.Match.select_units(unit_group)
	
	
func set_group(group_id:int):
	for unit in get_tree().get_nodes_in_group("unit_group_"+str(group_id)):
		unit.remove_from_group("unit_group_"+str(group_id))
	var unit_group = get_tree().get_nodes_in_group("selected_units")
	for unit in unit_group:
		if unit.is_in_group("controlled_units"):
			unit.add_to_group("unit_group_"+str(group_id))
