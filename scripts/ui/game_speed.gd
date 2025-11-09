extends Control

# Simple game speed toggler: placed on the `GameSpeed` Control node in the scene.
# It connects to the child Button `PauseSpeedButton` and updates its child Label
# `PauseSpeedButton/GameSpeedLabel`.
var speeds := [0.0, 1.0, 2.0, 4.0]
var index := 1

#@onready var pause_button: Button = $PauseSpeedButton if has_node("PauseSpeedButton") else null
#@onready var speed_label: Label = $PauseSpeedButton/GameSpeedLabel if has_node("PauseSpeedButton/GameSpeedLabel") else null
@export var pause_button: Button
@export var speed_label: Label


func _ready() -> void:
	_update_speed()
	if pause_button != null:
		var cb = Callable(self, "_on_pressed")
		if not pause_button.is_connected("pressed", cb):
			pause_button.connect("pressed", cb)

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
		push_warning("No game speed label found in PauseSpeedButton")
