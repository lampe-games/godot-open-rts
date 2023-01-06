@tool
extends Node2D

@export var color = Color.WHITE
@export var radius = 15


func _draw():
	draw_circle(Vector2(0, 0), radius, color)
