extends Node

func _ready():
	var terrain_tilemap = get_node("/root/TilemapGenTest/Tilemap/TerrainTilemapLayer")
	var plant_placer = get_node("/root/TilemapGenTest/PowerPlants/PowerPlantPlacer")
	var button1 = get_node("/root/TilemapGenTest/GUI/PowerPlantUi/PowerPlantAdder/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/Button")
	var button2 = get_node("/root/TilemapGenTest/GUI/PowerPlantUi/PowerPlantAdder/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer/Button")
	var button3 = get_node("/root/TilemapGenTest/GUI/PowerPlantUi/PowerPlantAdder/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer3/VBoxContainer/Button")
	terrain_tilemap.plant_position_picked.connect(plant_placer.OnPositionPicked)
	button1.plant_chosen.connect(plant_placer.OnPlantPicked)
	button2.plant_chosen.connect(plant_placer.OnPlantPicked)
	button3.plant_chosen.connect(plant_placer.OnPlantPicked)
