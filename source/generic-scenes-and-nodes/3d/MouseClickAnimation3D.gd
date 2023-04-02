extends Node3D
@onready var _animation_player = find_child("AnimationPlayer")


func _ready():
	_animation_player.animation_finished.connect(_on_animation_finished)
	_animation_player.play("fade_out")


func _on_animation_finished(_animation):
	queue_free()
