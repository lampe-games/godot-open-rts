extends "res://source/match/units/actions/Action.gd"

const AttackingWhileInRange = preload("res://source/match/units/actions/AttackingWhileInRange.gd")
const FollowingToReachDistance = preload(
	"res://source/match/units/actions/FollowingToReachDistance.gd"
)

var _target_unit = null
var _sub_action = null
@onready var _unit = Utils.NodeEx.find_parent_with_group(self, "units")


static func is_applicable(source_unit, target_unit):
	return (
		source_unit.attack_range != null
		and "player" in target_unit
		and source_unit.player != target_unit.player
		and target_unit.movement_domain in source_unit.attack_domains
	)


func _init(target_unit):
	_target_unit = target_unit


func _ready():
	_target_unit.tree_exited.connect(_on_target_unit_removed)
	_attack_or_move_closer()


func _to_string():
	return "{0}({1})".format([super(), str(_sub_action) if _sub_action != null else ""])


func _target_in_range():
	return (
		_unit.global_position_yless.distance_to(_target_unit.global_position_yless)
		<= _unit.attack_range
	)


func _attack_or_move_closer():
	_sub_action = (
		AttackingWhileInRange.new(_target_unit)
		if _target_in_range()
		else FollowingToReachDistance.new(_target_unit, _unit.attack_range)
	)
	_sub_action.tree_exited.connect(_on_sub_action_finished)
	add_child(_sub_action)
	_unit.action_updated.emit()


func _on_target_unit_removed():
	queue_free()


func _on_sub_action_finished():
	if not is_inside_tree():
		return
	if not _target_unit.is_inside_tree():
		return
	_attack_or_move_closer()
