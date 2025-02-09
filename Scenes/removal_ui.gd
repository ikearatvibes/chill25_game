@tool
extends Button
class_name RemovalUI

@onready var removal_img: TextureRect = $Hbox/RemovalImg
@onready var usable_rich_text: UsableRichText = $Hbox/UsableRichText

var pressed_pos = 4
var pressed_down = false

@export var amount : int = 0:
	set(value):
		amount = value
		if !is_inside_tree(): return
		usable_rich_text.label_text = amount_base % amount

@export var amount_base : String = "- %s ":
	set(value):
		amount_base = value
		amount = amount #redeclare to recall its setter

@export var texture : Texture:
	set(value):
		texture = value
		if !is_inside_tree(): return
		removal_img.texture = value

func _ready() -> void:
	removal_img.texture = texture


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if pressed_down: return
		pressed_down = true
		position.y += pressed_pos
	else:
		if !pressed_down: return
		pressed_down = false
		position.y -= pressed_pos

func _on_button_down() -> void:
	if !button_pressed:
		if pressed_down: return
		pressed_down = true
		position.y += pressed_pos
	else:
		if !pressed_down: return
		pressed_down = false
		position.y -= pressed_pos

func _on_button_up() -> void:
	if !button_pressed:
		if !pressed_down: return
		pressed_down = false
		position.y -= pressed_pos
	else:
		if pressed_down: return
		pressed_down = true
		position.y += pressed_pos
