class_name ResourceTimer extends Timer

@export var debug: bool = false
@export var happiness_bar : ProgressBar
@export var pollution_manager : PollutionManager

func _on_timeout():
	ResourceManager.calculate_stores()
	happiness_bar.set_value_no_signal(ResourceManager.get_happiness())
	pollution_manager.propagate_all()
