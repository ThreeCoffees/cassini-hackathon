extends Node

@export var terrain_tilemap: TerrainTilemapLayer 
@export var plant_placer: PowerPlantPlacer
@export var button1: Button
@export var button2: Button
@export var button3: Button

func _ready():
	terrain_tilemap.plant_position_picked.connect(plant_placer.OnPositionPicked)
	button1.plant_chosen.connect(plant_placer.OnPlantPicked)
	button2.plant_chosen.connect(plant_placer.OnPlantPicked)
	button3.plant_chosen.connect(plant_placer.OnPlantPicked)
