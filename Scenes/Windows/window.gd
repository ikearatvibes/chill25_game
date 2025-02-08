extends Control
class_name PuzzleWindow

var current_puzzle : Puzzle = null

#texts
var current_body : Array[String] = []:
	set(value):
		current_body = value
		#check if the puzzle is solved when updated
		words_updated()
var current_body_objects : Array[UsableRichText]
@onready var body_word_container: HFlowContainer = $Background/Email/Body/BodyWordContainer

@onready var title_text: UsableRichText = $Background/Email/HeaderLine/TitleText
@onready var prompt: UsableRichText = $Background/Prompt

#removal
var currently_selected_removal : RemovalUI = null
var word_removals : int = 0
var word_moves : int = 0

var editing = false
var removing_words = false
var moving_words = false

@onready var word_removal: RemovalUI = $RemovalUIContainer/WordRemoval
@onready var word_moving: RemovalUI = $RemovalUIContainer/WordMoving


signal solved #calls when solved

const USABLE_RICH_TEXT = preload("res://Scenes/Text/usable_rich_text.tscn")


#~~~~~Setup~~~~~

#loads a puzzle
func load_puzzle(new_puzzle : Puzzle):
	current_puzzle = new_puzzle
	
	#load the body words
	load_body_words()
	
	#loads the title
	load_title()
	
	#load removal amounts
	load_editing_amounts()
	
	#load the prompt/hint text
	load_prompt()

func restart_puzzle():
	load_puzzle(current_puzzle)

func load_body_words():
	#reset words
	current_body.clear()
	remove_body_objects()
	
	#get word list
	current_body = current_puzzle.starting_text.split(" ")
	
	#error check
	if current_body.size() == 0:
		print("ERROR: Body of text failed to load :(")
		return
	
	
	#load in word objects
	for word in current_body:
		var word_object = USABLE_RICH_TEXT.instantiate()
		#add to array
		current_body_objects.append(word_object)
		#place in scene
		body_word_container.add_child(word_object)
		#update text
		word_object.label_text = word
		#connect clicked signal
		word_object.word_pressed.connect(word_clicked)
		word_object.place_text_before.connect(place_word_before)

func remove_body_objects():
	while current_body_objects.size() > 0:
		current_body_objects[0].delete()
		current_body_objects.remove_at(0)

func load_title():
	title_text.label_text = current_puzzle.title

func load_editing_amounts():
	word_removals = current_puzzle.word_deletes
	word_moves = current_puzzle.word_moves
	
	if word_removals == 0: word_removal.visible = false
	else: setup_removal_ui(word_removal, word_removals)
	
	if word_moves == 0: word_moving.visible = false
	else: setup_removal_ui(word_moving, word_moves)

func load_prompt():
	prompt.label_text = current_puzzle.prompt

func setup_removal_ui(ui : RemovalUI, amount : int):
	ui.visible = true
	ui.amount = amount

#~~~~~Puzzle Checking~~~~~

func words_updated():
	for solution in current_puzzle.solved_text:
		var split_solution = solution.split(" ") as Array
		
		#lowercase everything
		for i in range(split_solution.size()): split_solution[i] = split_solution[i].to_lower()
		var current_copy = []
		for i in current_body: current_copy.append(i.to_lower())
		
		#compare body with solution
		if current_copy == split_solution:
			print("Solved!")
			solved.emit()
			return
		#else:
			#print("%s != %s" % [current_copy, split_solution])

#~~~~~Word interaction~~~~~

func word_clicked(word : UsableRichText):
	if removing_words: delete_word(word)

func place_word_before(place_before : UsableRichText, word : UsableRichText):
	var placement_index = 0
	for i in current_body_objects:
		if i == place_before: break
		
		placement_index += 1
	
	print("Placing word @ " + str(placement_index))
	
	body_word_container.move_child(word, placement_index)
	
	current_body_objects.erase(word)
	current_body_objects.insert(placement_index, word)
	
	var word_word = word.label_text
	
	current_body.erase(word_word)
	current_body.insert(placement_index, word_word)
	
	#manage word moves
	
	word_moves -= 1
	word_moving.amount = word_moves
	if word_moves == 0:
		word_moving.button_pressed = false
		word_moving.visible = false
		_on_word_move_toggled(false)
	
	words_updated()

func delete_word(word : UsableRichText):
	#skip if no removals
	if word_removals <= 0: return
	
	#remove word from the object and word containers
	current_body.erase(word.label_text)
	current_body_objects.erase(word)
	
	#delete the word
	word.delete()
	
	
	word_removals -= 1
	word_removal.amount = word_removals
	if word_removals == 0:
		word_removal.button_pressed = false
		word_removal.visible = false
		_on_word_removal_toggled(false)
	
	words_updated()

#~~~~~Toggle Removals~~~~~
func removal_ui_clicked(ui : RemovalUI):
	#if theres a removal thats already selected, and its not this
	if currently_selected_removal != null and currently_selected_removal != ui:
		#set it to be unpressed
		currently_selected_removal.button_pressed = false
	
	if ui.button_pressed: currently_selected_removal = ui
	else: currently_selected_removal = null


func _on_word_removal_toggled(toggled_on: bool) -> void:
	removal_ui_clicked(word_removal)
	
	if toggled_on:
		removing_words = true
		moving_words = false
		editing = true
	else:
		removing_words = false
		editing = false


func _on_word_move_toggled(toggled_on: bool) -> void:
	removal_ui_clicked(word_moving)
	
	if toggled_on:
		removing_words = false
		moving_words = true
		editing = true
	else:
		moving_words = false
		editing = false
	
	set_draggable_state(moving_words)

func set_draggable_state(on : bool):
	for word in current_body_objects:
		word.draggable = on

#~~~~~Restart~~~~~
func _on_restart_button_pressed() -> void:
	restart_puzzle()
