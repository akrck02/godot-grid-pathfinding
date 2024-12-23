class_name NavigableTilemapLayer
extends TileMapLayer

const MIN_INTEGER_VALUE : int = -9223372036854775808
const MAX_INTEGER_VALUE : int = 9223372036854775807
const DEFAULT_SPRITE_SIZE : int = 16

const WALL_TYPE : int = 1
const TYPE_PROPERTY_NAME : String = "type"

@export_category("Configuration")
@export var tilemap_mode : TilemapSettings.Mode = TilemapSettings.Mode.SQUARE
@export var diagonal_policy : TilemapSettings.DiagonalPolicy =  TilemapSettings.DiagonalPolicy.NEVER
@export var cell_size : Vector2i = Vector2i(DEFAULT_SPRITE_SIZE, DEFAULT_SPRITE_SIZE)
@export var layers : Array[TileMapLayer] = []

@export_category("Debug")
@export var debug_canvas_layer : TileMapLayer

var grid : AStarGrid2D = AStarGrid2D.new()

## function to execute when tilemap layer is instantiated
func _ready() -> void:

	match tilemap_mode:
		TilemapSettings.Mode.SQUARE: grid.cell_shape = AStarGrid2D.CELL_SHAPE_SQUARE
		TilemapSettings.Mode.ISOMETRIC_DOWN: grid.cell_shape = AStarGrid2D.CELL_SHAPE_ISOMETRIC_DOWN
		TilemapSettings.Mode.ISOMETRIC_RIGHT: grid.cell_shape = AStarGrid2D.CELL_SHAPE_ISOMETRIC_RIGHT

	match diagonal_policy:
		TilemapSettings.DiagonalPolicy.NEVER: grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		TilemapSettings.DiagonalPolicy.ALWAYS: grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
		TilemapSettings.DiagonalPolicy.ONLY_IF_NO_OBSTACLES: grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES

	layers.append(self)
	layers.sort_custom(sort_by_name)

	grid.cell_size = cell_size
	grid.region = get_used_rectangle()
	grid.update()

	set_current_walls()


## Sort the current layers by index
func sort_by_name(a : Node, b : Node):
	return a.name.naturalnocasecmp_to(b.name) > 0


## Update the walls on the grid
func set_current_walls():
	var map = {}
	for layer: TileMapLayer in layers:
		for cell : Vector2 in layer.get_used_cells():
			var cell_index = _vectorToString(cell)
			
			if not map.has(cell_index):
				var data = layer.get_cell_tile_data(cell)
				map[cell_index] = data != null and data.get_custom_data(TYPE_PROPERTY_NAME) == WALL_TYPE
				_draw_debug_colors_for_cell(layer, cell, map[cell_index])
				grid.set_point_solid(cell, map[cell_index])

func _vectorToString(vec : Vector2) -> String: 
	return "{x},{y}".format({"x":vec.x, "y":vec.y})


## Draw debug colors for cells 
func _draw_debug_colors_for_cell(layer : TileMapLayer, cell : Vector2, solid : bool):
	if solid == true: 
		layer.set_cell(cell, 1, Vector2(1,0))
	# else: 
	#	layer.set_cell(cell,1, Vector2(0,0))

## Get the used rectangle of the tilemap
func get_used_rectangle() -> Rect2i:

	var min_position = Vector2(MAX_INTEGER_VALUE, MAX_INTEGER_VALUE)
	var max_position = Vector2(MIN_INTEGER_VALUE, MIN_INTEGER_VALUE)

	for layer in layers:
		for cell in layer.get_used_cells():
			if cell.x < min_position.x : min_position.x = cell.x
			if cell.y < min_position.y : min_position.y = cell.y
			if cell.x > max_position.x : max_position.x = cell.x
			if cell.y > max_position.y : max_position.y = cell.y

	var size : Vector2 = max_position - min_position
	return Rect2i(min_position, Vector2.ONE + size)


## calculate cell index
func calculate_point_index(point) -> Vector2i:
	point -= grid.region.position
	return point


## Get coordinates from global position
func get_coordinates_from_global_position(global_origin : Vector2) -> Vector2i:
	return local_to_map(to_local(global_origin))


## Get global position from coordinates
func get_global_position_from_coordinates(coords : Vector2) -> Vector2:
	return self.to_global(map_to_local(coords))
