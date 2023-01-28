extends Node


func _to_string():
	var action_script_path = get_script().resource_path
	var action_file_name = action_script_path.substr(action_script_path.rfind("/") + 1)
	var action_name = action_file_name.split(".")[0]
	return action_name
