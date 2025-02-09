extends Control

@export var puzzle_progression : Array[Puzzle]
var current_puzzle_index : int = 0
var completion_percent : float = 0

var puzzle_completed = false

@onready var window: PuzzleWindow = $Window
@onready var cpu_particles_2d: CPUParticles2D = $ParticlePlacer/CPUParticles2D
@onready var next_button: Button = $Window/NextButton

func _ready() -> void:
	SignalBus.focus_window.connect(focus_window)
	
	load_next_puzzle()


func load_next_puzzle():
	puzzle_completed = false
	
	window.load_puzzle(puzzle_progression[current_puzzle_index])
	MusicManager.play_random_pitch(MusicManager.mail_in)
	
	await window.enter_anim()

func puzzle_solved():
	#put small animation here
	cpu_particles_2d.emitting = true #emit particles
	MusicManager.play_random_pitch(MusicManager.mail_succeed)
	await get_tree().create_timer(.5).timeout
	
	if puzzle_completed: return
	puzzle_completed = true
	
	next_button.visible = true
	
	await next_button.pressed
	
	next_button.visible = false
	
	current_puzzle_index += 1
	if current_puzzle_index == puzzle_progression.size(): 
		SignalBus.game_finished.emit()
		print("Game Won!")
		return
	
	MusicManager.play_random_pitch(MusicManager.mail_out)
	await window.exit_anim()
	
	completion_percent = float(current_puzzle_index) / float(puzzle_progression.size() - 1) #-1 for end message
	SignalBus.completion_percent_update.emit(completion_percent)
	
	load_next_puzzle()


func focus_window(window : WindowsBase):
	var children = get_children()
	
	if !children.has(window): return
	
	print("Moving child to top layer")
	move_child(window, -1)
