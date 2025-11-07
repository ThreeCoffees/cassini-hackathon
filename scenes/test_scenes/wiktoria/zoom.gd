class_name ZoomingCamera2D
extends Camera2D

# --- Zmienne Zoomu ---
@export var min_zoom := 0.15
@export var max_zoom := 2.0
@export var zoom_factor := 0.1
@export var zoom_duration := 0.2

# --- Zmienne Ruchu ---
# Prędkość, z jaką kamera będzie się poruszać (w pikselach na sekundę).
@export var move_speed := 1000.0

var _zoom_level := 1.0: set = _set_zoom_level
var _active_tween: Tween

func _ready() -> void:
	# Ustawia wewnętrzną zmienną zoomu na minimum
	_zoom_level = min_zoom
	# Natychmiast ustawia faktyczny zoom kamery na tę wartość (pomijając animację startową)
	zoom = Vector2(_zoom_level, _zoom_level)


# --- Funkcja Process (Ruch) ---

# _process jest wywoływana w każdej klatce.
# Używamy jej do płynnego sprawdzania, czy klawisze ruchu są wciśnięte.
func _process(delta: float) -> void:
	# Pobiera wektor kierunku na podstawie akcji zdefiniowanych w Input Map.
	# Zwraca np. (1, 0) gdy wciśnięte "D", (-1, 0) dla "A", (0, -1) dla "W" itd.
	# Obsługuje też kombinacje (np. "W" i "D" da (1, -1)).
	var input_direction := Input.get_vector(
		"left", 
		"right", 
		"up", 
		"down"
	)
	
	# Aktualizuje pozycję kamery.
	# Mnożymy kierunek przez prędkość i czas (delta), aby ruch był płynny i niezależny od FPS.
	position += input_direction * move_speed * delta


# --- Funkcje Zoomu ---

func _set_zoom_level(value: float) -> void:
	_zoom_level = clamp(value, min_zoom, max_zoom)

	if _active_tween:
		_active_tween.kill()

	_active_tween = create_tween()
	_active_tween.tween_property(
		self,
		"zoom",
		Vector2(_zoom_level, _zoom_level),
		zoom_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		self._zoom_level = _zoom_level - zoom_factor
		
	if event.is_action_pressed("zoom_out"):
		self._zoom_level = _zoom_level + zoom_factor
