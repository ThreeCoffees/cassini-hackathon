class_name HappinessManager extends Control

const MAX_HAPPINESS = 100

var happiness : int = MAX_HAPPINESS :
	set(v):
		happiness = clamp(v, 0, MAX_HAPPINESS)
		happiness_info.set_label(str(happiness))
		
		
@export var happiness_info: PropertyInfo

func _ready() -> void:
	for faction in CityManager._faction_infos:
		faction.happiness_changed.connect(on_happiness_changed)
	happiness_info.set_label(str(happiness))
	
func on_happiness_changed(val):
	print(val)
	happiness = val
