extends "res://source/match/units/Unit.gd"

signal constructed

const UnderConstructionTrait = preload("res://source/match/units/traits/UnderConstruction.tscn")

@onready var _unit = get_parent()


func mark_as_under_construction():
	add_child(UnderConstructionTrait.instantiate())


func is_constructed():
	return _unit.find_child("UnderConstruction", true, false) == null


func emit_constructed():
	constructed.emit()
