extends Node

func _ready():
	var terrain_tilemap = get_node("/root/TilemapGenTest/Tilemap/TerrainTilemapLayer")
	var plant_placer = get_node("/root/TilemapGenTest/PowerPlants/PowerPlantPlacer")
	
	terrain_tilemap.plant_position_picked.connect(plant_placer.OnPositionPicked)
