extends "res://source/match/Match.gd"

@export var allow_resources_deficit_spending = true


func _ready():
	find_child("MatchEndHandler").queue_free()
	FeatureFlags.allow_resources_deficit_spending = allow_resources_deficit_spending
	super()
