extends Node

@onready var correct_score_label = $CorrectScoreLabel
@onready var incorrect_score_label = $IncorrectScoreLabel
@onready var restart_button = $RestartButton
@onready var quit_button = $QuitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	correct_score_label.text = "Correct: " + str(Globals.correct_score)
	incorrect_score_label.text = "Incorrect: " + str(Globals.incorrect_score)
	
func _on_restart_button_pressed():
	Globals.correct_score = 0
	Globals.incorrect_score = 0
	get_tree().change_scene_to_file("res://Game.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
