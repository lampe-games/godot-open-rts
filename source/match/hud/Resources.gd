extends VBoxContainer

@onready var _match = find_parent("Match")


func _ready():
	await find_parent("Match").ready
	_hide_all_bars()
	_setup_all_bars()
	if _match.settings.visibility == _match.settings.Visibility.PER_PLAYER:
		MatchSignals.controlled_player_changed.connect(_on_controlled_player_changed)
		_show_player_bars([_match.controlled_player])
	else:
		_show_player_bars(_match.players)


func _hide_all_bars():
	for bar in get_children():
		bar.hide()


func _setup_all_bars():
	var bar_nodes = get_children()
	for i in range(_match.players.size()):
		bar_nodes[i].setup(_match.players[i])


func _show_player_bars(players):
	for player in players:
		for bar_node in get_children():
			if bar_node.player == player:
				bar_node.show()


func _on_controlled_player_changed(player):
	_hide_all_bars()
	_show_player_bars([player])
