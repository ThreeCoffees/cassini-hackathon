extends Node


# w tym projekcie tilemapy używają atlasowych współrzędnych,
# gdzie indeks "2" odpowiada typowi WOODS/forest (zgodnie z TerrainTilemapLayer.TileTypes).

@export var forest_hp := 50
@export var forest_atlas_index := 2

var hp_map := {} # klucz: "(x,y)" -> int HP

# Przypisuje domyślne HP dla wszystkich pól lasu na podanej TileMap
func assign_hp_to_tilemap(tilemap) -> Dictionary:
    # Zakładamy, że tilemap ma metodę get_used_rect() i get_cell_atlas_coords(cell: Vector2i)
    hp_map.clear()
    var rect = tilemap.get_used_rect()
    for x in range(int(rect.position.x), int(rect.position.x + rect.size.x)):
        for y in range(int(rect.position.y), int(rect.position.y + rect.size.y)):
            var cell = Vector2i(x, y)
            var atlas = tilemap.get_cell_atlas_coords(cell)
            # atlas.x przechowuje indeks kafla (0..n)
            if atlas.x == int(forest_atlas_index):
                hp_map["(" + str(x) + "," + str(y) + ")"] = int(forest_hp)
    return hp_map

# Zwraca HP pola (lub null jeśli brak)
func get_hp(cell) -> int:
    var key = "(" + str(int(cell.x)) + "," + str(int(cell.y)) + ")"
    return hp_map.get(key)

# Zmniejsza HP pola o podaną wartość, zwraca true jeśli zastosowano
func damage(cell, amount := 1) -> bool:
    var key = "(" + str(int(cell.x)) + "," + str(int(cell.y)) + ")"
    if not hp_map.has(key):
        return false
    hp_map[key] = max(0, hp_map[key] - int(amount))
    return true

# Zwiększa HP pola o podaną wartość, zwraca true jeśli zastosowano
func restore_hp(cell, amount := 1) -> bool:
    var key = "(" + str(int(cell.x)) + "," + str(int(cell.y)) + ")"
    if not hp_map.has(key):
        return false
    hp_map[key] += int(amount)
    return true

