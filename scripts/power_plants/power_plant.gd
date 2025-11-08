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
	plant_position = position
	global_position = plant_position
	print(plant_position)
	plant_type = type
	match plant_type:
		PlantTypes.WOOD:
			energy_production_multiplier = 2
			texture = load("res://assets/icons/power_plant.png")
		PlantTypes.SUN:
			energy_production_multiplier = 3
			texture = load("res://assets/icons/sun_plant.png")
		PlantTypes.WIND:
			energy_production_multiplier = 4
			texture = load("res://assets/icons/wind_plant.png")
	

	
	
