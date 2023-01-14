extends Label3D

@onready var _unit = get_parent()


func _ready():
	_on_action_changed(_unit.action)
	_unit.action_changed.connect(_on_action_changed)


func _on_action_changed(new_action):
	if new_action == null:
		text = ""
	else:
		var action_script_path = _unit.action.script.resource_path
		var action_file_name = action_script_path.substr(action_script_path.rfind("/") + 1)
		var action_name = action_file_name.split(".")[0]
		text = action_name
