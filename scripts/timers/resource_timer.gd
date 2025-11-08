class_name ResourceTimer extends Timer

@export var debug: bool = false

func _on_timeout():
	ResourceManager.calculate_stores()
