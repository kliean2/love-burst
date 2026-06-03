extends Area2D

signal clicked(tile: Node)

var tile_type: int = 0
var grid_pos: Vector2i
var base_scale: Vector2

func _ready():
	base_scale = $Sprite2D.scale

func _input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)

func update_appearance():
	var paths = [
		"res://assets/hearts/red.svg",
		"res://assets/hearts/pink.svg",
		"res://assets/hearts/orange.svg",
		"res://assets/hearts/green.svg",
		"res://assets/hearts/blue.svg"
	]
	$Sprite2D.texture = load(paths[tile_type])

func debug_tint(color: Color):
	$Sprite2D.modulate = color

func select():
	$Sprite2D.modulate = Color.YELLOW
	$Sprite2D.scale = base_scale * 1.15

func deselect():
	$Sprite2D.modulate = Color.WHITE
	$Sprite2D.scale = base_scale
