extends PanelContainer


func _on_time_scale_spin_box_value_changed(value):
	Engine.time_scale = value
