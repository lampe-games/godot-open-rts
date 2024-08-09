extends "res://source/match/Map.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	find_child("Terrain3D").material.world_background = Terrain3DMaterial.WorldBackground.NONE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
