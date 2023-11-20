extends NavigationAgent3D

signal movement_finished
signal passive_movement_started
signal passive_movement_finished

const INITIAL_DISPERSION_FACTOR = 0.1

const STUCK_PREVENTION_ENABLED = true
const STUCK_PREVENTION_WINDOW_SIZE = 10  # number of frames for accumulating distance traveled
const STUCK_PREVENTION_THRESHOLD = 0.3  # fraction of expected distance traveled at full speed
const STUCK_PREVENTION_SIDE_MOVES = 15  # number of forced moves to the side if stuck

const ROTATION_LOW_PASS_FILTER_ENABLED = true
const ROTATION_LOW_PASS_FILTER_WINDOW_SIZE = 10  # number of frames for accumulating directions
const ROTATION_LOW_PASS_FILTER_VELOCITY_THRESHOLD = 0.01  # velocities below will be dropped

const PASSIVE_MOVEMENT_TRACKING_ENABLED = true

@export var domain = Constants.Match.Navigation.Domain.TERRAIN
@export var speed: float = 4.0

var _interim_speed: float = 0.0

var _stuck_prevention_window = []
var _total_velocity_in_stuck_prevention_window = 0.0
var _number_of_forced_side_moves_left = 0

var _rotation_low_pass_filter_window = []
var _total_direction_in_the_low_pass_filter_window = Vector3.ZERO
var _previously_set_global_transform_of_unit = null

var _passive_movement_detected = false

@onready var _match = find_parent("Match")
@onready var _unit = get_parent()


func _physics_process(delta):
	_interim_speed = speed * delta
	var fake_direction = _get_fake_direction_due_to_stuck_prevention()
	if fake_direction != null:
		set_velocity(fake_direction * _interim_speed)
		return
	var next_path_position: Vector3 = get_next_path_position()
	var current_agent_position: Vector3 = _unit.global_transform.origin
	var new_velocity: Vector3 = (
		(next_path_position - current_agent_position).normalized() * _interim_speed
	)
	set_velocity(new_velocity)


func _ready():
	if _match.navigation == null:
		await _match.ready
	velocity_computed.connect(_on_velocity_computed)
	navigation_finished.connect(_on_navigation_finished)
	set_navigation_map(_match.navigation.get_navigation_map_rid_by_domain(domain))
	_align_unit_position_to_navigation()
	move(
		(
			_unit.global_position
			+ Vector3(randf(), 0, randf()).normalized() * INITIAL_DISPERSION_FACTOR
		)
	)


func move(movement_target: Vector3):
	target_position = movement_target


func stop():
	target_position = Vector3.INF


func _align_unit_position_to_navigation():
	await get_tree().process_frame  # wait for navigation to be operational
	_unit.global_transform.origin = (
		NavigationServer3D.map_get_closest_point(
			get_navigation_map(), get_parent().global_transform.origin
		)
		- Vector3(0, path_height_offset, 0)
	)


func _is_moving_actively():
	return get_next_path_position() != _unit.global_position


func _get_fake_direction_due_to_stuck_prevention():
	if (
		not STUCK_PREVENTION_ENABLED
		or not _is_moving_actively()
		or _number_of_forced_side_moves_left == 0
	):
		return null
	_number_of_forced_side_moves_left -= 1
	var next_path_position: Vector3 = get_next_path_position()
	var direction_to_target = (next_path_position - _unit.global_position).normalized()
	var current_navigation_path = get_current_navigation_path()
	var current_navigation_path_index = get_current_navigation_path_index()
	if current_navigation_path.size() <= 1 or current_navigation_path_index == 0:
		return direction_to_target.rotated(Vector3.UP, PI / 2.0)
	# rotate +90*/-90* and choose the one that goes further from path
	var option_a = direction_to_target.rotated(Vector3.UP, PI / 2.0)
	var option_b = direction_to_target.rotated(Vector3.UP, -PI / 2.0)
	var previous_path_position = current_navigation_path[current_navigation_path_index - 1]
	if (
		(_unit.global_position + option_a).distance_to(previous_path_position)
		> (_unit.global_position + option_b).distance_to(previous_path_position)
	):
		return option_a
	return option_b


func _update_stuck_prevention(safe_velocity: Vector3):
	if not _is_moving_actively():
		return
	_stuck_prevention_window.append(safe_velocity.length())
	_total_velocity_in_stuck_prevention_window += safe_velocity.length()
	if _stuck_prevention_window.size() > STUCK_PREVENTION_WINDOW_SIZE:
		_total_velocity_in_stuck_prevention_window -= _stuck_prevention_window.pop_front()
	var stuck_prevention_threshold = (
		_interim_speed * STUCK_PREVENTION_WINDOW_SIZE * STUCK_PREVENTION_THRESHOLD
	)
	if (
		_stuck_prevention_window.size() == STUCK_PREVENTION_WINDOW_SIZE
		and _total_velocity_in_stuck_prevention_window < stuck_prevention_threshold
	):
		_number_of_forced_side_moves_left = STUCK_PREVENTION_SIDE_MOVES


func _get_filtered_rotation_direction(safe_velocity: Vector3):
	var direction = safe_velocity.normalized()
	if (
		_previously_set_global_transform_of_unit != null
		and not _previously_set_global_transform_of_unit.is_equal_approx(_unit.global_transform)
	):
		# reset filter if a global_transform of unit was altered from the outside
		_rotation_low_pass_filter_window = []
		_total_direction_in_the_low_pass_filter_window = Vector3.ZERO
	if safe_velocity.length() >= ROTATION_LOW_PASS_FILTER_VELOCITY_THRESHOLD:
		_rotation_low_pass_filter_window.append(direction)
		_total_direction_in_the_low_pass_filter_window += direction
	if _rotation_low_pass_filter_window.size() > ROTATION_LOW_PASS_FILTER_WINDOW_SIZE:
		_total_direction_in_the_low_pass_filter_window -= (
			_rotation_low_pass_filter_window.pop_front()
		)
	if _rotation_low_pass_filter_window.size() == ROTATION_LOW_PASS_FILTER_WINDOW_SIZE:
		return (
			_total_direction_in_the_low_pass_filter_window
			/ float(ROTATION_LOW_PASS_FILTER_WINDOW_SIZE)
		)
	return direction


func _rotate_in_direction(direction: Vector3):
	if ROTATION_LOW_PASS_FILTER_ENABLED:
		direction = _get_filtered_rotation_direction(direction)
	var rotation_target = _unit.global_transform.origin + direction
	if (
		not is_zero_approx(direction.length())
		and not rotation_target.is_equal_approx(_unit.global_transform.origin)
	):
		_unit.global_transform = _unit.global_transform.looking_at(rotation_target)


func _update_passive_movement_tracking(safe_velocity):
	if not PASSIVE_MOVEMENT_TRACKING_ENABLED:
		return
	if _is_moving_actively() or safe_velocity.is_zero_approx():
		if _passive_movement_detected:
			_passive_movement_detected = false
			passive_movement_finished.emit()
		return
	if not _passive_movement_detected:
		_passive_movement_detected = true
		passive_movement_started.emit()


func _on_velocity_computed(safe_velocity: Vector3):
	_update_stuck_prevention(safe_velocity)
	_rotate_in_direction(safe_velocity * Vector3(1, 0, 1))
	_unit.global_transform.origin = _unit.global_transform.origin.move_toward(
		_unit.global_transform.origin + safe_velocity, _interim_speed
	)
	_previously_set_global_transform_of_unit = _unit.global_transform
	_update_passive_movement_tracking(safe_velocity)


func _on_navigation_finished():
	target_position = Vector3.INF
	movement_finished.emit()
