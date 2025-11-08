class_name CityInspector extends Control

@export var debug: bool = false
@export var city_label: Label
@export var properties_container: VBoxContainer

func _on_faction_picked(faction_id: int) -> void:
	if debug:
		print("faction %d picked" % faction_id)
	city_label.text = "City %d" % faction_id

