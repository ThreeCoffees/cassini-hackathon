class_name TerrainTilemapLayer extends TileMapLayer

@export var debug: bool = false

signal faction_picked(faction_id: int)
signal plant_position_picked(position :Vector2i, parent : TerrainTilemapLayer)
signal worked_cell_picked(faction_id: int, cell_coords: Vector2i)

signal tile_changed(coords: Vector2i)
signal terrain_generated()

var selected_city: int = -1
var _drag_start_cell = null
var _dragging: bool = false
var _drag_start_type: int = 0
var _drag_start_global: Vector2 = Vector2.ZERO
var _drag_rect: Rect2 = Rect2()
var _marquee_line: Line2D = null

func _on_selected_city_set(new_city: int):
	selected_city = new_city
	faction_picked.emit(selected_city)

enum TileTypes{
	NONE,
	WATER,
	WOODS,
	AGRI,
	CITY,
}

func set_cell_emit(coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0):
	set_cell(coords, source_id, atlas_coords, alternative_tile)
	tile_changed.emit(coords)

func on_generation_finished():
	terrain_generated.emit()

func global_to_tilemap_coordinates(global_pos):
	var local_pos = to_local(global_pos)
	var hovered_cell = local_to_map(local_pos)
	return hovered_cell
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		_on_selected_city_set(-1)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var selected_cell = global_to_tilemap_coordinates(get_global_mouse_position())
		if debug:
			print("clicked tilemap layer (%d, %d)" % [selected_cell.x, selected_cell.y])

		# Quick forest planting: Ctrl+LeftClick on AGRI to plant a forest (minimal UX)
		# `event.control` isn't available on InputEventMouseButton in all engine versions;
		# check the global Input state instead.
		if Input.is_key_pressed(KEY_CTRL):
			var t_check = get_cell_type(selected_cell)

			if debug:
				print("Ctrl pressed; cell type=%s" % [str(t_check)])
			if t_check == TileTypes.AGRI:
				if ResourceManager.forest_hp_node != null:
					var planted: bool = ResourceManager.forest_hp_node.plant_forest(selected_cell)
					if debug:
						print("Attempted to plant at %s -> result=%s" % [selected_cell, str(planted)])
					if planted:
						# planted — don't run normal select/drag logic for this click
						return
				else:
					if debug:
						print("No forest_hp_node registered or plant_forest missing")


			#if t_check == TileTypes.AGRI:
				# (planting handled above when ResourceManager.forest_hp_node is present)


		
		_drag_start_cell = selected_cell
		_dragging = false
		var t = get_cell_type(selected_cell)
		
		if t == TileTypes.AGRI or t == TileTypes.WOODS:
			_drag_start_type = t
			_drag_start_global = get_global_mouse_position()
			_drag_rect = Rect2(to_local(_drag_start_global), Vector2.ZERO)
			# create a Line2D to draw marquee if possible
			if _marquee_line == null:
				_marquee_line = Line2D.new()
				_marquee_line.width = 2.0
				_marquee_line.default_color = Color(0.5, 0.5, 0.5)
				add_child(_marquee_line)
		else:
			# disable drag-selection for other tile types
			_drag_start_type = TileTypes.NONE

		handle_select_cell(selected_cell)

	
	# Detect dragging while left button is held
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _drag_start_cell != null:
		# only start dragging if we allowed a drag type
		if _drag_start_type == TileTypes.AGRI or _drag_start_type == TileTypes.WOODS:
			_dragging = true
			# update drag rectangle and marquee line
			var curr_global = get_global_mouse_position()
			var local_start = to_local(_drag_start_global)
			var local_curr = to_local(curr_global)
			_drag_rect.position = local_start
			_drag_rect.size = local_curr - local_start
			if _marquee_line != null:
				var a = local_start
				var b = Vector2(local_curr.x, local_start.y)
				var c = local_curr
				var d = Vector2(local_start.x, local_curr.y)
				_marquee_line.points = [a, b, c, d, a]

	# On left mouse release: if we were dragging, compute rectangle and pick multiple tiles
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		if _dragging and _drag_start_cell != null and selected_city != -1 and (_drag_start_type == TileTypes.AGRI or _drag_start_type == TileTypes.WOODS):
			var end_cell = global_to_tilemap_coordinates(get_global_mouse_position())
			var min_x = min(_drag_start_cell.x, end_cell.x)
			var max_x = max(_drag_start_cell.x, end_cell.x)
			var min_y = min(_drag_start_cell.y, end_cell.y)
			var max_y = max(_drag_start_cell.y, end_cell.y)

			var cells: Array = []
			for x in range(min_x, max_x + 1):
				for y in range(min_y, max_y + 1):
					var c = Vector2i(x, y)
					if get_cell_type(c) == _drag_start_type:
						cells.append(c)

			# Call SelectionLayer helper if present
			var sel_path = "../SelectionLayer"
			if has_node(sel_path):
				var sel = get_node(sel_path)
				sel.pick_multiple_worked_tiles(selected_city, cells, _drag_start_type)

		_drag_start_cell = null
		_dragging = false
		_drag_rect = Rect2()
		if _marquee_line != null:
			_marquee_line.queue_free()
			_marquee_line = null

func _draw():
	if _drag_rect.size != Vector2.ZERO:
		draw_rect(_drag_rect, Color(0.5, 0.5, 0.5), false)

func get_cell_type(coords: Vector2i) -> TileTypes:
	if !get_used_rect().has_point(coords):
		return TileTypes.NONE
	return get_cell_atlas_coords(coords).x as TileTypes
		
func handle_select_cell(cell_coords: Vector2i):
	var cell_type = get_cell_type(cell_coords)
	match cell_type:
		TileTypes.CITY:
			_on_selected_city_set(CityManager.get_cell_faction_id(cell_coords))
			if debug:
				print("CITY STANDS AT YOUR COMMAND: ", selected_city)
		TileTypes.AGRI, TileTypes.WOODS:
			if selected_city != -1:
				worked_cell_picked.emit(selected_city, cell_coords, cell_type)
				if debug:
					print("GET BACK TO WORK")
		TileTypes.NONE:
			plant_position_picked.emit(map_to_local(cell_coords), self)
