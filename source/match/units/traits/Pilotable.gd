extends Node3D

const Pilot = preload("res://source/match/units/Pilot.gd")
const CommandCenter = preload("res://source/match/units/CommandCenter.gd")

@onready var _unit = get_parent()
@onready var _movement = _unit.find_child("Movement")
@onready var _area = find_child("Area3D")
@onready var _UI = find_parent("Match").find_child("PlayMode")
@onready var _SH = find_parent("Match").find_child("PlayModeSwitchHandler")

func _ready():
	print("setup pilotable")
	if _unit is Pilot:
		_area.connect("area_entered", _on_area_entered)
		_area.connect("area_exited", _on_area_exited)
		print("pilot connected")
	
func _on_area_entered(area):
	if area == _unit or area.player != Globals.player:
		return
	if area.find_child("Pilotable") != null:
		_SH.pilotable = area
		_UI.find_child("Pilotable").text = "Pilotable: "+str(area)
	elif area is CommandCenter:
		_SH.command_center = area
		_UI.find_child("CC").text = "CommandCenter: "+str(area)

func _on_area_exited(area):
	if area == _SH.pilotable:
		_SH.pilotable = null
		_UI.find_child("Pilotable").text = "Pilotable: "
	elif area == _SH.command_center:
		_SH.command_center = null
		_UI.find_child("CC").text = "CommandCenter: "
