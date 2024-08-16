extends Area3D

const Pilot = preload("res://source/match/units/Pilot.gd")
const CommandCenter = preload("res://source/match/units/CommandCenter.gd")

@onready var _unit = get_parent()
@onready var _area = find_child("Area3D")
@onready var _UI = find_parent("Match").find_child("PlayMode")
@onready var _SH = find_parent("Match").find_child("PlayModeSwitchHandler")

func _ready():
	print("setup pilotable")
	if _unit is Pilot:
		connect("area_entered", _on_area_entered)
		connect("area_exited", _on_area_exited)
		print("pilot connected")
	
func _on_area_entered(area):
	var _other_unit = area.get_parent()
	if _other_unit == _unit or _other_unit.player != Globals.player:
		return
	elif _other_unit is CommandCenter:
		_SH.command_center = _other_unit
		_UI.find_child("CC").text = "CommandCenter: "+str(_other_unit)
	else:
		_SH.pilotable = _other_unit
		_UI.find_child("Pilotable").text = "Pilotable: "+str(_other_unit)

func _on_area_exited(area):
	var _other_unit = area.get_parent()
	if _other_unit == _SH.command_center:
		_SH.command_center = null
		_UI.find_child("CC").text = "CommandCenter: "
	else:
		_SH.pilotable = null
		_UI.find_child("Pilotable").text = "Pilotable: "
