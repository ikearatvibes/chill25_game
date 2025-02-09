extends HSlider



func _on_value_changed(value: float) -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	
	AudioServer.set_bus_volume_db(master_bus, value)
