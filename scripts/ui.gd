extends CanvasLayer

@onready var score_label = $ScoreLabel

func update_score(new_score: int):
	score_label.text = "Score: " + str(new_score)
