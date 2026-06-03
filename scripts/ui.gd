extends CanvasLayer

@onready var level_label = $LevelLabel
@onready var goal_label = $GoalLabel
@onready var score_label = $ScoreLabel
@onready var moves_label = $MoveLabel
@onready var combo_label = $ComboLabel
@onready var result_label = $ResultLabel
@onready var restart_button = $RestartButton
@onready var next_level_button = $NextLevelButton
@onready var main_menu_button = $MainMenuButton

@onready var main_menu_panel = $MainMenuPanel
@onready var how_to_play_panel = $HowToPlayPanel
@onready var menu_start_button = $MainMenuPanel/MenuStartButton
@onready var menu_how_to_play_button = $MainMenuPanel/MenuHowToPlayButton
@onready var how_to_play_back_button = $HowToPlayPanel/HowToPlayBackButton

var combo_tween: Tween

signal restart_pressed
signal next_level_pressed
signal start_game_pressed
signal show_how_to_play_pressed
signal back_to_menu_pressed
signal main_menu_pressed

func _ready():
	restart_button.pressed.connect(func():
		restart_pressed.emit()
	)
	next_level_button.pressed.connect(func():
		next_level_pressed.emit()
	)
	menu_start_button.pressed.connect(func():
		start_game_pressed.emit()
	)
	menu_how_to_play_button.pressed.connect(func():
		show_how_to_play_pressed.emit()
	)
	how_to_play_back_button.pressed.connect(func():
		back_to_menu_pressed.emit()
	)
	main_menu_button.pressed.connect(func():
		main_menu_pressed.emit()
	)

func show_menu():
	main_menu_panel.visible = true
	how_to_play_panel.visible = false

func show_how_to_play():
	main_menu_panel.visible = false
	how_to_play_panel.visible = true

func show_gameplay():
	main_menu_panel.visible = false
	how_to_play_panel.visible = false

func update_score(new_score: int):
	score_label.text = "Score: " + str(new_score)

func update_moves(count: int):
	moves_label.text = "Moves: " + str(count)

func update_level(level: int):
	level_label.text = "Level: " + str(level + 1)

func update_goal(goal: int):
	goal_label.text = "Goal: " + str(goal)

func show_win(has_next: bool):
	if has_next:
		result_label.text = "Level Complete!"
	else:
		result_label.text = "Game Complete!"
	result_label.modulate = Color(0.3, 1.0, 0.3)
	result_label.visible = true
	next_level_button.visible = has_next
	next_level_button.disabled = false
	main_menu_button.visible = not has_next

func show_lose():
	result_label.text = "Try Again!"
	result_label.modulate = Color(1.0, 0.3, 0.3)
	result_label.visible = true

func clear_result():
	result_label.text = ""
	result_label.visible = false
	next_level_button.visible = false
	next_level_button.disabled = false
	main_menu_button.visible = false

func clear_combo():
	if combo_tween:
		combo_tween.kill()
	combo_label.text = ""
	combo_label.modulate.a = 0.0

func show_combo(multiplier: int):
	if combo_tween:
		combo_tween.kill()
	
	combo_label.text = "Combo x%d!" % multiplier
	combo_label.modulate = Color.WHITE
	
	combo_tween = create_tween()
	combo_tween.tween_interval(0.3)
	combo_tween.tween_property(combo_label, "modulate:a", 0.0, 0.8)
	combo_tween.tween_callback(func():
		combo_label.text = ""
	)
