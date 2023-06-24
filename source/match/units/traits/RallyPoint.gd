extends Node3D

@onready var _unit = get_parent()
@onready var _line = get_node("Line")
@onready var _marker = get_node("Marker")


func _ready():
	get_node("AnimationPlayer").play("idle")


func _process(_delta):
	visible = _unit.is_in_group("selected_units")
