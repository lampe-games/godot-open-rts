extends CanvasLayer

@onready var _fps_label = find_child("FPSLabel")


func _ready():
	hide()


func _unhandled_input(event):
	if event.is_action_pressed("toggle_diagnostic_mode"):
		visible = not visible


func _physics_process(_delta):
	_fps_label.text = (
		"{0} FPS \n".format(["%0.1f" % (Performance.get_monitor(Performance.TIME_FPS))])
		+ str(OS.get_processor_name())
		+ " \n"
		+ str(OS.get_processor_count())
		+ " Threads Used \n"
		+ str(OS.get_static_memory_usage() / int(1000000))
		+ " MBs of Memory Used \n"
		+ str(RenderingServer.get_video_adapter_name())
		+ " "
		+ str(RenderingServer.get_video_adapter_vendor())
		+ " \n"
		+ "Using "
		+ str(OS.get_name())
		+ " Operating System"
	)
