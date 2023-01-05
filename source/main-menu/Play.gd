extends Control


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://source/match/Match.tscn")


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://source/main-menu/Main.tscn")
