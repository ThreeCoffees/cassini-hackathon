class_name Pollution
extends Sprite2D

var level : float # czy mocno zanieczyszcza czy srednio
var propagation_propability : int
var rng = RandomNumberGenerator.new()
@export var pollution_manager : PollutionManager

func _init(pol_lvl : float, pol_pos : Vector2, pol_pro : int) -> void:
	level = pol_lvl
	position = pol_pos
	propagation_propability = pol_pro
	texture = load("res://assets/icons/power.png")

func try_propagation():
	var rand = rng.randf_range(0,5)
	if (rand > propagation_propability):
		propagate()

func propagate():
	var rand = rng.randf()
	if rand < 0.25:
		if not pollution_manager.is_polluted(Vector2(position.x+1,position.y)):
			pollution_manager.add_polution(Vector2(position.x+1,position.y))
	elif rand < 0.5:
		if not pollution_manager.is_polluted(Vector2(position.x-1,position.y)):
			pollution_manager.add_polution(Vector2(position.x-1,position.y))
	elif rand < 0.75:
		if not pollution_manager.is_polluted(Vector2(position.x,position.y+1)):
			pollution_manager.add_polution(Vector2(position.x,position.y+1))
	else:
		if not pollution_manager.is_polluted(Vector2(position.x,position.y-1)):
			pollution_manager.add_polution(Vector2(position.x,position.y-1))
	
