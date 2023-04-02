extends Control

const MatchSettings = preload("res://source/model/MatchSettings.gd")
const PlayerSettings = preload("res://source/model/PlayerSettings.gd")
const LoadingScene = preload("res://source/main-menu/Loading.tscn")

@onready var _start_button = find_child("StartButton")


func _ready():
	find_child("OptionButton").item_selected.connect(_on_player_selected.bind(0))
	find_child("OptionButton2").item_selected.connect(_on_player_selected.bind(1))
	find_child("OptionButton3").item_selected.connect(_on_player_selected.bind(2))
	find_child("OptionButton4").item_selected.connect(_on_player_selected.bind(3))


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


func _on_start_button_pressed():
	hide()
	var new_scene = LoadingScene.instantiate()
	new_scene.match_settings = _create_match_settings()
	get_parent().add_child(new_scene)
	get_tree().current_scene = new_scene
	queue_free()


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://source/main-menu/Main.tscn")


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
