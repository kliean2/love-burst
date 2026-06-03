extends Node2D

@onready var board = $Board
@onready var ui = $UI

func _ready():
	board.score_changed.connect(_on_score_changed)
	board.combo_triggered.connect(_on_combo_triggered)
	ui.update_score(0)

func _on_score_changed(new_score: int):
	ui.update_score(new_score)

func _on_combo_triggered(multiplier: int):
	ui.show_combo(multiplier)
