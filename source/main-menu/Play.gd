extends Control

const MatchSettings = preload("res://source/model/MatchSettings.gd")
const PlayerSettings = preload("res://source/model/PlayerSettings.gd")
const LoadingScene = preload("res://source/main-menu/Loading.tscn")

var _map_paths = []

@onready var _start_button = find_child("StartButton")
@onready var _map_list = find_child("MapList")
@onready var _map_details = find_child("MapDetailsLabel")


func _ready():
	_setup_map_list()
	_on_map_list_item_selected(0)
	var option_nodes = find_child("GridContainer").find_children("OptionButton*")
	for option_node_id in range(option_nodes.size()):
		option_nodes[option_node_id].item_selected.connect(_on_player_selected.bind(option_node_id))


func _setup_map_list():
	var maps = Utils.Dict.items(Constants.Match.MAPS)
	maps.sort_custom(func(map_a, map_b): return map_a[1]["players"] < map_b[1]["players"])
	_map_paths = maps.map(func(map): return map[0])
	_map_list.clear()
	for map_path in _map_paths:
		_map_list.add_item(Constants.Match.MAPS[map_path]["name"])
	_map_list.select(0)


func _create_match_settings():
	var match_settings = MatchSettings.new()

	var option_nodes = find_child("GridContainer").find_children("OptionButton*")
	for option_node_id in range(option_nodes.size()):
		var player_controller = option_nodes[option_node_id].selected
		if player_controller != Constants.PlayerController.NONE:
			var player_settings = PlayerSettings.new()
			player_settings.controller = player_controller
			player_settings.color = Constants.Player.COLORS[option_node_id]
			player_settings.spawn_index = option_node_id
			match_settings.players.append(player_settings)

	match_settings.visible_player = -1
	for player_id in range(match_settings.players.size()):
		var player = match_settings.players[player_id]
		if player.controller == Constants.PlayerController.HUMAN:
			match_settings.visible_player = player_id
	if match_settings.visible_player == -1:
		match_settings.visibility = match_settings.Visibility.ALL_PLAYERS

	return match_settings


func _get_selected_map_path():
	return _map_paths[_map_list.get_selected_items()[0]]


func _on_start_button_pressed():
	hide()
	var new_scene = LoadingScene.instantiate()
	new_scene.match_settings = _create_match_settings()
	new_scene.map_path = _get_selected_map_path()
	get_parent().add_child(new_scene)
	get_tree().current_scene = new_scene
	queue_free()


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://source/main-menu/Main.tscn")


func _align_player_controls_visibility_to_map(map):
	var option_nodes = find_child("GridContainer").find_children("OptionButton*")
	var label_nodes = find_child("GridContainer").find_children("Label*")
	assert(option_nodes.size() == label_nodes.size())
	for node_id in range(option_nodes.size()):
		option_nodes[node_id].visible = node_id < map["players"]
		label_nodes[node_id].visible = node_id < map["players"]


func _on_player_selected(selected_option_id, selected_player_id):
	_start_button.disabled = false
	if selected_option_id == Constants.PlayerController.HUMAN:
		var option_nodes = find_child("GridContainer").find_children("OptionButton*")
		for option_node_id in range(option_nodes.size()):
			if (
				option_node_id != selected_player_id
				and option_nodes[option_node_id].selected == Constants.PlayerController.HUMAN
			):
				option_nodes[option_node_id].selected = (
					Constants.PlayerController.SIMPLE_CLAIRVOYANT_AI
				)
	elif selected_option_id == Constants.PlayerController.NONE:
		var option_nodes_with_player_controllers = (
			find_child("GridContainer")
			. find_children("OptionButton*")
			. filter(
				func(option_node): return option_node.selected != Constants.PlayerController.NONE
			)
		)
		if option_nodes_with_player_controllers.size() < 2:
			_start_button.disabled = true


func _on_map_list_item_selected(index):
	var map = Constants.Match.MAPS[_map_paths[index]]
	_map_details.text = "[u]Players:[/u] {0}\n[u]Size:[/u] {1}x{2}".format(
		[map["players"], map["size"].x, map["size"].y]
	)
	_align_player_controls_visibility_to_map(map)
