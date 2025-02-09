@tool
extends Panel

@export var window_focus : WindowsBase
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var usable_rich_text: UsableRichText = $HBoxContainer/UsableRichText

var mouse_hovering = false


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): 
		return
	
	if Input.is_action_just_pressed("ClickWindow") and mouse_hovering:
		print("Clicked")
		SignalBus.focus_window.emit(window_focus)

@export var icon : Texture:
	set(value):
		icon = value
		if !is_inside_tree(): return
		texture_rect.texture = icon

@export var text : String:
	set(value):
		text = value
		if !is_inside_tree(): return
		usable_rich_text.label_text = text

func _ready() -> void:
	texture_rect.texture = icon
	usable_rich_text.label_text = text


func _on_mouse_entered() -> void:
	mouse_hovering = true

func _on_mouse_exited() -> void:
	mouse_hovering = false
