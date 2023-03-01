extends "res://source/match/Match.gd"

@export var allow_resources_deficit_spending = true


func _ready():
	FeatureFlags.allow_resources_deficit_spending = allow_resources_deficit_spending
	super()
