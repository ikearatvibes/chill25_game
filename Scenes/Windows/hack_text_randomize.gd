extends Control
@onready var hack_text: UsableRichText = $HackText

func  _ready() -> void:
	_on_hack_refresh_timer_timeout()

func _on_hack_refresh_timer_timeout() -> void:
	var text = ""
	for i in range(20):
		text += str(hash(randf()))
	
	hack_text.label_text = text
