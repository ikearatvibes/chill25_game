@tool
extends Button
class_name UsableRichText

signal word_pressed(word : UsableRichText)

@onready var rich_text_label: RichTextLabel = $RichTextLabel

@export_multiline var label_text : String = "Text":
	set(value):
		label_text = value
		text = label_text
		if !is_inside_tree(): return #skip if not loaded
		rich_text_label.text = default_text_bbcode % value

@export var text_size : int = 32:
	set(value):
		text_size = value
		if !is_inside_tree(): return #skip if not loaded
		change_text_sizes(text_size)

@export_multiline var default_text_bbcode : String = "%s":
	set(value):
		default_text_bbcode = value
		#reset text with new bbcode
		label_text = label_text


@export var text_autowrap_mode : TextServer.AutowrapMode = TextServer.AutowrapMode.AUTOWRAP_WORD_SMART:
	set(value):
		autowrap_mode = value
		text_autowrap_mode = value
		if !is_inside_tree(): return #skip if not loaded
		rich_text_label.autowrap_mode = value

@export var color : Color = Color.BLACK:
	set(value):
		color = value
		if !is_inside_tree(): return #skip if not loaded
		rich_text_label.add_theme_color_override("default_color", color)

func _ready() -> void:
	rich_text_label.text = default_text_bbcode % label_text
	change_text_sizes(text_size)
	rich_text_label.autowrap_mode = autowrap_mode
	rich_text_label.add_theme_color_override("default_color", color)

func change_text_sizes(new_size : int):
	add_theme_font_size_override("font_size", new_size)
	rich_text_label.add_theme_font_size_override("normal_font_size", new_size)
	rich_text_label.add_theme_font_size_override("bold_italics_font_size", new_size)
	rich_text_label.add_theme_font_size_override("mono_font_size", new_size)
	rich_text_label.add_theme_font_size_override("italics_font_size", new_size)
	rich_text_label.add_theme_font_size_override("bold_font_size", new_size)



func delete():
	queue_free()


func _on_pressed() -> void:
	word_pressed.emit(self)
