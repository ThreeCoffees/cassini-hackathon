class_name PowerPlantPlacer extends Node

var plant_type : int = -1


func OnPlantPicked(type : int):
	plant_type = type

func OnPositionPicked(position : Vector2i, tilemap_layer: TerrainTilemapLayer):
	if (plant_type != -1):
		var new_plant = PowerPlant.new(position, plant_type as PowerPlant.PlantTypes)
		tilemap_layer.add_child(new_plant)
		plant_type = -1
	
	
