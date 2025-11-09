class_name PowerPlantAdder extends BaseButton

@export var type : int = -1

signal plant_chosen(type : int)

func _ready() -> void:
	# Connect pressed signal safely using Callable
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed() -> void:
	emit_signal("plant_chosen", type)
