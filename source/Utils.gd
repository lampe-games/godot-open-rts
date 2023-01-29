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


class Float:
	static func is_equal_approx_with_epsilon(a: float, b: float, epsilon):
		return abs(a - b) <= epsilon


class Colour:
	static func is_equal_approx_with_epsilon(a: Color, b: Color, epsilon: float):
		return (
			Float.is_equal_approx_with_epsilon(a.r, b.r, epsilon)
			and Float.is_equal_approx_with_epsilon(a.g, b.g, epsilon)
			and Float.is_equal_approx_with_epsilon(a.b, b.b, epsilon)
		)


class NodeEx:
	static func find_parent_with_group(node, group_for_parent_to_be_in):
		var ancestor = node.get_parent()
		while ancestor != null:
			if ancestor.is_in_group(group_for_parent_to_be_in):
				return ancestor
			ancestor = ancestor.get_parent()
		return null
