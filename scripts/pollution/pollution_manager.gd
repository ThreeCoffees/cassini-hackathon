class_name PollutionManager 
extends Node

var pollutions_items : Array[Pollution] = []
var pollutions : Array[Array] = []
var width: int = 128
var height: int = 128

@export var plant_placer : PowerPlantPlacer
@export var tilemap_layer : TerrainTilemapLayer
@export var pollution_layer : TileMapLayer

func _ready() -> void:
	plant_placer.plant_placed.connect(Callable(self, "_on_plant_placed"))
	prepare_dummy_array()

func add_polution(position : Vector2, value : float):
	var arr_position = tilemap_layer.map_to_local(position)
	pollution_layer.set_cell(position,2, Vector2(0,0))
	var pollution = Pollution.new(0.2, arr_position, value, self)
	pollutions[position.x][position.y] = 1
	pollutions_items.append(pollution)
	#tilemap_layer.add_child(pollution)

func generate_pollution_from_array(array : Array[Array]):
	for i in 128:
		for j in 128:
			if array[i][j] > 0:
				pollutions[i][j] = 1
				var arr_position = Vector2(i,j)
				var position = tilemap_layer.map_to_local(arr_position)
				var pollution = Pollution.new(0.2, position, 4, self)
				pollutions_items.append(pollution)
				pollution_layer.set_cell(arr_position,2, Vector2(0,0))
				#tilemap_layer.add_child(pollution)
		

func prepare_dummy_array():
	pollutions.resize(width)
	for i in width:
		pollutions[i] = []
		pollutions[i].resize(height)
		for j in height:
			pollutions[i][j] = 0

func _on_plant_placed(type :PowerPlant.PlantTypes, position : Vector2, tilemap: TerrainTilemapLayer):
	var arr_position = tilemap_layer.local_to_map(position)
	# tilemap_layer = tilemap
	match type:
		PowerPlant.PlantTypes.WOOD:
			var pollution = Pollution.new(0.8, position, 3, self)
			pollutions[arr_position.x][arr_position.y] = 1
			pollutions_items.append(pollution)
			pollution_layer.set_cell(arr_position,2, Vector2(0,0))
			#tilemap_layer.add_child(pollution)
		PowerPlant.PlantTypes.SUN:
			var pollution = Pollution.new(0.5, position, 4, self)
			pollutions[arr_position.x][arr_position.y] = 1
			pollutions_items.append(pollution)
			pollution_layer.set_cell(arr_position,2, Vector2(0,0))
			#tilemap_layer.add_child(pollution)
		PowerPlant.PlantTypes.WIND:
			var pollution = Pollution.new(0.2, position, 4.5, self)
			pollutions[arr_position.x][arr_position.y] = 1
			pollutions_items.append(pollution)
			pollution_layer.set_cell(arr_position,2, Vector2(0,0))
			#tilemap_layer.add_child(pollution)

func is_polluted(position : Vector2):
	if (pollutions[position.x][position.y] == 1):
		return true
	return false
	
func propagate_all():
	print("starting propagation")
	for pollution in pollutions_items:
		pollution.try_propagation()

func calculate_debuffs():
	var wood_debuffs : int = 0
	var agri_debuffs : int = 0
	var city_debuffs : int = 0
	for pollution in pollutions_items:
		var type : TerrainTilemapLayer.TileTypes = tilemap_layer.get_cell_type(pollution.position)
		match type:
			TerrainTilemapLayer.TileTypes.WOODS:
				wood_debuffs += 1
			TerrainTilemapLayer.TileTypes.AGRI:
				agri_debuffs += 1
			TerrainTilemapLayer.TileTypes.CITY:
				city_debuffs += 1
	var return_arr : Array[int] = [wood_debuffs, agri_debuffs, city_debuffs]
	return return_arr
	
