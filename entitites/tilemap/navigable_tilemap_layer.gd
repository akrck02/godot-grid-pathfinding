class_name NavigableTilemapLayer
extends TileMapLayer

@export var debug_canvas_layer : TileMapLayer
@export var layers : Array[TileMapLayer] = []
@onready var map_limits : Rect2i = get_used_rectangle()
var grid : AStarGrid2D = AStarGrid2D.new()

func _ready() -> void:
	setup_grid()

func setup_grid() -> void:
	grid.cell_size = Vector2(16, 16)
	grid.cell_shape = AStarGrid2D.CELL_SHAPE_SQUARE
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.region = map_limits
	grid.update()
	update_walls()
	
	for cell in get_used_cells():
		debug_canvas_layer.set_cell(cell,0,Vector2(0,3),0)

func update_walls():
	layers.append(self)
	for layer in layers:
		for cell in layer.get_used_cells():
			var data : TileData = layer.get_cell_tile_data(cell)
			
			if data.get_custom_data("type") == 1:
				grid.set_point_solid(cell, true)


func get_used_rectangle() -> Rect2i:
	
	var min_x : int = 9999999999999
	var max_x : int = -9999999999999
	
	var min_y : int = 9999999999999
	var max_y : int = -9999999999999
	
	for layer in layers:
		for cell in layer.get_used_cells(): 
			if min_x > cell.x:	min_x = cell.x
			if max_x < cell.x:	max_x = cell.x	
			if min_y > cell.y:	min_y = cell.y
			if max_y < cell.y:	max_y = cell.y	

	var position : Vector2 = Vector2(min_x, min_y)
	var size : Vector2 = Vector2(max_x - min_x, max_y - min_y)
	return Rect2i(position, size)


# calculate cell index
func calculate_point_index(point) -> Vector2i:
	# subtract offset from position
	point -= map_limits.position
	return point

## Get coordinates from global position
func get_coordinates_from_global_position(global_origin : Vector2) -> Vector2i:
	return local_to_map(to_local(global_origin))


## Get global position from coordinates
func get_global_position_from_coordinates(coords : Vector2) -> Vector2:
	return self.to_global(map_to_local(coords))
