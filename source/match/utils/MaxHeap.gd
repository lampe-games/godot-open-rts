
var _contents = []

func insert(item, score):
	if (typeof(score) != TYPE_INT and typeof(score) != TYPE_FLOAT) or\
			(typeof(score) == TYPE_FLOAT and is_nan(score)):
		OS.alert("Invalid max heap insert, score not a valid number")
		return
	var heap = _contents
	while true:
		if heap.size() == 0:
			heap.append(item)
			heap.append(score)
			heap.append(null)
			heap.append(null)
		if heap[1] > score:
			if heap[2] == null:
				heap[2] = [item, score, null, null]
				return
			heap = heap[2]
			continue
		else:
			if heap[3] == null:
				heap[3] = [item, score, null, null]
				return
			heap = heap[3]
			continue

func _count_heap(heap):
	while true:
		var c = 0
		if heap.size() == 0:
			return c
		c += 1
		if heap[2] != null:
			c += _count_heap(heap[2])
		if heap[3] != null:
			c += _count_heap(heap[3])
		return c

func count():
	return _count_heap(_contents)

func to_list():
	return _convert_heap_to_list(_contents)

func _convert_heap_to_list(heap):
	var result = []
	if heap.size() == 0:
		return result
	result.append([heap[0], heap[1]])
	if heap[2] != null:
		var prepend_list = _convert_heap_to_list(heap[2])
		for item in result:
			prepend_list.append(item)
		result = prepend_list
	if heap[3] != null:
		var append_list = _convert_heap_to_list(heap[3])
		for item in append_list:
			result.append(item)
	return result

func is_empty():
	if _contents.size() == 0:
		return true
	return false

func pop():
	if _contents.size() == 0:
		return null
	var heap = _contents
	var node = heap
	var parent = heap
	while node[3] != null:
		parent = node;
		node = node[3]
	if node == _contents:
		# Replace top node contents with right or left side:
		var popItem = [heap[0], heap[1]];
		if heap[2] == null and heap[3] == null:
			heap.clear()
			return popItem
		if heap[2] == null or heap[3] == null:
			# Just take whatever child is left as the top:
			var newTop = heap[3]
			if newTop == null:
				newTop = heap[2]
			heap[0] = newTop[0]
			heap[1] = newTop[1]
			heap[2] = newTop[2]
			heap[3] = newTop[3]
		else:
			# Need to shuffle around subtrees to keep order:
			var newTop = heap[3]
			var newLeftSide = heap[2]
			var newLeftSideParent = heap[3]
			while newLeftSideParent[2] != null:
				newLeftSideParent = newLeftSideParent[2]
			newLeftSideParent[2] = newLeftSide;
			heap[0] = newTop[0]
			heap[1] = newTop[1]
			heap[2] = newTop[2]
			heap[3] = newTop[3]
		return popItem
	else:
		# We need to retain left-hand subtree if any:
		var leftHalf = node[2]
		parent[3] = leftHalf  # Also removes 'node'
	return [node[0], node[1]]
