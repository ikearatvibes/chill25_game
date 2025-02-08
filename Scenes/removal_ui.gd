@tool
extends Panel
class_name RemovalUI

@onready var removal_img: TextureRect = $Hbox/RemovalImg
@onready var usable_rich_text: UsableRichText = $Hbox/UsableRichText

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
