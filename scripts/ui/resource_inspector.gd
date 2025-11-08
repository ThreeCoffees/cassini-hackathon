class_name ResourceInspector extends Control

@export var debug: bool = false

@export var wood_info: PropertyInfo
@export var food_info: PropertyInfo
@export var population_info: PropertyInfo
@export var energy_info: PropertyInfo

func _ready() -> void:
	on_global_resources_updated()
	ResourceManager.global_resources_updated.connect(on_global_resources_updated)

func on_global_resources_updated():
	var resources = ResourceManager.resources
	if debug:
		print("global resources updated")
	for res_data in resources.values():
		match res_data.type:
			"wood":
				wood_info.set_label(res_data.get_label())
			"food":
				food_info.set_label(res_data.get_label())
			"energy":
				energy_info.set_label(res_data.get_label())
