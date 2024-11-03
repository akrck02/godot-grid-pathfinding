class_name Positions

static func convert_ui_position_to_scene_global_position(viewport : Viewport, canvas_position : Vector2) -> Vector2:
	return viewport.get_canvas_transform().affine_inverse() * canvas_position
