class_name FloatingHealthbar extends Control

@export var label: Label

func set_label(health: int):
	label.text = "%d Trees Left" % health

