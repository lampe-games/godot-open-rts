extends Label3D

@onready var _unit = get_parent()


func _ready():
	_on_action_changed(_unit.action)
	_unit.action_changed.connect(_on_action_changed)
	_unit.action_updated.connect(_on_action_updated)


func _on_action_changed(new_action):
	if new_action == null:
		text = ""
	else:
		text = str(new_action)


func _on_action_updated():
	text = str(_unit.action)
