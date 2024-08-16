
var _debug = false

var _dimensions = []
var _slices_width
var _field_size_x
var _field_size_z
var _height_field = []
var _max_heap_class = load("res://source/match/utils/MaxHeap.gd")

func get_field_x_width():
	return _field_size_x

func get_field_z_width():
	return _field_size_x

func get_grid_slice_width():
	return _slices_width

func initialize_by_scanning(
		world_3d,
		min_x, max_x, min_y, max_y, min_z, max_z,
		slices_width
		):
	return initialize_by_scanning_ex(
		world_3d,
		min_x, max_x, min_y, max_y, min_z, max_z,
		slices_width, null, null
	)

func initialize_by_scanning_ex(
		world_3d,
		min_x, max_x, min_y, max_y, min_z, max_z,
		slices_width, terrain_3d_node,
		debug_point_spawn_callback
		):
	if _debug:
		print("HeightMapNavMesh.gd: initialize_by_scanning(): " +
			"will scan now")
	var use_physics_ray = false
	slices_width = max(0.001, slices_width)
	var slices_x = ceil(abs(max_x - min_x) / slices_width)
	var slices_z = ceil(abs(max_z - min_z) / slices_width)
	var space_state = world_3d.direct_space_state
	if _debug:
		print("HeightMapNavMesh.gd: initialize_by_scanning(): " +
			"slice count: " + str(slices_x) + "," + str(slices_z))
	_height_field = PackedFloat32Array()
	var i = 0
	while i < slices_x * slices_z:
		_height_field.append(0.0)
		i += 1
	var posx = min_x
	i = 0
	while i < slices_x:
		if _debug:
			var percentage = i / slices_x
			print("HeightMapNavMesh.gd: initialize_by_scanning(): " +
				"Scan percentage: " + str(percentage))
		var posz = min_z
		var k = 0
		while k < slices_z:
			var origin = Vector3(posx, max(max_z + 1.0, 999999), posz)
			var target = Vector3(posx, min(min_z - 1.0, -999999), posz)
			var height
			if not use_physics_ray:
				height = terrain_3d_node.storage.get_height(
					Vector3(posx, 0, posz)
				)
			else:
				var query = PhysicsRayQueryParameters3D.create(
					origin, target)
				query.set_collision_mask(1)
				query.collide_with_areas = true
				query.collide_with_bodies = true
				query.hit_back_faces = true
				query.hit_from_inside = true
				var collision = space_state.intersect_ray(query)
				height = min_y
				if collision:
					height = collision.position.y
			_height_field[i + k * slices_x] = height
			if debug_point_spawn_callback != null:
				debug_point_spawn_callback.call(
					Vector3(posx, height, posz)
				)
			k += 1
			posz += slices_width
		posx += slices_width
		i += 1
	_dimensions = [min_x, max_x, min_y, max_y, min_z, max_z]
	_slices_width = slices_width
	_field_size_x = slices_x
	_field_size_z = slices_z

func pos_to_offset(pos):
	if typeof(pos) == TYPE_VECTOR2:
		pos = Vector3(pos.x, 0, pos.y)
	var xoffset = min(max(0, round(
		float(pos.x - _dimensions[0]) / float(_slices_width)
	)), _field_size_x - 1)
	var zoffset = min(max(0, round(
		float(pos.z - _dimensions[4]) / float(_slices_width)
	)), _field_size_z - 1)
	return Vector2i(int(xoffset), int(zoffset))

func offset_to_pos_no_height(offset):
	assert(typeof(offset) == TYPE_VECTOR2I)
	var xpos = _dimensions[0] + _slices_width * float(offset.x)
	var zpos = _dimensions[4] + _slices_width * float(offset.y)
	return Vector3(xpos, 0, zpos)

func offset_to_pos(offset):
	var offset_clean_x = \
		max(0, min(_field_size_x - 1, int(round(offset.x))))
	var offset_clean_z = \
		max(0, min(_field_size_z - 1, int(round(offset.y))))
	var pos = offset_to_pos_no_height(Vector2i(offset_clean_x, offset_clean_z))
	pos.y = _height_field[offset_clean_x + offset_clean_z * _field_size_x]
	return pos

static func dir_to_offset(dir):
	if dir == 0:  # Forward
		return Vector2i(1, 0)
	elif dir == 1:  # Forward right
		return Vector2i(1, 1)
	elif dir == 2:  # Right
		return Vector2i(0, 1)
	elif dir == 3:  # Backward right
		return Vector2i(-1, 1)
	elif dir == 4:  # Backward
		return Vector2i(-1, 0)
	elif dir == 5:  # Backward left
		return Vector2i(-1, -1)
	elif dir == 6:  # Left
		return Vector2i(0, -1)
	elif dir == 7:  # Forward left
		return Vector2i(1, -1)
	else:
		OS.alert("invalid direction for dir_to_offset")
		assert(false)

func find_path(passability_check_func,
		start, target):
	return find_path_ex(passability_check_func,
		start, target, true, null)

func find_path_with_max_climb_angle(passability_check_func,
		start, target, angle):
	return find_path_ex(passability_check_func,
		start, target, true, angle)

func find_path_ex(passability_check_func,
		start, target, get_world_coords, max_climb_angle):
	if typeof(start) == TYPE_VECTOR2:
		start = Vector3(start.x, 0, start.y)
	if typeof(target) == TYPE_VECTOR2:
		target = Vector3(target.x, 0, target.y)
	var checkobj = passability_check_func
	const hFactor = 0.7

	var x
	var z
	var _startoffset = pos_to_offset(start)
	x = _startoffset[0]
	z = _startoffset[1]
	var target_x
	var target_z
	var mapWidth = float(_field_size_x)
	var _targetoffset = pos_to_offset(target)
	target_x = max(0, min(_field_size_x - 1, _targetoffset[0]))
	target_z = max(0, min(_field_size_z - 1, _targetoffset[1]))
	if _debug:
		print(
			"HeightMapNavMesh.gd: " +
			"find_path: Will find " +
			"path for " + str(x) + "," + str(z) + " -> " +
			str(target_x) + "," + str(target_z) + " " +
			"with max_climb_angle=" + str(max_climb_angle)
		)

	# Set up a few variables:
	var step_distance = _slices_width
	var _goalIsNonpassableResult = true
	var _passablesrcx = -1
	var _passablesrcy = -1
	var startX = int(_startoffset[0])
	var startZ = int(_startoffset[1])
	x = -1
	while x <= 1:
		z = -1
		while z <= 1:
			if x == z:
				z += 1
				continue
			var srcx = _passablesrcx + target_x
			var srcz = _passablesrcy + target_z
			if srcx < 0 or srcx >= _field_size_x:
				z += 1
				continue
			if srcz < 0 or srcz >= _field_size_z:
				z += 1
				continue
			var src_height = _height_field[
				srcx + srcz * mapWidth
			]
			var target_height = _height_field[
				target_x + target_z * mapWidth
			]
			if passability_check_func == null or \
					passability_check_func.call(
					self, Vector2(srcx, srcz), Vector2(target_x, target_z),
					step_distance, src_height, target_height) != INF:
				if (max_climb_angle == null or
						abs(Vector2(step_distance,
							target_height - src_height).angle()) <
							max_climb_angle):
					_goalIsNonpassableResult = false
					break
			z += 1
		x += 1
	var goalIsNonpassable = _goalIsNonpassableResult
	if _debug:
		print(
			"HeightMapNavMesh.gd: " +
			"find_path: " +
			"Goal not passable: " + str(goalIsNonpassable)
		)
	
	var bestNodeX = int(_startoffset[0])
	var bestNodeZ = int(_startoffset[1])
	var bestNodeScore = (
		Vector2(startX - target_x, startZ - target_z).length()
	)
	var openListHeap = _max_heap_class.new()
	var visitedSet = {}
	visitedSet[startX + startZ * mapWidth] = [
		startX, startZ,
		Vector2(startX - target_x, startZ - target_z).length() + 0,
		startX, startZ
	]

	# Add initial open list entry:
	var i = 0
	while i < 8:
		var offset = dir_to_offset(i)
		var tx = startX + offset[0]
		var tz = startZ + offset[1]
		if tx < 0 or tx >= _field_size_x or \
				tz < 0 or tz >= _field_size_z:
			i += 1
			continue
		var src_height = _height_field[
			startX + startZ * mapWidth
		]
		var target_height = _height_field[
			tx + tz * mapWidth
		]
		var cost = 1.0
		if (max_climb_angle != null and
				abs(Vector2(step_distance,
					target_height - src_height).angle()) >
					max_climb_angle):
			cost = INF
		elif passability_check_func != null:
			cost = passability_check_func.call(
				 self, Vector2(startX, startZ), Vector2(tx, tz),
				 step_distance, src_height, target_height)
		if cost != INF:
			var heuristic = (
				hFactor * cost * (
					Vector2(target_x - tx, target_z - tz).length()) +
				1
			)
			openListHeap.insert(
				[tx, tz, 1, startX, startZ], -heuristic
			)
		i += 1

	var maxRuntime = max(
		100, 0  # FIXME: Make this configurable
	);
	while not openListHeap.is_empty() and maxRuntime > 0:
		var bestDist = -1.0
		var bestHeuristic = -1.0
		var prevCount = null
		var _bestItemDebugScore = null
		if _debug:
			prevCount = openListHeap.count()
			var heapAsList = openListHeap.to_list()
			var i2 = 0
			while i2 < heapAsList.size() - 1:
				if (heapAsList[i2][1] > heapAsList[i2 + 1][1]):
					OS.alert("heap has wrong sorting")
				i2 += 1
			_bestItemDebugScore = -(
				heapAsList[heapAsList.size() - 1][1]
			)
		var openListEntryPair = openListHeap.pop()
		var openListEntry = openListEntryPair[0]
		bestHeuristic = -openListEntryPair[1] * 1.0
		bestDist = openListEntry[2]
		if _debug:
			if openListHeap.count() != prevCount - 1:
				OS.alert("heap pop didn't remove exactly one item! " +
					"old heap size: " + str(prevCount) + ", " +
					"new heap size: " + str(openListHeap.count()))
			if (abs(bestHeuristic - _bestItemDebugScore)
					> 0.00001):
				OS.alert("heap pop didn't yield best scored item")
		maxRuntime -= 1
		if _debug:
			print(
				"HeightMapNavMesh.gd: " +
				"find_path: " +
				"openList chosen -> (x: " +
				str(openListEntry[0]) +
				", y: " + str(openListEntry[1]) +
				", distance: " + str(bestDist) + ", fromX: " +
				str(openListEntry[3]) + ", fromY: " +
				str(openListEntry[4]) + ", combined heuristic: " +
				str(bestHeuristic) + ")"
			)
		x = openListEntry[0]
		z = openListEntry[1]
		if x == startX and z == startZ:
			# Nonsense, don't go there
			continue

		var fromX = openListEntry[3]
		var fromZ = openListEntry[4]
		var dist = bestDist
		var heuristic = bestHeuristic
		if (visitedSet.has(x + z * mapWidth) and
				visitedSet[x + z * mapWidth][2] <= heuristic):
			continue

		var reachedDestination = false;
		# Check if we reached goal, or if goal is not passable
		# then a neighbor of our goal:
		if (x == target_x and z == target_z):
			reachedDestination = true
		elif (goalIsNonpassable and
				((x == target_x and abs(z - target_z) == 1) or
				(z == target_z and abs(x - target_x) == 1))):
			reachedDestination = true

		# Add new open list entries if not at destination yet:
		if not reachedDestination or true:
			var i2 = 0
			while i2 < 8:
				var offset = dir_to_offset(i2)
				var tx = x + offset[0]
				var tz = z + offset[1]
				if tx < 0 or tx >= _field_size_x or \
						tz < 0 or tz >= _field_size_z:
					i2 += 1
					continue
				var src_height = _height_field[
					x + z * mapWidth
				]
				var target_height = _height_field[
					tx + tz * mapWidth
				]
				var cost = 1.0
				if (max_climb_angle != null and
						abs(Vector2(step_distance,
							target_height - src_height).angle()) >
							max_climb_angle):
					cost = INF
				elif passability_check_func != null:
					cost = passability_check_func.call(
						 self, Vector2(x, z), Vector2(tx, tz),
						 step_distance, src_height, target_height)
				if cost != INF:
					var _heuristic = (
						hFactor * cost * (
							Vector2(target_x - tx, target_z - tz).length()) +
						1
					)
					if _debug:
						print("HeightMapNavMesh..gd: " +
							"Adding point to initial open list: " +
							str([tx, tx]))
					openListHeap.insert(
						[tx, tz, Vector2(offset[0], offset[1]).length(),
						x, z], -_heuristic
					)
				i2 += 1
		if _debug:
			var t = ("HeightMapNavMesh.gd: " +
				"find_path: openList entries -> [")
			var heapEntries = openListHeap.to_list()
			var j = 0;
			while j < heapEntries.size():
				if j > 0:
					t += ", "
				t += ("(x: " + str(heapEntries[j][0][0]) +
					", y: " + str(heapEntries[j][0][1]) +
					", dist: " + str(heapEntries[j][0][2]) +
					", heap score: " + str(heapEntries[j][1]) +
					")")
				j += 1
			t += "]"
			print(t)
			t = (
				"HeightMapNavMesh.gd: find_path: " +
				"visitedSet entries -> ["
			);
			var firstEntry = true 
			for key in visitedSet:
				if firstEntry:
					firstEntry = false
				else:
					t += ", "
				t += ("(x: " + str(visitedSet[key][0]) +
					", y: " + str(visitedSet[key][1]) +
					", dist: ???" +
					", heuristic: " + str(visitedSet[key][2]) +
					")")
			t += "]"
			print(t)

		var _visitCost = heuristic
		if reachedDestination:
			_visitCost = 0
		visitedSet[x + z * mapWidth] = [
			x, z, _visitCost, fromX, fromZ
		]
		var plainHeurDist = (
			Vector2(x - target_x, z - target_z).length()
		)
		if reachedDestination or plainHeurDist < bestNodeScore:
			bestNodeScore = plainHeurDist
			if reachedDestination:
				bestNodeScore = 0
			bestNodeX = x
			bestNodeZ = z

		if reachedDestination:
			break

	# Find best visited node to walk back from:
	var bestNodeFromX = (
		visitedSet[bestNodeX + bestNodeZ * mapWidth][3]
	)
	var bestNodeFromZ = (
		visitedSet[bestNodeX + bestNodeZ * mapWidth][4]
	)
	if _debug:
		print(
			"HeightMapNavMesh.gd: find_path: " +
			"going to best node at x: " +
			str(bestNodeX) + ", y: " + str(bestNodeZ)
		)

	var reverse_path = []
	if get_world_coords == true:
		reverse_path.append(offset_to_pos(Vector2i(bestNodeX, bestNodeZ)))
	else:
		reverse_path.append(Vector2i(bestNodeX, bestNodeZ))

	# Walk it back:
	while (bestNodeFromX != startX or bestNodeFromZ != startZ):
		bestNodeX = bestNodeFromX
		bestNodeZ = bestNodeFromZ
		var key = bestNodeX + bestNodeZ * mapWidth
		bestNodeFromX = visitedSet[key][3]
		bestNodeFromZ = visitedSet[key][4]
		if get_world_coords == true:
			reverse_path.append(offset_to_pos(Vector2i(bestNodeX, bestNodeZ)))
		else:
			reverse_path.append(Vector2i(bestNodeX, bestNodeZ))

	# Construct final path in proper order:
	var path = []
	var i3 = reverse_path.size() - 1
	while i3 >= 0:
		path.append(reverse_path[i3])
		i3 -= 1

	if _debug:
		print(
			"HeightMapNavMesh.gd: find_path: " +
			"extracted result: path=" + str(path)
		)
	if (bestNodeFromX != startX or bestNodeFromZ != startZ):
		OS.alert("invalid walk back result")

	# Return extracted way point path
	return path
