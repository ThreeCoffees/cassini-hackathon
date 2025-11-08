class_name TerrainGenerator extends Node

@export var terrain_tilemap_layer: TerrainTilemapLayer
@export var selection_layer: SelectionLayer
@export var auto_assign_forest_hp := true

var ForestHP = null

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
	generate_tilemap()
	CityManager.create_cities(terrain_tilemap_layer)

# Wypełnia tilemapę na podstawie terrain_array i przypisuje HP lasom
func generate_tilemap():
	for i in width:
		for j in height:
			terrain_tilemap_layer.set_cell(Vector2i(i, j), 1, Vector2i(terrain_array[i][j], 0), 0)

	# Po wygenerowaniu tilemapy — przypisz HP dla tile'y lasu, jesli wlaczone
	if auto_assign_forest_hp:
		if ForestHP == null:
			ForestHP = load("res://scripts/tile_resources/forest_hp.gd")
		var fh = ForestHP.new()
		add_child(fh)
		fh.assign_hp_to_tilemap(terrain_tilemap_layer, selection_layer)
		# Zarejestruj instancję w ResourceManager, żeby mogła być aktualizowana co tick
		ResourceManager.register_forest_hp(fh)
			
