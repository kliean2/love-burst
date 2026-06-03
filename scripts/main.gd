extends Node2D

@onready var board = $Board
@onready var ui = $UI

func _ready():
	board.score_changed.connect(_on_score_changed)
	board.moves_changed.connect(_on_moves_changed)
	board.combo_triggered.connect(_on_combo_triggered)
	ui.restart_pressed.connect(_on_restart_pressed)
	ui.update_score(0)
	ui.update_moves(0)

func _on_score_changed(new_score: int):
	ui.update_score(new_score)

func _on_moves_changed(count: int):
	ui.update_moves(count)

func _on_combo_triggered(multiplier: int):
	ui.show_combo(multiplier)

func _on_restart_pressed():
	board.restart()
	ui.clear_combo()
