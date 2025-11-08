class_name PowerPlantAdder extends BaseButton

@export var type : int 

signal plant_chosen(type : int)

func _ready():
	pressed.connect(on_press)
	
	
func on_press():
	plant_chosen.emit(type)
