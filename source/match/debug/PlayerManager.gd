extends MarginContainer

@onready var _match = find_parent("Match")

@onready var _controlled_player = find_child("ControlledPlayerSpinBox")
@onready var _visible_player = find_child("ControlledPlayerSpinBox")


func _ready():
	await _match.ready
	_controlled_player.value = _match.players.find(_match.controlled_player)
	_visible_player.value = _match.players.find(_match.visible_player)
	_controlled_player.value_changed.connect(_on_controlled_player_spin_box_value_changed)
	_visible_player.value_changed.connect(_on_visible_player_spin_box_value_changed)


func _on_controlled_player_spin_box_value_changed(value):
	_match.controlled_player = (
		_match.players[value] if value >= 0 and value < _match.players.size() else null
	)


func _on_visible_player_spin_box_value_changed(value):
	_match.visible_player = (
		_match.players[value] if value >= 0 and value < _match.players.size() else null
	)
