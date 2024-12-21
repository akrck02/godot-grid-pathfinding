class_name NavigableTilemapLayer
extends TileMapLayer

const MIN_INTEGER_VALUE : int = -9223372036854775808
const MAX_INTEGER_VALUE : int = 9223372036854775807
const DEFAULT_SPRITE_SIZE : int = 16

const WALL_TYPE : int = 1
const TYPE_PROPERTY_NAME : String = "type"

## Enumeration for the tilemap modes
enum TilemapMode {
	SQUARE,
	ISOMETRIC_DOWN,
	ISOMETRIC_RIGHT
}

## Enumeration for diagonal movement policy
enum DiagonalPolicy {
	NEVER,
	ALWAYS,
	ONLY_IF_NO_OBSTACLES
}

@export_category("Configuration")
@export var tilemap_mode : TilemapMode = TilemapMode.SQUARE
@export var diagonal_policy : DiagonalPolicy = DiagonalPolicy.NEVER
@export var cell_size : Vector2i = Vector2i(DEFAULT_SPRITE_SIZE, DEFAULT_SPRITE_SIZE)
@export var layers : Array[TileMapLayer] = []

@export_category("Debug")
@export var debug_canvas_layer : TileMapLayer

var grid : AStarGrid2D = AStarGrid2D.new()

func _ready() -> void:

	match tilemap_mode:
		TilemapMode.SQUARE: grid.cell_shape = AStarGrid2D.CELL_SHAPE_SQUARE
		TilemapMode.ISOMETRIC_DOWN: grid.cell_shape = AStarGrid2D.CELL_SHAPE_ISOMETRIC_DOWN
		TilemapMode.ISOMETRIC_RIGHT: grid.cell_shape = AStarGrid2D.CELL_SHAPE_ISOMETRIC_RIGHT

	match diagonal_policy:
		DiagonalPolicy.NEVER: grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		DiagonalPolicy.ALWAYS: grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
		DiagonalPolicy.ONLY_IF_NO_OBSTACLES: grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES

	layers.append(self)
	grid.cell_size = cell_size
	grid.region = get_used_rectangle()
	grid.update()
	set_current_walls()


## Update the walls on the grid
func set_current_walls():

	for layer in layers:
		for cell in layer.get_used_cells():
			var data = layer.get_cell_tile_data(cell)
			if data != null and data.get_custom_data(TYPE_PROPERTY_NAME) == WALL_TYPE:
				print("Setting wall at: %s, %s" %[cell.x , cell.y])
				grid.set_point_solid(cell, true)
				debug_canvas_layer.set_cell(cell,2,Vector2(4,5),0)


## Get the used rectangle of the tilemap
func get_used_rectangle() -> Rect2i:

	var min_position = Vector2(MAX_INTEGER_VALUE, MAX_INTEGER_VALUE)
	var max_position = Vector2(MIN_INTEGER_VALUE, MIN_INTEGER_VALUE)

	for layer in layers:
		for cell in layer.get_used_cells():
			if cell.x < min_position.x : min_position.x = cell.x
			if cell.y < min_position.y : min_position.y = cell.y
			if cell.x > max_position.x : max_position.x = cell.x
			if cell.y > max_position.y : max_position.y = cell.x

	var size : Vector2 = max_position - min_position
	return Rect2i(min_position, Vector2.ONE + size )


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
