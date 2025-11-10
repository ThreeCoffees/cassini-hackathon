class_name ApiAddressInput extends TextEdit

func _on_text_changed() -> void:
	ApiSettings.set_new_api_address(text)
	print("api address changed")

