extends Control

@onready var _rich_text_label = find_child("RichTextLabel")


func _ready():
	_rich_text_label.text = (
		_rich_text_label
		. text
		. replace("CORE_CONTRIBUTORS", tr("CORE_CONTRIBUTORS"))
		. replace("ASSETS", tr("ASSETS"))
	)


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://source/main-menu/Main.tscn")
