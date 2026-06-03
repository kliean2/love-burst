extends CanvasLayer

@onready var level_label = $LevelLabel
@onready var goal_label = $GoalLabel
@onready var score_label = $ScoreLabel
@onready var moves_label = $MoveLabel
@onready var combo_label = $ComboLabel
@onready var result_label = $ResultLabel
@onready var restart_button = $RestartButton
@onready var next_level_button = $NextLevelButton

var combo_tween: Tween

signal restart_pressed
signal next_level_pressed

func _ready():
	restart_button.pressed.connect(func():
		restart_pressed.emit()
	)
	next_level_button.pressed.connect(func():
		next_level_pressed.emit()
	)

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

func show_lose():
	result_label.text = "Try Again!"
	result_label.modulate = Color(1.0, 0.3, 0.3)
	result_label.visible = true

func clear_result():
	result_label.text = ""
	result_label.visible = false
	next_level_button.visible = false
	next_level_button.disabled = false

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
