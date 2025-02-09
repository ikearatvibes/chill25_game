extends Panel
@onready var time_text: UsableRichText = $Time2/TimeText

var time = Time.get_time_dict_from_system()

func _process(delta: float) -> void:
	var afternoon = "AM"
	if time["hour"] > 12: afternoon = "PM"
	
	time_text.label_text = "%s:%s %s" % [time["hour"] % 12, "%002d" % time["minute"], afternoon]
