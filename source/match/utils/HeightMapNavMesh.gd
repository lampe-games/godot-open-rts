
var _debug = false

var _dimensions = []
var _slices_width
var _field_size_x
var _field_size_z
var _height_field = []
var _max_heap_class = load("res://source/match/utils/MaxHeap.gd")

func initialize_by_scanning(
		world_3d,
		min_x, max_x, min_y, max_y, min_z, max_z,
		slices_width
		):
	print("will scan now")
	slices_width = max(0.001, slices_width)
	var slices_x = ceil(abs(max_x - min_x) / slices_width)
	var slices_z = ceil(abs(max_z - min_z) / slices_width)
	var space_state = world_3d.direct_space_state
	print("SLICES: " + str(slices_x) + "," + str(slices_z))
	_height_field = []
	var i = 0
	while i < slices_x * slices_z:
		_height_field.append(0.0)
		i += 1
	var posx = min_x
	i = 0
	while i < slices_x:
		var posz = min_z
		var k = 0
		while k < slices_z:
			var origin = Vector3(posx, max_z + 1.0, posz)
			var target = Vector3(posx, min_z - 1.0, posz)
			var query = PhysicsRayQueryParameters3D.create(
				origin, target)
			var collision = space_state.intersect_ray(query)
			var height = min_y
			if collision != null:
				height = collision.y
			_height_field[i + k * slices_x] = height
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
		(pos.x - _dimensions[0]) / _slices_width
	)), _field_size_x)
	var zoffset = min(max(0, round(
		(pos.z - _dimensions[4]) / _slices_width
	)), _field_size_z)
	return [int(xoffset), int(zoffset)]

func offset_to_pos_no_height(offset):
	assert(typeof(offset) == TYPE_ARRAY)
	var xpos = _dimensions[0] + _slices_width * float(offset.x)
	var zpos = _dimensions[4] + _slices_width * float(offset.y)
	return Vector3(xpos, 0, zpos)

func offset_to_pos(offset):
	var offset_clean_x = \
		max(0, min(_field_size_x - 1, int(round(offset[1]))))
	var offset_clean_z = \
		max(0, min(_field_size_z - 1, int(round(offset[2]))))
	var pos = offset_to_pos_no_height([offset_clean_x, offset_clean_z])
	pos.y = _height_field[offset_clean_x + offset_clean_z * _field_size_x]
	return pos

static func dir_to_offset(dir):
	if dir == 0:  # Forward
		return [1, 0]
	elif dir == 1:  # Forward right
		return [1, 1]
	elif dir == 2:  # Right
		return [0, 1]
	elif dir == 3:  # Backward right
		return [-1, 1]
	elif dir == 4:  # Backward
		return [-1, 0]
	elif dir == 5:  # Backward left
		return [-1, -1]
	elif dir == 6:  # Left
		return [0, -1]
	elif dir == 7:  # Forward left
		return [1, -1]
	else:
		OS.alert("invalid direction for dir_to_offset")
		assert(false)

func find_path(passability_check_object,
		start, target, get_world_coords):
	return find_path_ex(passability_check_object,
		start, target, true, null)

func find_path_with_max_climb_angle(passability_check_object,
		start, target, get_world_coords, angle):
	return find_path_ex(passability_check_object,
		start, target, true, angle)

func find_path_ex(passability_check_object,
		start, target, get_world_coords, max_climb_angle):
	if typeof(start) == TYPE_VECTOR2:
		start = Vector3(start.x, 0, start.y)
	if typeof(target) == TYPE_VECTOR2:
		target = Vector3(target.x, 0, target.y)
	var checkobj = passability_check_object
	const hFactor = 0.7

	var x
	var z
	var _offset = pos_to_offset(start)
	x = _offset[0]
	z = _offset[1]
	var target_x
	var target_z
	var mapWidth = float(_field_size_x)
	_offset = pos_to_offset(target)
	target_x = max(0, min(_field_size_x - 1, _offset[0]))
	target_z = max(0, min(_field_size_z - 1, _offset[1]))
	if _debug:
		print(
			"HeightMapNavMesh.gd: " +
			"find_path: Will find " +
			"path for " + str(x) + "," + str(z) + " -> " +
			str(target_x) + "," + str(target_z)
		)

	# Set up a few variables:
	var step_distance = _slices_width
	var _goalIsNonpassableResult = true;
	var _passablesrcx = -1
	var _passablesrcy = -1
	while x <= 1:
		z = - 1
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
			if passability_check_object == null or \
					passability_check_object.check_path_step_cost(
					self, Vector2(srcx, srcz), Vector2(target_x, target_z),
					step_distance, src_height, target_height) != INF:
				if (max_climb_angle == null or
						abs(Vector2(step_distance,
							target_height - src_height).angle()) <
							max_climb_angle):
					_goalIsNonpassableResult = false
					break
		x += 1

	var goalIsNonpassable = _goalIsNonpassableResult
	if _debug:
		print(
			"HeightMapNavMesh.gd: " +
			"find_path: " +
			"Goal not passable: " + str(goalIsNonpassable)
		)
	var startX = x
	var startZ = z
	var bestNodeX = x
	var bestNodeZ = z
	var bestNodeScore = (
		abs(startX - target_x) + abs(startZ - target_z)
	)
	var openListHeap = _max_heap_class.new()
	var visitedSet = {}
	visitedSet[x + z * mapWidth] = [
		x, z, abs(x - target_x) + abs(z - target_z) + 0, x, z
	]

	# Add initial open list entry:
	var i = 0
	while i < 8:
		var offset = dir_to_offset(i)
		var tx = x + offset[0]
		var tz = z + offset[1]
		if tx < 0 or tx >= _field_size_x or \
				tz < 0 or tz >= _field_size_z:
			i += 1
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
		elif passability_check_object != null:
			cost = passability_check_object.check_path_step_cost(
				 self, Vector2(x, z), Vector2(tx, tz),
				 step_distance, src_height, target_height)
		if cost != INF:
			var heuristic = (
				hFactor * cost * (abs((x + 1) - tx) +
				abs(z - tz)) +
				1
			);
			openListHeap.insert(
				[tx, tz, 1, x, z], -heuristic
			)
		i += 1

	var maxRuntime = max(
		1000, 0  # FIXME: Make this configurable
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
			while i2 < heapAsList.length - 1:
				if (heapAsList[i2][1] > heapAsList[i2 + 1][1]):
					OS.alert("heap has wrong sorting")
				i2 += 1
			_bestItemDebugScore = -(
				heapAsList[heapAsList.length - 1][1]
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
				"getDirTowardsTarget: " +
				"openList chosen -> (x: " +
				str(openListEntry[0]) +
				", y: " + str(openListEntry[1]) +
				", distance: " + str(bestDist) + ", fromX: " +
				str(openListEntry[3]) + ", fromY: " +
				str(openListEntry[4]) + ", heuristic: " +
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
		if not reachedDestination:
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
				elif passability_check_object != null:
					cost = passability_check_object.check_path_step_cost(
						 self, Vector2(x, z), Vector2(tx, tz),
						 step_distance, src_height, target_height)
				if cost != INF:
					var _heuristic = (
						hFactor * cost * (abs((x + 1) - tx) +
						abs(z - tz)) +
						1
					);
					openListHeap.insert(
						[tx, tz, 1, x, z], -_heuristic
					)
				i2 += 1
		if _debug:
			var t = ("HeightMapNavMesh.gd: " +
				"getDirTowardsTarget: openList entries -> [")
			var heapEntries = openListHeap.to_list()
			var j = 0;
			while j < heapEntries.length:
				if j > 0:
					t += ", "
				t += ("(x: " + heapEntries[j][0][0] +
					", y: " + heapEntries[j][0][1] +
					", dist: " + heapEntries[j][0][2] +
					", heap score: " + heapEntries[j][1] +
					")")
				j += 1
			print(t)
			t = (
				"HeightMapNavMesh.gd: getDirTowardsTarget: " +
				"visitedSet entries -> "
			);
			var firstEntry = true 
			for key in visitedSet:
				if not visitedSet.has(key):
					continue
				if firstEntry:
					firstEntry = false
				else:
					t += ", "
				t += ("(x: " + visitedSet[key][0] +
					", y: " + visitedSet[key][1] +
					", dist: ???" +
					", heuristic: " + visitedSet[key][2] +
					")")
			print(t)

		var _visitCost = heuristic
		if reachedDestination:
			_visitCost = 0
		visitedSet[x + z * mapWidth] = [
			x, z, _visitCost, fromX, fromZ
		]
		var plainHeurDist = (
			abs(x - target_x) + abs(z - target_z)
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
			"HeightMapNavMesh.gd: getDirTowardsTarget: " +
			"going to best node at x: " +
			str(bestNodeX) + ", y: " + str(bestNodeZ)
		)

	var reverse_path = []
	if get_world_coords == true:
		reverse_path.append(offset_to_pos([bestNodeX, bestNodeZ]))
	else:
		reverse_path.append([bestNodeX, bestNodeZ])

	# Walk it back:
	while (bestNodeFromX != startX or bestNodeFromZ != startZ):
		bestNodeX = bestNodeFromX
		bestNodeZ = bestNodeFromZ
		var key = bestNodeX + bestNodeZ * mapWidth
		bestNodeFromX = visitedSet[key][3]
		bestNodeFromZ = visitedSet[key][4]
		if get_world_coords == true:
			reverse_path.append(offset_to_pos([bestNodeX, bestNodeZ]))
		else:
			reverse_path.append([bestNodeX, bestNodeZ])

	# Construct final path in proper order:
	var path = []
	var i3 = path.len - 1
	while i3 >= 0:
		path.append(reverse_path[i3])
		i3 -= 1

	if _debug:
		print(
			"MovementNowSmart.js: getDirTowardsTarget: " +
			"extracted result: path=" + str(path)
		)
	if (bestNodeFromX != startX or bestNodeFromZ != startZ):
		OS.alert("invalid walk back result")

	# Return extracted direction
	return path
