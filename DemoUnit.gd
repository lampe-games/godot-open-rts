extends CharacterBody3D

var attack_range = 8
var projectile_speed = 10
var attack_damage = 2
var speed = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	find_child("DirectMovement").piloted = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


