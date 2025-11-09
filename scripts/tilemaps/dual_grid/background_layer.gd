class_name BackgroundLayer extends TileMapLayer

@export var reference_tilemap: TileMapLayer
@export var terrain_type: int
@export var source_id: int

var width: int
var height: int

func _ready():
	generate_layer()

func generate_layer():
	var rect = reference_tilemap.get_used_rect()
	width = rect.size.x+1
	height = rect.size.y+1

	for i in width:
		for j in height:
			set_cell(Vector2i(i,j), source_id, Vector2i(0,0), 0)

