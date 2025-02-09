extends Resource
class_name Puzzle

@export var name : String = "Name"
@export_multiline var title : String = "Title"
@export_multiline var starting_text : String #what the player starts with
@export_multiline var solved_text : Array[String]

@export_multiline var prompt : String #what the player is given to solve the pun

@export var hint_words : Array[String] #words that get colored when hint is selected
@export var hint_color : Color = Color.RED

@export var word_deletes : int = 0
@export var word_moves : int = 0
