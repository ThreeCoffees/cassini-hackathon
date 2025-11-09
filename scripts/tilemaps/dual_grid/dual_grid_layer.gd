class_name DualGridLayer extends TileMapLayer

@export var reference_tilemap: TileMapLayer
@export var terrain_type: int 
@export var source_id: int

var width: int
var height: int

const tile_dict: Dictionary[String, Vector2i] = {
	"0010": Vector2i(0,0),
	"0101": Vector2i(1,0),
	"1011": Vector2i(2,0),
	"0011": Vector2i(3,0),

	"1001": Vector2i(0,1),
	"0111": Vector2i(1,1),
	"1111": Vector2i(2,1),
	"1110": Vector2i(3,1),

	"0100": Vector2i(0,2),
	"1100": Vector2i(1,2),
	"1101": Vector2i(2,2),
	"1010": Vector2i(3,2),

	"0000": Vector2i(0,3),
	"0001": Vector2i(1,3),
	"0110": Vector2i(2,3),
	"1000": Vector2i(3,3),
}

func _ready():
	generate_layer()

func generate_layer():
	var rect = reference_tilemap.get_used_rect()
	width = rect.size.x+1
	height = rect.size.y+1

	for i in width:
		for j in height:
			set_cell(Vector2i(i,j), source_id, get_atlas_coords(Vector2i(i,j)), 0)


func get_atlas_coords(coords: Vector2i)-> Vector2i:
	return tile_dict.get(get_neighbors(coords))

func get_neighbors(coords: Vector2i)-> String:
	# Neighbors order:
	# 0 1
	# 2 3
	var neighbors: String = "0000" 

	neighbors[0] = "1" if reference_tilemap.get_cell_atlas_coords(Vector2i(coords.x-1, coords.y-1)).x == terrain_type else "0"
	neighbors[1] = "1" if reference_tilemap.get_cell_atlas_coords(Vector2i(coords.x, coords.y-1)).x == terrain_type else "0"
	neighbors[2] = "1" if reference_tilemap.get_cell_atlas_coords(Vector2i(coords.x-1, coords.y)).x == terrain_type else "0"
	neighbors[3] = "1" if reference_tilemap.get_cell_atlas_coords(Vector2i(coords.x, coords.y)).x == terrain_type else "0"

	return neighbors
