extends Node


# Clean, single-definition implementation for forest_hp.gd

@export var forest_hp: int = 50
@export var plantable_atlases := [Vector2i(0, 0), Vector2i(3, 0)]

var hp_map: Dictionary[Vector2i, int]= {}
var tilemap_ref: TerrainTilemapLayer = null
var selection_layer: SelectionLayer
var _half_tree_texture: Texture2D = null
var _bigger_tree_texture: Texture2D = null
var overlay_map: Dictionary[Vector2i, Sprite2D] = {}
var pollution_manager : PollutionManager

func assign_hp_to_tilemap(tilemap: TerrainTilemapLayer, sel: SelectionLayer, poll : PollutionManager) -> Dictionary:
	hp_map.clear()
	tilemap_ref = tilemap
	selection_layer = sel
	pollution_manager = poll

	print("forest_hp: assign_hp_to_tilemap called")
	print("forest_hp: tilemap_ref=%s selection_layer=%s" % [tilemap_ref, selection_layer])

	for coords in tilemap.get_used_cells_by_id(1, Vector2i(2, 0)):
		hp_map.set(coords, forest_hp)

	print("forest_hp: registered %d forest tiles" % [hp_map.size()])

	return hp_map

func get_hp(cell: Vector2i) -> int:
	if !hp_map.has(cell):
		return -1
	return hp_map.get(cell)

func damage(cell: Vector2i, amount: int = 1) -> bool:
	if not hp_map.has(cell):
		return false
	
	if pollution_manager.is_polluted(cell):
		amount += 2			#debuff drzew - przyspieszenie niszczenia gdy pollution
	
	hp_map[cell] = max(0, hp_map[cell] - int(amount))

	if hp_map[cell] <= 0:
		if tilemap_ref != null:
			tilemap_ref.set_cell_emit(cell, 1, Vector2i(0, 0), 0)

		hp_map.erase(cell)

		var faction = CityManager.get_cell_exploatation_faction(cell)
		if faction != null:
			faction.remove_worked_tile_by_coords(cell)
			if selection_layer != null:
				selection_layer.clear_worked_tile(cell, faction.id)

		_remove_overlay(cell)
		return true

	_update_overlay_for_cell(cell)

	return true

func restore_hp(cell: Vector2i, amount: int = 1) -> bool:
	if not hp_map.has(cell):
		return false
		
	if pollution_manager.is_polluted(cell):
		amount -= 1			#debuff drzew - przyspieszenie niszczenia gdy pollution
	
	hp_map[cell] += int(amount)
	_update_overlay_for_cell(cell)
	return true

func _get_tile_size() -> Vector2:
	if tilemap_ref == null:
		return Vector2(64, 64)
	var p = tilemap_ref.get("cell_size")
	if p != null:
		return p
	var a = tilemap_ref.map_to_local(Vector2i(1, 1))
	var b = tilemap_ref.map_to_local(Vector2i(0, 0))
	var tile_offset = a - b
	if tile_offset == Vector2.ZERO:
		return Vector2(64, 64)
	return Vector2(abs(tile_offset.x), abs(tile_offset.y))

func _get_tile_center_local(cell: Vector2i) -> Vector2:
	if tilemap_ref == null:
		return Vector2.ZERO

	var local = tilemap_ref.map_to_local(cell)
	var tile_sz := _get_tile_size()
	var tile_offset := tilemap_ref.map_to_local(Vector2i(1, 1)) - tilemap_ref.map_to_local(Vector2i(0, 0))
	if tile_offset != Vector2.ZERO:
		if abs(tile_offset.x - tile_sz.x) < 1.0 and abs(tile_offset.y - tile_sz.y) < 1.0:
			local -= tile_offset

	return local + tile_sz * 0.5

func _load_overlay_textures() -> void:
	if _half_tree_texture == null:
		var half_path = "res://assets/icons/half_tree.png"
		if ResourceLoader.exists(half_path):
			_half_tree_texture = load(half_path)
		else:
			push_warning("forest_hp: half_tree texture not found at %s" % half_path)
	if _bigger_tree_texture == null:
		var big_path = "res://assets/icons/bigger_half_tree.png"
		if ResourceLoader.exists(big_path):
			_bigger_tree_texture = load(big_path)
		else:
			null

func _set_overlay(cell: Vector2i, tex: Texture2D) -> void:
	if tex == null:
		_remove_overlay(cell)
		return
	var sprite: Sprite2D = null
	if overlay_map.has(cell):
		sprite = overlay_map[cell]
		if not is_instance_valid(sprite):
			overlay_map.erase(cell)
			sprite = null
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.z_index = 1
		tilemap_ref.add_child(sprite)
		overlay_map[cell] = sprite
	sprite.texture = tex
	sprite.position = _get_tile_center_local(cell)

func _remove_overlay(cell: Vector2i) -> void:
	if not overlay_map.has(cell):
		return
	var s: Sprite2D = overlay_map[cell]
	if is_instance_valid(s):
		s.queue_free()
	overlay_map.erase(cell)

func _update_overlay_for_cell(cell: Vector2i) -> void:
	if not hp_map.has(cell):
		_remove_overlay(cell)
		return
	var current = hp_map[cell]
	var half_threshold = int(forest_hp / 2)
	var three_quarters = int(forest_hp * 3 / 4)
	_load_overlay_textures()
	if current > three_quarters:
		_remove_overlay(cell)
	elif current > half_threshold and _bigger_tree_texture != null:
		_set_overlay(cell, _bigger_tree_texture)
	else:
		_set_overlay(cell, _half_tree_texture)

func _is_plantable_atlas(atlas: Vector2i) -> bool:
	for a in plantable_atlases:
		if a == atlas:
			return true
	return false

func plant_forest(cell: Vector2i) -> bool:
	if tilemap_ref == null:
		push_warning("forest_hp: tilemap_ref not set, can't plant")
		return false

	print("forest_hp: plant_forest called for %s" % [cell])
	var atlas := Vector2i(-1, -1)
	if tilemap_ref != null:
		atlas = tilemap_ref.get_cell_atlas_coords(cell)
		print("forest_hp: atlas at cell = %s" % [str(atlas)])
	else:
		print("forest_hp: can't read atlas coords for cell")

	if hp_map.has(cell):
		return false

	if not _is_plantable_atlas(atlas):
		print("forest_hp: plant_forest -> not plantable tile, abort (atlas=%s)" % [str(atlas)])
		return false

	hp_map[cell] = 0
	if tilemap_ref != null:
		tilemap_ref.set_cell_emit(cell, 1, Vector2i(2, 0), 0)

	if selection_layer != null:
		selection_layer.set_cell(cell, 0, Vector2i(1, 0))

	_show_temporary_marker(cell)
	_update_overlay_for_cell(cell)
	return true

func _show_temporary_marker(cell: Vector2i) -> void:
	if tilemap_ref == null:
		return
	var size := 16
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 1, 0, 0.6))
	var tex := ImageTexture.create_from_image(img)
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.position = _get_tile_center_local(cell)
	sprite.z_index = 100
	tilemap_ref.add_child(sprite)
	var t := Timer.new()
	t.wait_time = 0.6
	t.one_shot = true
	t.autostart = true
	sprite.add_child(t)
	t.timeout.connect(Callable(sprite, "queue_free"))

func growth_tick(amount: int = 1) -> void:
	if tilemap_ref == null:
		return
	var to_cells := hp_map.keys()
	for c in to_cells:
		var cur = hp_map.get(c)
		if cur < int(forest_hp):
			var newhp = min(int(forest_hp), cur + int(amount))
			hp_map[c] = newhp
			if newhp >= int(forest_hp):
				if tilemap_ref != null:
					tilemap_ref.set_cell_emit(c, 1, Vector2i(2, 0), 0)
				_remove_overlay(c)
			else:
				_update_overlay_for_cell(c)

			newhp = min(int(forest_hp), cur + int(amount))
			hp_map[c] = newhp
			# if fully grown, convert tile to WOODS and remove overlay
			if newhp >= int(forest_hp):
				if tilemap_ref != null:
					tilemap_ref.set_cell_emit(c, 1, Vector2i(2, 0), 0)
				_remove_overlay(c)
			else:
				_update_overlay_for_cell(c)
