extends PanelContainer

@onready var _match = find_parent("Match")

@onready var _controlled_player = find_child("ControlledPlayerSpinBox")


func _ready():
	await _match.ready
	_controlled_player.value = get_tree().get_nodes_in_group("players").find(
		_match.controlled_player
	)
	_controlled_player.value_changed.connect(_on_controlled_player_spin_box_value_changed)


func _on_controlled_player_spin_box_value_changed(value):
	var players = get_tree().get_nodes_in_group("players")
	_match.controlled_player = (players[value] if value >= 0 and value < players.size() else null)
