extends CanvasLayer

@onready var player_coordinates_label : Label = $MarginContainer/VBoxContainer/PlayerCoordinates
@onready var mouse_coordinates_label : Label = $MarginContainer/VBoxContainer/MouseCoordinates
@export var tilemap_layer : NavigableTilemapLayer
@export var player : Player

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouse:
		update_mouse_data(event.position)


## Update mouse coordinates on labels
func update_mouse_data(global_mouse_position : Vector2):
	var new_global_position = Positions.convert_ui_position_to_scene_global_position(get_viewport(), global_mouse_position)
	var coordinates : Vector2i = tilemap_layer.get_coordinates_from_global_position(new_global_position)
	mouse_coordinates_label.text = "Mouse: x: {x} , y: {y}".format({"x" : coordinates.x, "y": coordinates.y})


func _process(_delta: float) -> void:
	var coordinates : Vector2 = player.get_coordinates()
	player_coordinates_label.text = "Player: x: {x} , y: {y}".format({"x" : coordinates.x, "y": coordinates.y})
	
