extends CanvasLayer

@onready var _fps_label = find_child("FPSLabel")


func _ready():
	hide()


func _unhandled_input(event):
	if event.is_action_pressed("toggle_diagnostic_mode"):
		visible = not visible


func _physics_process(_delta):
	_fps_label.text = "{0} FPS \n".format(["%0.1f" % (Performance.get_monitor(Performance.TIME_FPS))])
	_fps_label.text += str(OS.get_processor_name()) + " \n"
	_fps_label.text += str(OS.get_processor_count()) + " Threads Used \n"
	var MBs = OS.get_static_memory_usage()/int(1000000)
	_fps_label.text += str(MBs) + " MBs of Memory Used \n"
	_fps_label.text += str(RenderingServer.get_video_adapter_name()) + " "
	_fps_label.text += str(RenderingServer.get_video_adapter_vendor()) + " \n"
	_fps_label.text += "Using " + str(OS.get_name()) + " Operating System"
