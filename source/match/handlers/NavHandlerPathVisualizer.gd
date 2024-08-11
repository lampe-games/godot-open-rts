var _hmnavmesh = null
var _match = null
var _path = null
var _marker_list = null
var _debugmarker = preload("res://source/DebugMarker3D.tscn")

func destroy():
	self.remove_visualization()

func set_nav_mesh(nav_mesh):
	self._hmnavmesh = nav_mesh
	self.update_visualization()

func set_match(game_match):
	_match = game_match
	self.update_visualization()

func set_path(path):
	_path = []
	for item in path:
		_path.append(item)
		self.update_visualization()

func remove_visualization():
	if _marker_list != null:
		for marker in _marker_list:
			marker.get_parent().remove_child(marker)
			marker.queue_free()
		_marker_list = []

func update_visualization():
	if _match == null or _path == null or _hmnavmesh == null:
		return
	
	self.remove_visualization()
	_marker_list = []
	for item in _path:
		var pos = item
		if typeof(item) == TYPE_VECTOR2I:
			# This is likely an internal search grid offset.
			# Translate to world pos first:
			pos = _hmnavmesh.offset_to_pos(item)
		var dm = _debugmarker.instantiate()
		_match.find_child("Units").add_child(dm)
		dm.global_position = pos
		_marker_list.append(dm)
