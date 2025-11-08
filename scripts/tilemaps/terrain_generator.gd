class_name TerrainGenerator extends Node

@export var terrain_tilemap_layer: TileMapLayer
@export var auto_assign_forest_hp := true

var ForestHP = preload("res://scripts/tile_resources/forest_hp.gd")

var terrain_array: Array[Array] = []
var width: int = 128
var height: int = 128

func prepare_dummy_array():
	terrain_array.resize(width)
	for i in width:
		terrain_array[i] = []
		terrain_array[i].resize(height)
		for j in height:
			terrain_array[i][j] = randi_range(0, 4)

func fetch_array() -> void:
	# TODO: replace with fetch
	prepare_dummy_array()
	

func _ready() -> void:
	fetch_array()
	generate_tilemap()
	CityManager.create_cities(terrain_tilemap_layer)
	

func generate_tilemap():
	for i in width:
		for j in height:
			terrain_tilemap_layer.set_cell(Vector2i(i, j), 1, Vector2i(terrain_array[i][j], 0), 0)

	# Po wygenerowaniu tilemapy — przypisz HP dla tile'y lasu, jesli wlaczone
	if auto_assign_forest_hp:
		var fh = ForestHP.new()
		add_child(fh)
		fh.assign_hp_to_tilemap(terrain_tilemap_layer)
			
