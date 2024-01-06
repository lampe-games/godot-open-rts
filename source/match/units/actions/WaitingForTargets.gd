extends "res://source/match/units/actions/Action.gd"

const AttackingWhileInRange = preload("res://source/match/units/actions/AttackingWhileInRange.gd")
const AutoAttacking = preload("res://source/match/units/actions/AutoAttacking.gd")

const REFRESH_INTERVAL = 1.0 / 60.0 * 10.0

var _timer = null
var _sub_action = null

@onready var _unit = Utils.NodeEx.find_parent_with_group(self, "units")


func _ready():
	_timer = Timer.new()
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	_timer.start(REFRESH_INTERVAL)


func _to_string():
	return "{0}({1})".format([super(), str(_sub_action) if _sub_action != null else ""])


func is_idle():
	return _sub_action == null


func _get_units_to_attack():
	return get_tree().get_nodes_in_group("units").filter(
		func(unit): return (
			unit.player != _unit.player
			and unit.movement_domain in _unit.attack_domains
			and (_unit.location.distance_to(unit.location) <= _unit.sight_range)
		)
	)


func _attack_unit(unit):
	_timer.timeout.disconnect(_on_timer_timeout)
	_sub_action = (
		AutoAttacking.new(unit) if _unit.movement_speed > 0.0 else AttackingWhileInRange.new(unit)
	)
	_sub_action.tree_exited.connect(_on_attack_finished)
	add_child(_sub_action)
	_unit.action_updated.emit()


func _on_timer_timeout():
	var units_to_attack = _get_units_to_attack()
	if not units_to_attack.is_empty():
		var dist = _unit.sight_range
		var target_unit = units_to_attack[0]
		for unit in units_to_attack:
			if unit.location.distance_to(_unit.location) < dist:
				target_unit = unit
				dist = unit.location.distance_to(_unit.location)
		_attack_unit(target_unit)


func _on_attack_finished():
	if not is_inside_tree():
		return
	_sub_action = null
	_unit.action_updated.emit()
	_timer.timeout.connect(_on_timer_timeout)
