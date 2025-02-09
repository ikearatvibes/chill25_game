extends Control
class_name stonk_pip

@export var pip_gradient : Gradient
@onready var pip: Panel = $pip
var pips_color : Color = Color.GREEN

var pip_y_pos : float = .5

func set_pip_y_pos(y_pos : float):
	pip_y_pos = clampf(y_pos, 0, 1)
	
	pip.anchor_top = pip_y_pos
	pip.anchor_bottom = pip_y_pos
	
	var panel = pip.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	
	var pip_color = Color.RED
	var index = 0
	for offset in pip_gradient.get_point_count():
		if pip_gradient.get_offset(offset) > pip_y_pos:
			pip_color = pip_gradient.get_color(offset)
			break
	
	pips_color = pip_color
	
	panel.bg_color = pip_color
	pip.add_theme_stylebox_override("panel", panel)

func draw_line_to_pip(other_pip : stonk_pip):
	var line = Line2D.new()
	line.default_color = pips_color
	line.width = 2
	add_child(line)
	
	line.add_point(pip.global_position)
	line.add_point(other_pip.pip.global_position)
