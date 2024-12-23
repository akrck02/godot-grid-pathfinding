class_name Navigation
extends Node2D

func get_steps(tilemap : NavigableTilemapLayer, start : Vector2, end : Vector2) -> PackedVector2Array:
	
	if not tilemap.grid.is_in_boundsv(start) or not tilemap.grid.is_in_boundsv(end): 
		return [];
	
	return tilemap.grid.get_point_path(start, end, false)
