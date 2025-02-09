extends WindowsBase

var completion_percent : float = 0
var y_variation : float = .05
var stonk_pos : Array[float] = []
var pips : Array[Control] = []
var max_pips : int = 35
@onready var stonk_container: HBoxContainer = $Background/stonk_container

const STOCK_PIP = preload("res://Scenes/stock_pip.tscn")

func _ready() -> void:
	SignalBus.completion_percent_update.connect(update_completion_percent)

func update_completion_percent(new_percent : float):
	completion_percent = new_percent

func stonk_tick():
	var pip_pos = get_stonk_pos()
	
	var new_pip = STOCK_PIP.instantiate()
	stonk_container.add_child(new_pip)
	new_pip.set_pip_y_pos(pip_pos)
	
	pips.append(new_pip)
	
	if pips.size() > max_pips:
		pips[0].queue_free()
		pips.remove_at(0)

func get_stonk_pos():
	return (completion_percent) + randf_range(-y_variation, y_variation)


func _on_stonk_cooldown_timeout() -> void:
	stonk_tick()
