extends Control

@onready var _animation_player = find_child("AnimationPlayer")


func _ready():
	if not FeatureFlags.show_logos_on_startup:
		queue_free()
		return
	_animation_player.animation_finished.connect(func(_animation_name): queue_free())
	_animation_player.play("animate_logos")


func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		get_viewport().set_input_as_handled()
		
		if _animation_player.current_animation_position < 1.5:
			_animation_player.seek(1.5)
		else:
			queue_free()
