class_name PowerPlantPlacer extends Node

var plant_type : int = -1
var is_placing : bool = false

signal plant_placed(type : PowerPlant.PlantTypes, position : Vector2, tilemap_layer: TerrainTilemapLayer)

func OnPlantPicked(type : int) -> void:
	# Set the desired plant type (does not place immediately)
	plant_type = type

func set_placing(enable: bool) -> void:
	is_placing = enable

func toggle_placing(type: int) -> void:
	# Toggle placing mode: clicking same type twice disables placing
	if is_placing and plant_type == type:
		is_placing = false
		plant_type = -1
	else:
		plant_type = type
		is_placing = true

func OnPositionPicked(position : Vector2i, tilemap_layer: TerrainTilemapLayer) -> bool:
	# Only place when in placing mode and a type is selected
	if not is_placing or plant_type == -1:
		return false

	# Prevent placing multiple plants on same tile
	for p in ResourceManager.plants:
		if p is PowerPlant and p.plant_position == position:
			print("miejsce zajete")
			return false

	# Check cost depending on plant type
	var wood = ResourceManager.how_much_resource("wood")
	var cost_ok := false
	if plant_type == 0 and wood >= 20:
		cost_ok = true
	elif plant_type == 1 and wood >= 40:
		cost_ok = true
	elif plant_type == 2 and wood >= 80:
		cost_ok = true

	if not cost_ok:
		print("za malo drewna")
		return false

	var new_plant = PowerPlant.new(position, plant_type as PowerPlant.PlantTypes)
	tilemap_layer.add_child(new_plant)
	ResourceManager.plants.append(new_plant)
	# keep placing mode on until user toggles off per requirement
	plant_placed.emit(plant_type, position)
	return true
	
	
