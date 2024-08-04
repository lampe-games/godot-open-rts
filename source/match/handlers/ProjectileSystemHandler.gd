extends Node3D

@export var num_projectiles = 1000

const Terrain = preload("res://source/match/Terrain.gd")
const Unit = preload("res://source/match/units/Unit.gd")

@onready var Particles = $GPUParticles3D

class Projectile:
	var pos :Vector3
	var previous_pos :Vector3
	var normal :Vector3
	var damage :Unit
	var speed :float
	
	static func new_with_pos(pos :Vector3, dir :Vector3) -> Projectile:
		var new_projectile = Projectile.new()
		new_projectile.pos = pos
		new_projectile.normal = dir.normalized()
		new_projectile.previous_pos = pos - new_projectile.normal
		return new_projectile



var _projectile_queue = PackedInt32Array()
var _projectile_active = PackedInt32Array()
var _projectile_speed = PackedInt32Array()
var _projectile_pos = PackedVector3Array()
var _projectile_previous_pos = PackedVector3Array()
var _projectile_normals = PackedVector3Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	_projectile_normals.resize(num_projectiles)
	_projectile_queue.resize(num_projectiles)
	for i in range(0,num_projectiles):
		_projectile_queue[i]=i
	_projectile_pos.resize(num_projectiles)
	_projectile_previous_pos.resize(num_projectiles)
	_projectile_speed.resize(num_projectiles)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_work_active_projectiles(delta)
	_update_shader(delta)

func _register_Projectile(projectile):
	if _projectile_queue.size() < 1:
		# no space for new projectiles
		print("_projectile_queue empty, cannot register projectile")
		return
	
	var idx = _projectile_queue[_projectile_queue.size()-1]
	_projectile_queue.remove_at(_projectile_queue.size()-1)
	_projectile_active.append(idx)
	
	_projectile_pos[idx] = projectile.pos
	_projectile_previous_pos[idx] = projectile.previous_pos
	_projectile_normals[idx] = projectile.normal
	_projectile_speed[idx] = projectile.speed

func _unregister_Projectile(projectileIdx):
	_projectile_active.remove_at(_projectile_active.find(projectileIdx))
	_projectile_queue.append(projectileIdx)

func _work_active_projectiles(delta):
	var unregister_marked = []
	for proj in range(0, _projectile_active.size()):
		var idx = _projectile_active[proj]
		var collition = _check_collision(idx, delta)
		if not collition:
			_projectile_previous_pos[idx] = _projectile_pos[idx]
			_projectile_pos[idx] += _projectile_normals[idx] * _projectile_speed[idx] * delta
		else:
			unregister_marked.append(idx)
	
	for idx in unregister_marked:
		_unregister_Projectile(idx)

func _check_collision(idx, delta):
	var origin = _projectile_pos[idx]
	var normal = _projectile_normals[idx]
	
	var step_range = _projectile_speed[idx] * delta # *1.0001
		
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin,
				global_position + normal * step_range)
	var collision = space_state.intersect_ray(query)
	return collision

func _update_shader(delta):
	Particles.process_material.set_shader_parameter("projectile_pos", _projectile_pos)
	Particles.process_material.set_shader_parameter("projectile_previous_pos", _projectile_previous_pos)
	Particles.process_material.set_shader_parameter("projectile_active", _projectile_active)
