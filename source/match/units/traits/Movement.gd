extends NavigationAgent3D

signal movement_finished

const INITIAL_DISPERSION_FACTOR = 0.1

@export var domain = Constants.Match.Navigation.Domain.TERRAIN
@export var speed: float = 4.0

var _interim_speed: float = 0.0

@onready var _match = find_parent("Match")
@onready var _unit = get_parent()


func _physics_process(delta):
	_interim_speed = speed * delta
	var next_path_position: Vector3 = get_next_path_position()
	var current_agent_position: Vector3 = _unit.global_transform.origin
	var new_velocity: Vector3 = (
		(next_path_position - current_agent_position).normalized() * _interim_speed
	)
	set_velocity(new_velocity)


func _ready():
	if _match.navigation == null:
		await _match.ready
	max_neighbors = 100  # TODO: set dynamically
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
		- Vector3(0, agent_height_offset, 0)
	)


func _on_velocity_computed(safe_velocity: Vector3):
	var direction = safe_velocity
	var rotation_target = _unit.global_transform.origin + direction
	if (
		not is_zero_approx(direction.length())
		and not rotation_target.is_equal_approx(_unit.global_transform.origin)
		and not (
			is_zero_approx(direction.x)
			and not is_zero_approx(direction.y)
			and is_zero_approx(direction.z)
		)
	):
		_unit.global_transform = _unit.global_transform.looking_at(rotation_target)
	_unit.global_transform.origin = _unit.global_transform.origin.move_toward(
		_unit.global_transform.origin + safe_velocity, _interim_speed
	)


func _on_navigation_finished():
	target_position = Vector3.INF
	movement_finished.emit()
