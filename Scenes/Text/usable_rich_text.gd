@tool
extends Button
class_name UsableRichText

var dragging = false
var draggable = false

signal word_pressed(placement_word : UsableRichText, new_word : UsableRichText)

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

@export_multiline var default_text_bbcode : String = "[wave amp=10.0 freq=.25 connected=1]%s[/wave]":
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

const USABLE_RICH_TEXT = preload("res://Scenes/Text/usable_rich_text.tscn")

signal place_text_before(new_text : UsableRichText)

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

#~~~~~Dragging~~~~~

func _get_drag_data(at_position: Vector2) -> Variant:
	if !draggable: return
	
	var text = USABLE_RICH_TEXT.instantiate()
	text.label_text = label_text
	text.text_size = text_size
	
	var preview = Control.new()
	preview.size = Vector2(30, 30)
	
	preview.add_child(text)
	
	set_drag_preview(preview)
	
	rich_text_label.text = ""
	text = ""
	
	dragging = true
	
	return self

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is UsableRichText

func _drop_data(at_position: Vector2, data: Variant) -> void:
	place_text_before.emit(self, data)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and dragging:
		label_text = label_text
		dragging = false


func delete():
	var tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "text_size", 1, .2)
	tween.parallel().tween_property(self, "color", Color.RED, .2)
	
	await tween.finished
	
	queue_free()


func _on_pressed() -> void:
	word_pressed.emit(self)
