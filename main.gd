extends Control


func _on_d_pressed() -> void:
	get_tree().change_scene_to_file("res://world/world.tscn")


func _on_isometric_pressed() -> void:
	get_tree().change_scene_to_file("res://world/isometric_world.tscn")
