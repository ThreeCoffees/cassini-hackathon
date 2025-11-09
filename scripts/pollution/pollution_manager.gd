class_name PollutionManager 
extends Node

var pollutions : Array[Array] = []
var width: int = 128
var height: int = 128

@export var plant_placer : PowerPlantPlacer
var tilemap_layer : TerrainTilemapLayer

func _ready() -> void:
	plant_placer.plant_placed.connect(Callable(self, "_on_plant_placed"))
	prepare_dummy_array()

func add_polution(position : Vector2):
	var pollution = Pollution.new(0.2, position, 4)
	pollutions[position.x][position.y] = pollution
	tilemap_layer.add_child(pollution)

func prepare_dummy_array():
	pollutions.resize(width)
	for i in width:
		pollutions[i] = []
		pollutions[i].resize(height)
		for j in height:
			pollutions[i][j] = null

func _on_plant_placed(type :PowerPlant.PlantTypes, position : Vector2, tilemap: TerrainTilemapLayer):
	tilemap_layer = tilemap
	match type:
		PowerPlant.PlantTypes.WOOD:
			var pollution = Pollution.new(0.8, position, 2)
			pollutions[position.x/24][position.y/24] = pollution
			tilemap_layer.add_child(pollution)
		PowerPlant.PlantTypes.SUN:
			var pollution = Pollution.new(0.5, position, 3)
			pollutions[position.x/24][position.y/24] = pollution
			tilemap_layer.add_child(pollution)
		PowerPlant.PlantTypes.WIND:
			var pollution = Pollution.new(0.2, position, 4)
			pollutions[position.x/24][position.y/24] = pollution
			tilemap_layer.add_child(pollution)

func is_polluted(position : Vector2):
	if (pollutions[position.x][position.y] != null):
		return true
	return false
	
		
	
