class_name PowerPlantPlacer extends Node

var plant_type : int = -1

func OnPlantPicked(type : int):
	plant_type = type

func OnPositionPicked(position : Vector2i, tilemap_layer: TerrainTilemapLayer):
	if (plant_type != -1):
		if (((ResourceManager.how_much_resource("wood") >= 20) and (plant_type == 0)) or ((ResourceManager.how_much_resource("wood") >= 40) and (plant_type == 1)) or ((ResourceManager.how_much_resource("wood") >= 80) and (plant_type == 2))):
			var new_plant = PowerPlant.new(position, plant_type as PowerPlant.PlantTypes)
			tilemap_layer.add_child(new_plant)
			plant_type = -1
		else:
			print("za malo drewna")
	
	
