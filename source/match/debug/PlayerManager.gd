extends MarginContainer

@onready var _match = find_parent("Match")

@onready var _controlled_player = find_child("ControlledPlayerSpinBox")
@onready var _visible_player = find_child("ControlledPlayerSpinBox")


func _ready():
	await _match.ready
	_controlled_player.value = _match.controlled_player_id
	_visible_player.value = _match.visible_player_id


func _on_controlled_player_spin_box_value_changed(value):
	_match.controlled_player_id = value


func _on_visible_player_spin_box_value_changed(value):
	_match.visible_player_id = value
