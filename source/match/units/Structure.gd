extends "res://source/match/units/Unit.gd"

signal constructed

const UnderConstructionTrait = preload("res://source/match/units/traits/UnderConstruction.tscn")


func mark_as_under_construction():
	assert(find_child("UnderConstruction", true, false) == null)
	add_child(UnderConstructionTrait.instantiate())


func construct():
	var under_construction_trait = find_child("UnderConstruction", true, false)
	assert(under_construction_trait != null)
	if under_construction_trait:
		under_construction_trait.queue_free()


func is_constructed():
	return find_child("UnderConstruction", true, false) == null


func emit_constructed():
	constructed.emit()
