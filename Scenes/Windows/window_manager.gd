extends Control

@export var puzzle_progression : Array[Puzzle]
var current_puzzle_index : int = 0

@onready var window: PuzzleWindow = $Window
@onready var cpu_particles_2d: CPUParticles2D = $ParticlePlacer/CPUParticles2D


func _ready() -> void:
	load_next_puzzle()


func load_next_puzzle():
	window.load_puzzle(puzzle_progression[current_puzzle_index])

func puzzle_solved():
	#put small animation here
	cpu_particles_2d.emitting = true #emit particles
	await get_tree().create_timer(.5).timeout
	
	current_puzzle_index += 1
	if current_puzzle_index == puzzle_progression.size(): 
		print("Game Won!")
		return
	
	load_next_puzzle()
