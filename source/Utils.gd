extends Node

const Match = preload("res://source/match/MatchUtils.gd")


class Set:
	extends "res://source/utils/Set.gd"

	static func from_array(array):
		var a_set = Set.new()
		for item in array:
			a_set.add(item)
		return a_set

	static func subtracted(minuend, subtrahend):
		var difference = Set.new()
		for item in minuend.iterate():
			if not subtrahend.has(item):
				difference.add(item)
		return difference


class Dict:
	static func items(d):
		var pairs = []
		for k in d:
			pairs.append([k, d[k]])
		return pairs
