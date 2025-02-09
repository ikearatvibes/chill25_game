extends Control
class_name WindowsBase

var mouse_hovering = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ClickWindow") and mouse_hovering:
		SignalBus.focus_window.emit(self)

func _on_mouse_entered() -> void:
	mouse_hovering = true

func _on_mouse_exited() -> void:
	mouse_hovering = false
