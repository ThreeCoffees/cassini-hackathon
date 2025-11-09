extends Button


func _on_pressed():
	print('start')
	MapDataGlobal.fetch_map()
	print('end')
