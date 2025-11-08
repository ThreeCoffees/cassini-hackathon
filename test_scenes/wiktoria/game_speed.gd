extends Button

# Simple game speed toggler attached to PauseButton (child label named GameSpeedLabel)
var speeds := [0.0, 1.0, 2.0, 4.0]
var index := 1
@onready var speed_label: Label = has_node("GameSpeedLabel") ? $GameSpeedLabel : null

func _ready():
	# Ensure label exists
	if speed_label == null and has_node("GameSpeedLabel"):
		speed_label = $GameSpeedLabel
	_update_speed()
	# Connect pressed (Button already emits pressed; we handle it)
	if not is_connected("pressed", self, "_on_pressed"):
		connect("pressed", self, "_on_pressed")

func _on_pressed() -> void:
	index = (index + 1) % speeds.size()
	_update_speed()

func _update_speed() -> void:
	var s = speeds[index]
	Engine.time_scale = s
	if speed_label != null:
		if s == 0.0:
			speed_label.text = "Game speed: PAUSED"
		else:
			speed_label.text = "Game speed: %dx" % int(s)
	else:
		print("No game speed label :(((")
