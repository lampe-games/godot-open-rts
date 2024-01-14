@tool
extends StaticBody3D

@export var domain = Constants.Match.Navigation.Domain.TERRAIN
@export var shape: Shape3D = null:
	set(a_shape):
		shape = a_shape
		find_child("CollisionShape3D").shape = shape


func _enter_tree():
	if Engine.is_editor_hint():
		return
	var match = find_parent("Match")
	if not match.is_node_ready():
		await match.ready
	add_to_group(Constants.Match.Navigation.DOMAIN_TO_GROUP_MAPPING[domain])
	MatchSignals.schedule_navigation_rebake.emit(domain)


func _exit_tree():
	if Engine.is_editor_hint():
		return
	remove_from_group(Constants.Match.Navigation.DOMAIN_TO_GROUP_MAPPING[domain])
	MatchSignals.schedule_navigation_rebake.emit(domain)
