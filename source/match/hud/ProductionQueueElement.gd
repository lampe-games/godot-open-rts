extends Button

var queue_element = null


func _ready():
	queue_element.changed.connect(_on_queue_element_changed)
	text = queue_element.unit_prototype.resource_path[
		queue_element.unit_prototype.resource_path.rfind("/") + 1
	]
	find_child("Label").text = "{0}%".format([int(queue_element.progress() * 100.0)])


func _on_queue_element_changed():
	find_child("Label").text = "{0}%".format([int(queue_element.progress() * 100.0)])
