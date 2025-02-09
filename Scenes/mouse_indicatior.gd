extends TextureRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var hint_clicked_tick = 1
var hints_clicked = 0

func _ready() -> void:
	SignalBus.hint_clicked.connect(hint_clicked)
	animation_player.play("Mouse Hover")
	
	if hint_clicked_tick == 1:
		await get_tree().create_timer(2).timeout
		visible = true

func hint_clicked():
	hints_clicked += 1
	if hint_clicked_tick == hints_clicked:
		queue_free()
	
	if hints_clicked == hint_clicked_tick -1:
		visible = true
