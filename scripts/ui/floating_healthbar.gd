class_name FloatingHealthbar extends Control

@export var label: Label
@export var terrain_tilemap_layer: TerrainTilemapLayer

func set_label(health: int):
	label.text = "%d Trees Left" % health

func _process(delta: float) -> void:
	follow_cursor()

	set_visibility()

	if self.visible:
		set_label(ResourceManager.forest_hp_node.get_hp(get_tile_coords()))

func get_tile_coords()-> Vector2i:
	return terrain_tilemap_layer.global_to_tilemap_coordinates(get_viewport().canvas_transform.affine_inverse() * get_global_mouse_position())

func follow_cursor() -> void:
	var cursor_position = get_global_mouse_position()
	position = cursor_position


func set_visibility() -> void:
	var cell_coords = get_tile_coords()
	if terrain_tilemap_layer.get_cell_type(cell_coords) == TerrainTilemapLayer.TileTypes.WOODS:
		show()
	else:
		hide()
