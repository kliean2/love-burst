extends Node2D

@onready var board = $Board
@onready var ui = $UI

func _ready():
	board.score_changed.connect(_on_score_changed)
	ui.update_score(0)

func _on_score_changed(new_score: int):
	ui.update_score(new_score)
