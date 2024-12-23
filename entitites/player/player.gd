class_name Player
extends CharacterBody2D

@export var tilemap : NavigableTilemapLayer = null;

@onready var navigation : Navigation = $Navigation
@onready var timer : Timer = $Timer
@onready var sprite : Sprite2D = $Sprite2D

var tween : Tween
var moving : bool = false
var steps : PackedVector2Array = []

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and Input.is_action_just_pressed(&'ui_accept'):

		var debug = get_parent().get_tree().get_nodes_in_group("debug")[0]
		for child in debug.get_children():
			child.queue_free()

		var new_position = Positions.convert_ui_position_to_scene_global_position(get_viewport(), event.position)
		var current_coordinates = tilemap.get_coordinates_from_global_position(global_position)
		var new_coordinates = tilemap.get_coordinates_from_global_position(new_position)

		steps = navigation.get_steps(tilemap, current_coordinates, new_coordinates)
		print("Steps from %s to %s" % [current_coordinates, new_coordinates])
		print("%s\n" %steps)

		_draw_line(debug, steps)

func _process(_delta: float) -> void:

	if moving or steps.is_empty():
		return

	var step = steps[0]
	steps.remove_at(0)
	_move_to_cell(step)


func _draw_line(parent : Node2D, draw_steps: PackedVector2Array) -> void:
	var line : Line2D = Line2D.new()
	for point in draw_steps:
		line.add_point(Vector2(point.x + tilemap.cell_size.x/2.00, point.y + tilemap.cell_size.y/2.00))

	line.default_color = Color.REBECCA_PURPLE
	line.default_color.a = 1
	line.visible = true
	line.width = 1
	line.z_index = 999
	line.joint_mode = Line2D.LINE_JOINT_BEVEL
	parent.add_child(line)


func _move_to_cell(new_position: Vector2) -> void:

	moving = true
	tween = create_tween()
	tween.tween_property(self, "position", new_position, 1.00 / 3)
	await tween.finished
	moving = false

func _input(_event: InputEvent) -> void:

	if Input.is_action_just_pressed(&"ui_reset"):
		get_tree().reload_current_scene()

	if Input.is_action_just_pressed(&"ui_cancel"):
		get_tree().change_scene_to_file('res://main.tscn')


func get_coordinates() -> Vector2:
	return tilemap.get_coordinates_from_global_position(global_position)
