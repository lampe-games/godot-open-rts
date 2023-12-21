extends Node

@onready var _player = find_child("AudioStreamPlayer")


func _ready():
	MatchSignals.unit_died.connect(_on_unit_died)


func _handle_event(event):
	_player.stream = Constants.Match.VoiceNarrator.EVENT_TO_ASSET_MAPPING[event]
	_player.play()


func _on_unit_died(unit):
	if unit.is_in_group("controlled_units"):
		_handle_event(Constants.Match.VoiceNarrator.Events.UNIT_LOST)
