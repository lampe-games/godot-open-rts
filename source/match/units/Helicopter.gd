extends "res://source/match/units/Unit.gd"

const ROTOR_SPEED = 800.0  # degrees/s

const WaitingForTargets = preload("res://source/match/units/actions/WaitingForTargets.gd")


func _ready():
	await super()
	action_changed.connect(_on_action_changed)
	action = WaitingForTargets.new()


func _physics_process(delta):
	find_child("Rotor").rotation_degrees.y += ROTOR_SPEED * delta


func _on_action_changed(new_action):
	if new_action == null:
		action = WaitingForTargets.new()
