extends PanelContainer


func _ready():
	if not FeatureFlags.show_minimap:
		queue_free()
	find_child("MinimapViewport").size = find_parent("Match").find_child("Map").size
