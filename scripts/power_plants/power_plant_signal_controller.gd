extends Node

@export var terrain_tilemap: TerrainTilemapLayer
@export var plant_placer: PowerPlantPlacer
@export var button1: PowerPlantAdder
@export var button2: PowerPlantAdder
@export var button3: PowerPlantAdder

var placing_mode: bool = false
var current_type: int = -1

func _ready() -> void:
	# Listen for terrain clicks and handle placements centrally
	if terrain_tilemap != null:
		terrain_tilemap.plant_position_picked.connect(Callable(self, "_on_plant_position_picked"))

	# Connect plant buttons
	for b in [button1, button2, button3]:
		if b == null:
			continue
		if b.has_signal("plant_chosen"):
			b.plant_chosen.connect(Callable(self, "_on_button_chosen"))
		else:
			# fallback: connect pressed and expect `type` exported on script
			b.connect("pressed", Callable(self, "_on_button_pressed"), [b])

	_update_button_states()

func _on_button_pressed(b: Button) -> void:
	# fallback pressed handler: try to read exported `type` from the button script
	var t: int = -1
	if b.get_script() != null:
		var maybe = b.get("type")
		if typeof(maybe) == TYPE_INT:
			t = maybe
	if t == -1 and b.has_meta("plant_type"):
		var m = b.get_meta("plant_type")
		if typeof(m) == TYPE_INT:
			t = m
	if t == -1:
		push_warning("Couldn't infer plant type for %s" % [b.get_class()])
		return
	_on_button_chosen(t)

func _on_button_chosen(type: int) -> void:
	# Toggle placing mode: clicking same button again disables placing
	if placing_mode and current_type == type:
		placing_mode = false
		current_type = -1
		plant_placer.set_placing(false)
	else:
		placing_mode = true
		current_type = type
		plant_placer.toggle_placing(type)

	_update_button_states()

func _on_plant_position_picked(position: Vector2i, tilemap_layer: TerrainTilemapLayer) -> void:
	if not placing_mode:
		return
	var placed := plant_placer.OnPositionPicked(position, tilemap_layer)
	if placed:
		# keep placing until user toggles off
		pass

func _update_button_states() -> void:
	for b in [button1, button2, button3]:
		if b == null:
			continue
		var pressed_state: bool = placing_mode and current_type == b.type
		b.set_pressed(pressed_state)
