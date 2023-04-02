extends "res://source/match/units/Unit.gd"

var resource_a = 0
var resource_b = 0
var resources_max = null


func is_full():
	assert(resource_a + resource_b <= resources_max, "worker capacity was exceeded somehow")
	return resource_a + resource_b == resources_max
