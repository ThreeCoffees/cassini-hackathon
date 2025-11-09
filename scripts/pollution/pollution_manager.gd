class_name PollutionManager 
extends Node

var pollutions_items : Array[Pollution] = []
var pollutions : Array[Array] = []
var width: int = 128
var height: int = 128

@export var plant_placer : PowerPlantPlacer
@export var tilemap_layer : TerrainTilemapLayer

func _ready() -> void:
	plant_placer.plant_placed.connect(Callable(self, "_on_plant_placed"))
	prepare_dummy_array()

func add_polution(position : Vector2):
	var arr_position = tilemap_layer.local_to_map(position)
	var pollution = Pollution.new(0.2, position, 4, self)
	pollutions[arr_position.x][arr_position.y] = 1
	pollutions_items.append(pollution)
	tilemap_layer.add_child(pollution)
	

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
			var pollution = Pollution.new(0.8, position, 2, self)
			pollutions[arr_position.x][arr_position.y] = 1
			pollutions_items.append(pollution)
			tilemap_layer.add_child(pollution)
		PowerPlant.PlantTypes.SUN:
			var pollution = Pollution.new(0.5, position, 3, self)
			pollutions[arr_position.x][arr_position.y] = 1
			pollutions_items.append(pollution)
			tilemap_layer.add_child(pollution)
		PowerPlant.PlantTypes.WIND:
			var pollution = Pollution.new(0.2, position, 4, self)
			pollutions[arr_position.x][arr_position.y] = 1
			pollutions_items.append(pollution)
			tilemap_layer.add_child(pollution)

func is_polluted(position : Vector2):
	var arr_position = tilemap_layer.local_to_map(position)
	if (pollutions[arr_position.x][arr_position.y] == 1):
		return true
	return false
	
func propagate_all():
	for pollution in pollutions_items:
		pollution.try_propagation()
	
