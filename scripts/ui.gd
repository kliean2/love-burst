extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var moves_label = $MoveLabel
@onready var combo_label = $ComboLabel
@onready var restart_button = $RestartButton

var combo_tween: Tween

signal restart_pressed

func _ready():
	restart_button.pressed.connect(func():
		restart_pressed.emit()
	)

func update_score(new_score: int):
	score_label.text = "Score: " + str(new_score)

func update_moves(count: int):
	moves_label.text = "Moves: " + str(count)

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
