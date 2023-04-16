extends PanelContainer

@onready var _match = find_parent("Match")


func _on_toggle_button_pressed():
	_match.fog_of_war.visible = not _match.fog_of_war.visible
