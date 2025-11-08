extends Node


# w tym projekcie tilemapy używają atlasowych współrzędnych,
# gdzie indeks "2" odpowiada typowi WOODS/forest (zgodnie z TerrainTilemapLayer.TileTypes).

@export var forest_hp: int = 50

var hp_map: Dictionary[Vector2i, int]= {}
var tilemap_ref: TerrainTilemapLayer = null
var selection_layer: SelectionLayer
var _half_tree_texture: Texture2D = null
var _bigger_tree_texture: Texture2D = null
var overlay_map: Dictionary[Vector2i, Sprite2D] = {}

# Przypisuje domyślne HP dla wszystkich pól lasu na podanej TileMap
func assign_hp_to_tilemap(tilemap: TerrainTilemapLayer, sel: SelectionLayer) -> Dictionary:
	hp_map.clear()
	tilemap_ref = tilemap
	selection_layer = sel

	print("forest_hp: assign_hp_to_tilemap called")
	print("forest_hp: tilemap_ref=%s selection_layer=%s" % [tilemap_ref, selection_layer])

	for coords in tilemap.get_used_cells_by_id(1, Vector2i(2, 0)):
		hp_map.set(coords, forest_hp)

	print("forest_hp: registered %d forest tiles" % [hp_map.size()])

	return hp_map

# Zwraca HP pola (lub -1 jeśli brak)
func get_hp(cell: Vector2i) -> int:
	if !hp_map.has(cell):
		return -1
	return hp_map.get(cell)

# Zmniejsza HP pola o podaną wartość, zwraca true jeśli zastosowano
func damage(cell: Vector2i, amount: int = 1) -> bool:
	if not hp_map.has(cell):
		return false

	hp_map[cell] = max(0, hp_map[cell] - int(amount))

	# Jeśli HP spadło do 0, podmień kafelek na czarny (atlas index 0,0) i usuń z mapy HP
	if hp_map[cell] <= 0:
		if tilemap_ref != null:
			tilemap_ref.set_cell(cell, 1, Vector2i(0, 0), 0)

		# Usuń wpis HP
		hp_map.erase(cell)

		# Spróbuj usunąć pracowane pole z każdej frakcji, jeśli było przypisane.
		var faction = CityManager.get_cell_exploatation_faction(cell)
		if faction != null:
			faction.remove_worked_tile_by_coords(cell)
			if selection_layer != null:
				selection_layer.clear_worked_tile(cell, faction.id)

		# Ensure any overlay sprite for this cell is removed when the forest is gone
		_remove_overlay(cell)
		return true

	# After applying damage, update overlay state for this cell (none/bigger/half)
	_update_overlay_for_cell(cell)

	return true

# Zwiększa HP pola o podaną wartość, zwraca true jeśli zastosowano
func restore_hp(cell: Vector2i, amount: int = 1) -> bool:
	if not hp_map.has(cell):
		return false
	hp_map[cell] += int(amount)
	# After restoring, update overlay state for this cell (none/bigger/half)
	_update_overlay_for_cell(cell)
	return true


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
			# not critical
			#push_warning("forest_hp: bigger_half_tree texture not found at %s" % big_path)
			null

func _set_overlay(cell: Vector2i, tex: Texture2D) -> void:
	# tex==null means remove overlay
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
	# position centered on tile
	var local = tilemap_ref.map_to_local(cell)
	# Defensive access to tile size: some TileMap wrappers expose get_cell_size(),
	# others have a `cell_size` property. Try method first, then property, else default.
	var tile_sz := Vector2(64, 64)
	if tilemap_ref != null:
		if tilemap_ref.has_method("get_cell_size"):
			tile_sz = tilemap_ref.get_cell_size()
		else:
			var prop = tilemap_ref.get("cell_size")
			if prop != null:
				tile_sz = prop
	sprite.position = local + Vector2(tile_sz.x / 2.0, tile_sz.y / 2.0)

func _remove_overlay(cell: Vector2i) -> void:
	if not overlay_map.has(cell):
		return
	var s: Sprite2D = overlay_map[cell]
	if is_instance_valid(s):
		s.queue_free()
	overlay_map.erase(cell)

func _update_overlay_for_cell(cell: Vector2i) -> void:
	# decide which overlay (none / bigger / half) based on current HP
	if not hp_map.has(cell):
		_remove_overlay(cell)
		return
	var current = hp_map[cell]
	var half_threshold = int(forest_hp / 2)
	var three_quarters = int(forest_hp * 3 / 4)
	_load_overlay_textures()
	if current > three_quarters:
		# healthy enough, remove overlay
		_remove_overlay(cell)
	elif current > half_threshold and _bigger_tree_texture != null:
		_set_overlay(cell, _bigger_tree_texture)
	else:
		# at or below half
		_set_overlay(cell, _half_tree_texture)


# Plant a forest at the given tile coordinates.
# Returns true if planted, false if already forest or cannot plant.
func plant_forest(cell: Vector2i) -> bool:
	if tilemap_ref == null:
		push_warning("forest_hp: tilemap_ref not set, can't plant")
		return false

	# If tile already has HP entry, consider it already a forest
	if hp_map.has(cell):
		return false

	# Set tile to WOODS in the tilemap (atlas coords Vector2i(2,0) used by this project)
	tilemap_ref.set_cell(cell, 1, Vector2i(2, 0), 0)
	hp_map[cell] = int(forest_hp)

	# If selection layer exists, refresh visuals for this cell
	if selection_layer != null and selection_layer.has_method("set_cell"):
		selection_layer.set_cell(cell, 0, Vector2i(1, 0))

	# Quick visual feedback so user sees planting worked
	print("forest_hp: planted forest at %s — updating visuals" % [cell])
	_show_temporary_marker(cell)

	# Also attempt to set the tile atlas explicitly so the tile visual updates
	if tilemap_ref != null:
		tilemap_ref.set_cell(cell, 1, Vector2i(2, 0), 0)

	return true

func _show_temporary_marker(cell: Vector2i) -> void:
	# Create a small colored square texture at runtime and show it briefly
	if tilemap_ref == null:
		return
	var size := 16
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 1, 0, 0.6))
	var tex := ImageTexture.create_from_image(img)
	var sprite := Sprite2D.new()
	sprite.texture = tex
	# center the sprite on the tile
	var local = tilemap_ref.map_to_local(cell)
	# Defensive access to tile size (see above)
	var tile_sz2 := Vector2(64, 64)
	if tilemap_ref != null:
		if tilemap_ref.has_method("get_cell_size"):
			tile_sz2 = tilemap_ref.get_cell_size()
		else:
			var prop2 = tilemap_ref.get("cell_size")
			if prop2 != null:
				tile_sz2 = prop2
	sprite.position = local + Vector2(tile_sz2.x / 2.0, tile_sz2.y / 2.0)
	sprite.z_index = 100
	tilemap_ref.add_child(sprite)

	var t := Timer.new()
	t.wait_time = 0.6
	t.one_shot = true
	t.autostart = true
	sprite.add_child(t)
	t.timeout.connect(Callable(sprite, "queue_free"))
