extends Control

@onready var name_input = $NameInput

func _on_submit_button_pressed() -> void:
	var username = name_input.text.strip_edges()
	if username == "":
		username = "Unkown"
	Globals.username = username
	get_tree().change_scene_to_file("res://Game.tscn")
