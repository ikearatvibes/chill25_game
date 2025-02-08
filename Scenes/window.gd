extends Control

@export var current_puzzle : Puzzle = null

var current_body : Array[String] = []
var current_body_objects : Array[UsableRichText]


@onready var body_word_container: HFlowContainer = $Background/Email/Body/BodyWordContainer

@onready var title_text: UsableRichText = $Background/Email/HeaderLine/TitleText

const USABLE_RICH_TEXT = preload("res://Scenes/Text/usable_rich_text.tscn")


#TEMP DEBUG ETC
func _ready() -> void:
	load_puzzle(current_puzzle)

#loads a puzzle
func load_puzzle(new_puzzle : Puzzle):
	current_puzzle = new_puzzle
	
	#load the body words
	load_body_words()
	
	#loads the title
	load_title()

func load_body_words():
	#reset words
	current_body.clear()
	
	#get word list
	var current_body = current_puzzle.starting_text.split(" ")
	
	#error check
	if current_body.size() == 0:
		print("ERROR: Body of text failed to load :(")
		return
	
	
	#load in word objects
	for word in current_body:
		var word_object = USABLE_RICH_TEXT.instantiate()
		#add to array
		current_body_objects.append(word)
		#place in scene
		body_word_container.add_child(word_object)
		#update text
		word_object.label_text = word
		#connect clicked signal
		word_object.word_pressed.connect(word_clicked)

func load_title():
	title_text.label_text = current_puzzle.title

func word_clicked(word : UsableRichText):
	print("Clicked: %s" % word.label_text)
