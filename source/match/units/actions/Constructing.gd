extends "res://source/match/units/actions/Action.gd"

const Worker = preload("res://source/match/units/Worker.gd")
const Structure = preload("res://source/match/units/Structure.gd")
const MovingToUnit = preload("res://source/match/units/actions/MovingToUnit.gd")
const ConstructingWhileInRange = preload(
	"res://source/match/units/actions/ConstructingWhileInRange.gd"
)

var _target_unit = null
var _sub_action = null

@onready var _unit = Utils.NodeEx.find_parent_with_group(self, "units")


static func is_applicable(source_unit, target_unit):
	return (
		source_unit is Worker
		and target_unit is Structure
		and not target_unit.is_constructed()
		and source_unit.player == target_unit.player
	)


func _init(target_unit):
	_target_unit = target_unit
	_target_unit.constructed.connect(_on_target_unit_constructed)


func _ready():
	_construct_or_move_closer()


func _construct_or_move_closer():
	_sub_action = (
		MovingToUnit.new(_target_unit)
		if not Utils.Match.Unit.Movement.units_adhere(_unit, _target_unit)
		else ConstructingWhileInRange.new(_target_unit)
	)
	_sub_action.tree_exited.connect(_on_sub_action_finished)
	add_child(_sub_action)
	_unit.action_updated.emit()


func _to_string():
	return "{0}({1})".format([super(), str(_sub_action) if _sub_action != null else ""])


func _on_sub_action_finished():
	if not is_inside_tree():
		return
	if not is_instance_valid(_target_unit) or not _target_unit.is_inside_tree():
		queue_free()
		return
	_sub_action = null
	_construct_or_move_closer()


func _on_target_unit_constructed():
	if not is_inside_tree():
		return
	_sub_action.tree_exited.disconnect(_on_sub_action_finished)
	queue_free()
