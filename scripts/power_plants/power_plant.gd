class_name PowerPlant extends Sprite2D

var plant_position : Vector2i
var energy_production_multiplier : int
var plant_type : PlantTypes

enum PlantTypes{
	WOOD,
	SUN,
	WIND
}

func _init(position : Vector2i, type : PlantTypes):
	#plant_position = to_global(position)
	plant_position = position
	global_position = plant_position
	print(plant_position)
	plant_type = type
	match plant_type:
		PlantTypes.WOOD:
			energy_production_multiplier = 2
		PlantTypes.SUN:
			energy_production_multiplier = 3
		PlantTypes.WIND:
			energy_production_multiplier = 4
	texture = load("res://assets/icons/power_plant.png")

	
	
