extends Node2D

@onready var board = $Board
@onready var ui = $UI

func _ready():
	board.score_changed.connect(_on_score_changed)
	board.moves_left_changed.connect(_on_moves_left_changed)
	board.combo_triggered.connect(_on_combo_triggered)
	board.level_won.connect(_on_level_won)
	board.level_lost.connect(_on_level_lost)
	ui.restart_pressed.connect(_on_restart_pressed)
	ui.next_level_pressed.connect(_on_next_level_pressed)
	ui.update_score(0)
	ui.update_moves(board.moves_left)
	ui.update_level(board.current_level)
	ui.update_goal(board.goal_score)

func _on_score_changed(new_score: int):
	ui.update_score(new_score)

func _on_moves_left_changed(count: int):
	ui.update_moves(count)

func _on_combo_triggered(multiplier: int):
	ui.show_combo(multiplier)

func _on_level_won():
	ui.show_win(board.has_next_level())

func _on_level_lost():
	ui.show_lose()

func _on_next_level_pressed():
	board.next_level()
	ui.clear_combo()
	ui.clear_result()
	ui.update_level(board.current_level)
	ui.update_goal(board.goal_score)

func _on_restart_pressed():
	board.restart()
	ui.clear_combo()
	ui.clear_result()
	ui.update_level(board.current_level)
	ui.update_goal(board.goal_score)
