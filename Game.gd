extends Node2D

enum Directions { UP, DOWN, LEFT, RIGHT }
 
@onready var arrow_sprite = $ArrowSprite
@onready var correct_score_label = $CorrectScoreLabel
@onready var incorrect_score_label = $IncorrectScoreLabel
@onready var reaction_time_label = $ReactionTimeLabel
@onready var previous_time_label = $PreviousTimeLabel
@onready var start_message = $StartMessage
var current_direction = Directions.UP
var is_green_arrow = true
var start_time = 0.0
var is_timing = false
var game_started = false

var log_entries = []
var log_file_name = ""

var green_arrow_textures = {
	Directions.UP: preload("res://assets/arrow_up_green.png"),
	Directions.DOWN: preload("res://assets/arrow_down_green.png"),
	Directions.RIGHT: preload("res://assets/arrow_right_green.png"),
	Directions.LEFT: preload("res://assets/arrow_left_green.png")
}

var red_arrow_textures = {
	Directions.UP: preload("res://assets/arrow_up_red.png"),
	Directions.DOWN: preload("res://assets/arrow_down_red.png"),
	Directions.RIGHT: preload("res://assets/arrow_right_red.png"),
	Directions.LEFT: preload("res://assets/arrow_left_red.png")
}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	start_message.visible = true
	arrow_sprite.visible = false
	update_labels()
	setup_log_file()

func generate_new_direction():
	current_direction = randi() % 4
	is_green_arrow = randi() % 2 == 0
	
	if is_green_arrow:
		arrow_sprite.texture = green_arrow_textures[current_direction]
	else:
		arrow_sprite.texture = red_arrow_textures[current_direction]
		
	start_time = Time.get_ticks_msec()
	is_timing = true
	reaction_time_label.text = "Time: 0 ms"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not game_started:
		if Input.is_action_just_pressed("ui_accept"):
			game_started = true
			start_message.visible = false
			arrow_sprite.visible = true
			generate_new_direction()
		return
	
	if is_timing:
		var current_time = Time.get_ticks_msec()
		var elapsed_time = current_time - start_time
		reaction_time_label.text = "Time: " + str(elapsed_time) + " ms"
		
	var input_pressed = false
	
	if is_green_arrow:
		if Input.is_action_just_pressed("ui_up") and current_direction == Directions.UP:
			add_correct_point()
			log_entry("up", "green", "correct")
			input_pressed = true
		elif Input.is_action_just_pressed("ui_down") and current_direction == Directions.DOWN:
			add_correct_point()
			log_entry("down", "green", "correct")
			input_pressed = true
		elif Input.is_action_just_pressed("ui_left") and current_direction == Directions.LEFT:
			add_correct_point()
			log_entry("left", "green", "correct")
			input_pressed = true
		elif Input.is_action_just_pressed("ui_right") and current_direction == Directions.RIGHT:
			add_correct_point()
			log_entry("right", "green", "correct")
			input_pressed = true
		else:
			input_pressed = check_incorrect_input()
	else:
		if Input.is_action_just_pressed("ui_up") and current_direction == Directions.DOWN:
			add_correct_point()
			log_entry("up", "red", "correct")
			input_pressed = true
		elif Input.is_action_just_pressed("ui_down") and current_direction == Directions.UP:
			add_correct_point()
			log_entry("down", "red", "correct")
			input_pressed = true
		elif Input.is_action_just_pressed("ui_left") and current_direction == Directions.RIGHT:
			add_correct_point()
			log_entry("left", "red", "correct")
			input_pressed = true
		elif Input.is_action_just_pressed("ui_right") and current_direction == Directions.LEFT:
			add_correct_point()
			log_entry("right", "red", "correct")
			input_pressed = true
		else:
			input_pressed = check_incorrect_input()
		
	if input_pressed:
		generate_new_direction()
		
	if (Globals.correct_score + Globals.incorrect_score) == 50:
		save_log_to_file()
		get_tree().change_scene_to_file("res://EndScene.tscn")
		
	if Input.is_action_just_pressed("ui_cancel"):
		save_log_to_file()
		get_tree().quit()
		
func add_correct_point():
	Globals.correct_score += 1
	record_reaction_time()
	update_labels()

func add_incorrect_point():
	Globals.incorrect_score += 1
	record_reaction_time()
	update_labels()

func update_labels():
	correct_score_label.text = "Correct: " + str(Globals.correct_score)
	incorrect_score_label.text = "Incorrect: " + str(Globals.incorrect_score)

func check_incorrect_input() -> bool:
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		add_incorrect_point()
		log_entry(get_direction(), get_arrow_color(), "incorrect")
		return true
	return false

func record_reaction_time():
	var reaction_time = Time.get_ticks_msec() - start_time
	previous_time_label.text = "Reaction Time: " + str(reaction_time) + " ms"
	is_timing = false
	
func setup_log_file():
	var current_date = Time.get_datetime_string_from_system(false)
	current_date = current_date.replace(":", "").replace("-", "")
	log_file_name = Globals.username + "_" + current_date + ".txt"

func ensure_directory():
	var dir = DirAccess.open("user://")
	dir.make_dir("user_data")

func save_log_to_file():
	ensure_directory()
	var file_path = "user://user_data/" + log_file_name
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line("No.|direction|color|answer|time")
		for entry in log_entries:
			file.store_line(entry)
		file.close()
		print("Log saved to: " + log_file_name)
	else:
		print(FileAccess.get_open_error())
		print("Failed to save log file")
	
func log_entry(direction: String, color: String, answer: String):
	var reaction_time = Time.get_ticks_msec() - start_time
	var entry = str(log_entries.size() + 1) + "|" + direction + "|" + color + "|" + answer + "|" + str(reaction_time)
	log_entries.append(entry)

func get_direction() -> String:
	if current_direction == Directions.UP:
		return "up"
	if current_direction == Directions.DOWN:
		return "down"
	if current_direction == Directions.LEFT:
		return "left"
	if current_direction == Directions.RIGHT:
		return "right"
	return "unknown"

func get_arrow_color() -> String:
	return "green" if is_green_arrow else "red"
	
	
	
	
