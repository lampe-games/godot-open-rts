extends CanvasLayer


func _ready():
	if not Globals.god_mode:
		hide()
	Signals.god_mode_enabled.connect(show)
	Signals.god_mode_disabled.connect(hide)
