extends Node

@onready var click: AudioStreamPlayer = $Click
@onready var mail_out: AudioStreamPlayer = $MailOut
@onready var mail_in: AudioStreamPlayer = $MailIn
@onready var mail_succeed: AudioStreamPlayer = $MailSucceed

var pitch_variation = .2

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ClickWindow"):
		play_random_pitch(click)

func play_random_pitch(sound):
	var pitch = 1 + randf_range(-pitch_variation, pitch_variation)
	
	sound.pitch_scale = pitch
	sound.play()
