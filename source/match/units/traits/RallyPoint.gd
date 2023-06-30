extends Node3D

@onready var _unit = get_parent()
@onready var _animation_player = find_child("AnimationPlayer")


func _ready():
	_animation_player.play("idle")


func _process(_delta):
	# TODO: calculate based on signals to avoid polling
	visible = _unit.is_in_group("selected_units")
