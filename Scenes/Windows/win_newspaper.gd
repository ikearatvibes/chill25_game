extends Control

@onready var background: Panel = $Background

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background.position = Vector2(2000, 0)
	
	SignalBus.game_finished.connect(enter_anim)


func enter_anim():
	var animation_time = 1
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(background, "position", Vector2(0, 0), animation_time)
	
	await tween.finished
	tween.kill()
