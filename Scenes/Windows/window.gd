extends WindowsBase
class_name PuzzleWindow

var current_puzzle : Puzzle = null
var solved_puzzle = false

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
@onready var background: Panel = $Background

var undo_actions : Dictionary #{#add/move, [word, index]}

#removal
var currently_selected_removal : RemovalUI = null
var word_removals : int = 0
var word_moves : int = 0

var editing = false
var removing_words = false
var moving_words = false

@onready var word_removal: RemovalUI = $Background/RemovalUIContainer/WordRemoval
@onready var word_moving: RemovalUI = $Background/RemovalUIContainer/WordMoving

var delete_hint_clicked = false
var word_hint_clicked = false
var restart_hint_clicked = false

@onready var mouse_indicatior: TextureRect = $Background/RestartButton/MouseIndicatior

signal solved #calls when solved

const USABLE_RICH_TEXT = preload("res://Scenes/Text/usable_rich_text.tscn")

#~~~~~Setup~~~~~

#loads a puzzle
func load_puzzle(new_puzzle : Puzzle):
	current_puzzle = new_puzzle
	solved_puzzle = false
	
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

#~~~~~Animations~~~~~
func exit_anim():
	var tween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
	var animation_time = .75
	
	tween.tween_property(background, "position", Vector2(-size.x * 4, 0), animation_time)
	
	await tween.finished
	tween.kill()

func enter_anim():
	background.position = Vector2(size.x * 2, 0)
	var animation_time = 1
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(background, "position", Vector2(0, 0), animation_time)
	
	await tween.finished
	tween.kill()

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
			solved_puzzle = true
			solved.emit()
			return
		#else:
			#print("%s != %s" % [current_copy, split_solution])

#~~~~~Word interaction~~~~~

func word_clicked(word : UsableRichText):
	if removing_words: delete_word(word)

func place_word_before(place_before : UsableRichText, word : UsableRichText):
	var placement_index = current_body_objects.find(place_before)
	var current_index = current_body_objects.find(word)
	
	if placement_index > current_index: placement_index -= 1
	
	current_body_objects.erase(word)
	
	body_word_container.move_child(word, placement_index)
	
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
	
	check_if_failed()

func delete_word(word : UsableRichText):
	if !word_hint_clicked:
		word_hint_clicked = true
		SignalBus.hint_clicked.emit()
	
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
	
	check_if_failed()

func check_if_failed():
	if word_removals == 0 and word_moves == 0 and !solved_puzzle:
		prompt.label_text = "Not bad enough, retry?"
		if !restart_hint_clicked: 
			SignalBus.hint_clicked.emit()
			mouse_indicatior.visible = true

#~~~~~Toggle Removals~~~~~
func removal_ui_clicked(ui : RemovalUI):
	#if theres a removal thats already selected, and its not this
	if currently_selected_removal != null and currently_selected_removal != ui:
		#set it to be unpressed
		currently_selected_removal.button_pressed = false
	
	if ui.button_pressed: currently_selected_removal = ui
	else: currently_selected_removal = null


func _on_word_removal_toggled(toggled_on: bool) -> void:
	if !delete_hint_clicked: 
		SignalBus.hint_clicked.emit()
		delete_hint_clicked = true
	
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
	if mouse_indicatior.visible:
		restart_hint_clicked = true
		mouse_indicatior.visible = false
		SignalBus.hint_clicked.emit()
	
	restart_puzzle()
