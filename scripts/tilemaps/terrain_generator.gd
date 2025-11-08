class_name TerrainGenerator extends Node

@export var terrain_tilemap_layer: TileMapLayer
@export var auto_assign_forest_hp := true

var ForestHP = preload("res://scripts/tile_resources/forest_hp.gd")

var terrain_array: Array[Array] = []
var width: int = 128
var height: int = 128

# Przygotowuje losową tablicę terenu (dummy)
func prepare_dummy_array():
	terrain_array.resize(width)
	for i in width:
		terrain_array[i] = []
		terrain_array[i].resize(height)
		for j in height:
			terrain_array[i][j] = randi_range(0, 4)

# Pobiera/ustawia tablicę terenu (tymczasowo wywołuje prepare_dummy_array)
func fetch_array() -> void:
	# TODO: replace with fetch
	prepare_dummy_array()
	

# Inicjalizacja: pobranie danych i wygenerowanie tilemapy
func _ready() -> void:
	fetch_array()
	generate_tilemaps_around()
	CityManager.create_cities(terrain_tilemap_layer)

func generate_tilemaps_around():
	generate_tilemap(0,0, true)
	generate_tilemap(-width,0)
	generate_tilemap(0,-height)
	generate_tilemap(width, 0)
	generate_tilemap(0,height)
	generate_tilemap(-width,height)
	generate_tilemap(width,-height)
	generate_tilemap(-width,-height)
	generate_tilemap(width,height)

# Wypełnia tilemapę na podstawie terrain_array i przypisuje HP lasom
func generate_tilemap(start_x, start_y, is_available=false):
	for i in width:
		for j in height:
			terrain_tilemap_layer.set_cell(Vector2i(start_x+i, start_y+j), 1, Vector2i(terrain_array[i][j], 0), 0)
	if !is_available:		
		terrain_tilemap_layer.modulate = Color(0,0,0,0.55)

	# Po wygenerowaniu tilemapy — przypisz HP dla tile'y lasu, jesli wlaczone
	if auto_assign_forest_hp:
		var fh = ForestHP.new()
		add_child(fh)
		fh.assign_hp_to_tilemap(terrain_tilemap_layer)
		# Zarejestruj instancję w ResourceManager, żeby mogła być aktualizowana co tick
		if ResourceManager.has_method("register_forest_hp"):
			ResourceManager.register_forest_hp(fh)
			
