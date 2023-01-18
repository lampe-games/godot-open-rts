extends "res://source/match/units/Unit.gd"

const ManagingProduction = preload("res://source/match/units/actions/ManagingProduction.gd")

const SIGHT_RANGE = 10.0

var color:
	set(a_color):
		var material = StandardMaterial3D.new()
		material.albedo_color = a_color
		find_child("MeshInstance3D2").material_override = material


func _ready():
	super()
	action = ManagingProduction.new()
