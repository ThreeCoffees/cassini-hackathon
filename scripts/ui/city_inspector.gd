class_name CityInspector extends Control

@export var debug: bool = false
@export var city_label: Label

@export var population_info: PropertyInfo
@export var food_yield_info: PropertyInfo
@export var wood_yield_info: PropertyInfo

@export var food_requirement_info: PropertyInfo
@export var energy_requirement_info: PropertyInfo

func _ready() -> void:
	_on_faction_picked(-1)


func _on_faction_picked(faction_id: int) -> void:
	if debug:
		print("faction %d picked" % faction_id)

	if faction_id == -1:
		hide()
		return
	else:
		show()

	city_label.text = "City %d" % faction_id

	var faction_info: Faction = CityManager.get_faction(faction_id)

	if debug: 
		faction_info.print()
	
	population_info.set_label(str(faction_info.population))
	food_requirement_info.set_label(str(faction_info.food_requirement))
	energy_requirement_info.set_label(str(faction_info.energy_requirement))

	food_yield_info.set_label(str(faction_info.food_yields))
	wood_yield_info.set_label(str(faction_info.wood_yields))

func _on_faction_info_changed(faction_id: int) -> void:
	var faction_info: Faction = CityManager.get_faction(faction_id)

	population_info.set_label(str(faction_info.population))
	food_requirement_info.set_label(str(faction_info.food_requirement))
	energy_requirement_info.set_label(str(faction_info.energy_requirement))

	food_yield_info.set_label(str(faction_info.food_yields))
	wood_yield_info.set_label(str(faction_info.wood_yields))


