extends Control

func _on_button_3_pressed():
	get_tree().change_scene_to_file("res://test_scenes/łukasz/interactive_planetcopy.tscn")

func _on_button_2_pressed():
	get_tree().quit()
