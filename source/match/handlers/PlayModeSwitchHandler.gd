extends Node3D

const PilotScene = preload("res://source/match/units/Pilot.tscn")
const Pilot = preload("res://source/match/units/Pilot.gd")

var pilotable = null
var command_center = null: set = _set_command_center
func _set_command_center(value):
	if value != null:
		_last_command_center = value
	command_center = value

var _last_command_center = null
var _piloted = null
@onready var _match = find_parent("Match")

func _unhandled_input(event):
	if event.is_action_pressed("toggle_play_mode"):
		_toggle_play_mode()

func _toggle_play_mode():
	# playing in FPS
	if Globals.play_mode == Constants.PlayModes.Pilot:
		if _piloted is Pilot:
			# enter ship
			if pilotable != null:
				_piloted.tree_exited.disconnect(enter_command_center)
				_piloted.queue_free()
				pilot_unit(pilotable)
			# enter commandCenter
			elif command_center != null:
				enter_command_center()
				_piloted.queue_free()
		else:
			# exit ship
			var new_pilot = PilotScene.instantiate()
			_match._setup_and_spawn_unit(new_pilot, _piloted.global_transform.translated(Vector3(-1, 0, -1)), Globals.player)
			_piloted.find_child("Movement").piloted = false
			pilot_unit(new_pilot)
			
	# playing as operator
	else:
		# exit commandCenter
		if _last_command_center != null:
			var new_pilot = PilotScene.instantiate()
			_match._setup_and_spawn_unit(new_pilot, _last_command_center.global_transform.translated(Vector3(-1, 0, -1)), Globals.player)
			pilot_unit(new_pilot)
			Globals.play_mode = Constants.PlayModes.Pilot

func pilot_unit(unit):
	unit.find_child("Camera3D").make_current()
	unit.find_child("Movement").piloted = true
	unit.tree_exited.connect(enter_command_center)
	_piloted = unit
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func enter_command_center():
	Globals.play_mode = Constants.PlayModes.Operator
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_match.find_child("IsometricCamera3D").make_current()
