class_name PowerPlantPlacer extends Node

func OnPositionPicked(position : Vector2i):
	var new_plant = PowerPlant.new(position, 0 as PowerPlant.PlantTypes)
	add_child(new_plant)
	
	
