extends CanvasLayer

@onready var _fps_label = find_child("FPSLabel")


func _ready():
	hide()


func _unhandled_input(event):
	if event.is_action_pressed("toggle_diagnostic_mode"):
		visible = not visible


func _physics_process(_delta):
	_fps_label.text = "{0} FPS".format(["%0.1f" % (Performance.get_monitor(Performance.TIME_FPS))])
