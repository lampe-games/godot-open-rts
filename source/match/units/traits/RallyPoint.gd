extends Node3D

@onready var _unit   = get_parent()

func _ready():
	get_node("AnimationPlayer").play("idle")

func _process(_delta):
	visible = _unit.is_in_group("selected_units")
