extends "res://source/match/units/actions/Action.gd"

const AttackingWhileInRange = preload("res://source/match/units/actions/AttackingWhileInRange.gd")

const REFRESH_INTERVAL = 1.0 / 60.0 * 10.0

var _target_domains = []
var _timer = null
var _sub_action = null

@onready var _unit = get_parent()


func _init(_domains):
	_target_domains = _domains


func _ready():
	_timer = Timer.new()
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	_timer.start(REFRESH_INTERVAL)


func _exit_tree():
	if _sub_action != null:
		_sub_action.queue_free()


func _to_string():
	return "{0}({1})".format([super(), str(_sub_action) if _sub_action != null else ""])


func _get_units_to_attack():
	var self_position_yless = _unit.global_position * Vector3(1, 0, 1)
	return get_tree().get_nodes_in_group("units").filter(
		func(unit): return (
			unit.player_id != _unit.player_id
			and unit.movement_domain in _target_domains
			and (
				self_position_yless.distance_to(unit.global_position * Vector3(1, 0, 1))
				<= _unit.attack_range
			)
		)
	)


func _attack_unit(unit):
	_timer.timeout.disconnect(_on_timer_timeout)
	_sub_action = AttackingWhileInRange.new(unit)
	_sub_action.tree_exited.connect(_on_attack_finished)
	_unit.add_child(_sub_action)
	_unit.action_updated.emit()


func _on_timer_timeout():
	var units_to_attack = _get_units_to_attack()
	if not units_to_attack.is_empty():
		_attack_unit(units_to_attack.pick_random())


func _on_attack_finished():
	_sub_action = null
	_unit.action_updated.emit()
	_timer.timeout.connect(_on_timer_timeout)
