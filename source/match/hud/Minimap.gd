extends PanelContainer


func _ready():
	if not FeatureFlags.show_minimap:
		queue_free()
