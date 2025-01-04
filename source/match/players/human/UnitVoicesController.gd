extends Node

const Structure = preload("res://source/match/units/Structure.gd")
const ResourceUnit = preload("res://source/match/units/non-player/ResourceUnit.gd")

var _last_ack_event = 0

@onready var _audio_player = find_child("AudioStreamPlayer")
@onready var _player = get_parent()


func _ready() -> void:
	MatchSignals.unit_selected.connect(_on_unit_selected)
	MatchSignals.unit_targeted.connect(_on_unit_action_requsted)
	MatchSignals.terrain_targeted.connect(_on_unit_action_requsted)


func _handle_event(event):
	if _audio_player.playing:
		return
	_audio_player.stream = Constants.Match.VoiceNarrator.EVENT_TO_ASSET_MAPPING[event]
	_audio_player.play()


func _on_unit_selected(unit):
	if not unit is Structure and not unit is ResourceUnit and unit.player == _player:
		_handle_event(Constants.Match.VoiceNarrator.Events.UNIT_HELLO)
	# TODO: handle building - perhaps with some sound instead of voice


func _on_unit_action_requsted(_ignore):
	if get_tree().get_nodes_in_group("selected_units").any(
		func(unit): return not unit is Structure and unit.player == _player
	):
		_handle_event(
			(
				Constants.Match.VoiceNarrator.Events.UNIT_ACK_1
				if _last_ack_event == 0
				else Constants.Match.VoiceNarrator.Events.UNIT_ACK_2
			)
		)
		_last_ack_event = (_last_ack_event + 1) % 2
