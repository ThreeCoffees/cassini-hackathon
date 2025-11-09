class_name Pollution
extends Sprite2D

var level : float # czy mocno zanieczyszcza czy srednio
var propagation_propability : float
var rng = RandomNumberGenerator.new()
var pollution_manager : PollutionManager
var tilemap : TerrainTilemapLayer

func _init(pol_lvl : float, pol_pos : Vector2, pol_pro : float, parent : PollutionManager) -> void:
	level = pol_lvl
	position = pol_pos
	propagation_propability = pol_pro 
	texture = load("res://assets/icons/pollution.png")
	pollution_manager = parent
	tilemap = parent.tilemap_layer

func try_propagation():
	var rand = rng.randf_range(0,5)
	if (rand > propagation_propability):
		propagate()
		propagation_propability = min(4.95, propagation_propability+0.1)

func propagate():
	var arr_position = tilemap.local_to_map(position)
	print(arr_position)
	var rand = rng.randf()
	if rand < 0.25:
		if not pollution_manager.is_polluted(Vector2(arr_position.x+1,arr_position.y)):
			pollution_manager.add_polution(Vector2(arr_position.x+1,arr_position.y))
	elif rand < 0.5:
		if not pollution_manager.is_polluted(Vector2(arr_position.x-1,arr_position.y)):
			pollution_manager.add_polution(Vector2(arr_position.x-1,arr_position.y))
	elif rand < 0.75:
		if not pollution_manager.is_polluted(Vector2(arr_position.x,arr_position.y+1)):
			pollution_manager.add_polution(Vector2(arr_position.x,arr_position.y+1))
	else:
		if not pollution_manager.is_polluted(Vector2(arr_position.x,arr_position.y-1)):
			pollution_manager.add_polution(Vector2(arr_position.x,arr_position.y-1))
	
