extends PanelContainer

var _watched_player = null

@onready var _resource_a_label = find_child("ResourceALabel")
@onready var _resource_b_label = find_child("ResourceBLabel")
@onready var _resource_a_color_rect = find_child("ResourceAColorRect")
@onready var _resource_b_color_rect = find_child("ResourceBColorRect")


func _ready():
	_resource_a_color_rect.color = Constants.Match.Resources.A.COLOR
	_resource_b_color_rect.color = Constants.Match.Resources.B.COLOR
	MatchSignals.controlled_player_changed.connect(_on_controlled_player_changed)


func _on_controlled_player_changed(player):
	if _watched_player != null:
		_watched_player.changed.disconnect(_on_player_changed)
		_watched_player = null
	if player == null:
		_resource_a_label.text = "N/A"
		_resource_b_label.text = "N/A"
		return
	_watched_player = player
	_on_player_changed(_watched_player)
	_watched_player.changed.connect(_on_player_changed.bind(_watched_player))


func _on_player_changed(player):
	_resource_a_label.text = str(player.resource_a)
	_resource_b_label.text = str(player.resource_b)
