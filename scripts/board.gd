extends Node2D

const COLS = 8
const ROWS = 8
const TILE_SIZE = 52
const BOARD_OFFSET_X = 32
const BOARD_OFFSET_Y = 80

var grid = []
var selected_tile = null
var is_animating = false
var score = 0

signal score_changed(new_score)

func _ready():
	for row in range(ROWS):
		grid.append([])
		for col in range(COLS):
			var tile = preload("res://scenes/Tile.tscn").instantiate()
			tile.tile_type = _safe_random_type(col, row)
			tile.grid_pos = Vector2i(col, row)
			tile.position = Vector2(
				BOARD_OFFSET_X + col * TILE_SIZE,
				BOARD_OFFSET_Y + row * TILE_SIZE
			)
			tile.update_appearance()
			tile.clicked.connect(_on_tile_clicked)
			add_child(tile)
			grid[row].append(tile)
	
	_verify_initial_board()
	_ensure_playable_board()

func _safe_random_type(col, row) -> int:
	var types = [0, 1, 2, 3, 4]
	types.shuffle()
	for t in types:
		if col >= 2:
			if grid[row][col - 1].tile_type == t and grid[row][col - 2].tile_type == t:
				continue
		if row >= 2:
			if grid[row - 1][col].tile_type == t and grid[row - 2][col].tile_type == t:
				continue
		return t
	return types[0]

func _verify_initial_board():
	var matches = find_matches()
	if matches.is_empty():
		print("Initial board has no matches")
	else:
		print("WARNING: Initial board has ", matches.size(), " matches:")
		for tile in matches:
			print("  ", tile.grid_pos)

func _on_tile_clicked(tile):
	if is_animating:
		return
	
	if selected_tile == null:
		selected_tile = tile
		tile.select()
	elif selected_tile == tile:
		tile.deselect()
		selected_tile = null
	elif _are_adjacent(selected_tile, tile):
		selected_tile.deselect()
		_swap_tiles(selected_tile, tile)
	else:
		selected_tile.deselect()
		selected_tile = tile
		tile.select()

func find_matches() -> Array:
	var matched = {}
	var result = []
	
	for row in range(ROWS):
		var col = 0
		while col < COLS:
			if grid[row][col] == null:
				col += 1
				continue
			var t = grid[row][col].tile_type
			var end = col + 1
			while end < COLS and grid[row][end] != null and grid[row][end].tile_type == t:
				end += 1
			if end - col >= 3:
				for c in range(col, end):
					var pos = Vector2i(c, row)
					if not matched.has(pos):
						matched[pos] = true
						result.append(grid[row][c])
			col = end
	
	for col in range(COLS):
		var row = 0
		while row < ROWS:
			if grid[row][col] == null:
				row += 1
				continue
			var t = grid[row][col].tile_type
			var end = row + 1
			while end < ROWS and grid[end][col] != null and grid[end][col].tile_type == t:
				end += 1
			if end - row >= 3:
				for r in range(row, end):
					var pos = Vector2i(col, r)
					if not matched.has(pos):
						matched[pos] = true
						result.append(grid[r][col])
			row = end
	
	return result

func _check_matches_after_swap(tile_a, tile_b):
	var matches = find_matches()
	
	var involves_swapped = false
	for tile in matches:
		if tile == tile_a or tile == tile_b:
			involves_swapped = true
			break
	
	if involves_swapped:
		print("Valid swap")
		print("Match found! ", matches.size(), " tiles:")
		for tile in matches:
			print("  ", tile.grid_pos)
			tile.debug_tint(Color.RED)
		
		is_animating = true
		get_tree().create_timer(0.3).timeout.connect(
			_clear_matched_tiles.bind(matches)
		)
	else:
		print("Invalid swap, swapping back")
		_swap_back(tile_a, tile_b)

func _swap_back(tile_a, tile_b):
	is_animating = true
	var pos_a = tile_a.position
	var pos_b = tile_b.position
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(tile_a, "position", pos_b, 0.15)
	tween.tween_property(tile_b, "position", pos_a, 0.15)
	tween.set_parallel(false)
	tween.tween_callback(_finish_swap_back.bind(tile_a, tile_b))

func _finish_swap_back(tile_a, tile_b):
	var a_col = tile_a.grid_pos.x
	var a_row = tile_a.grid_pos.y
	var b_col = tile_b.grid_pos.x
	var b_row = tile_b.grid_pos.y
	
	grid[a_row][a_col] = tile_b
	grid[b_row][b_col] = tile_a
	
	tile_a.grid_pos = Vector2i(b_col, b_row)
	tile_b.grid_pos = Vector2i(a_col, a_row)
	
	is_animating = false

func _clear_matched_tiles(matches):
	score += matches.size() * 10
	score_changed.emit(score)
	
	for tile in matches:
		var pos = tile.grid_pos
		grid[pos.y][pos.x] = null
	
	var tween = create_tween()
	tween.set_parallel(true)
	for tile in matches:
		tween.tween_property(tile, "modulate:a", 0.0, 0.2)
	tween.set_parallel(false)
	tween.tween_callback(func():
		for tile in matches:
			tile.queue_free()
		_drop_and_refill()
	)

func _safe_refill_type(col, row) -> int:
	var types = [0, 1, 2, 3, 4]
	types.shuffle()
	for t in types:
		if not _refill_type_creates_match(t, col, row):
			return t
	return types[0]

func _refill_type_creates_match(t, col, row) -> bool:
	if col >= 2:
		var a = grid[row][col - 1]
		var b = grid[row][col - 2]
		if a != null and b != null and a.tile_type == t and b.tile_type == t:
			return true
	if col <= COLS - 3:
		var a = grid[row][col + 1]
		var b = grid[row][col + 2]
		if a != null and b != null and a.tile_type == t and b.tile_type == t:
			return true
	if col >= 1 and col <= COLS - 2:
		var a = grid[row][col - 1]
		var b = grid[row][col + 1]
		if a != null and b != null and a.tile_type == t and b.tile_type == t:
			return true
	if row >= 2:
		var a = grid[row - 1][col]
		var b = grid[row - 2][col]
		if a != null and b != null and a.tile_type == t and b.tile_type == t:
			return true
	if row <= ROWS - 3:
		var a = grid[row + 1][col]
		var b = grid[row + 2][col]
		if a != null and b != null and a.tile_type == t and b.tile_type == t:
			return true
	if row >= 1 and row <= ROWS - 2:
		var a = grid[row - 1][col]
		var b = grid[row + 1][col]
		if a != null and b != null and a.tile_type == t and b.tile_type == t:
			return true
	return false

func _drop_and_refill():
	var tween = create_tween()
	tween.set_parallel(true)
	
	for col in range(COLS):
		var tiles = []
		for row in range(ROWS - 1, -1, -1):
			if grid[row][col] != null:
				tiles.append(grid[row][col])
		
		var write_row = ROWS - 1
		for tile in tiles:
			if tile.grid_pos.y != write_row:
				grid[tile.grid_pos.y][col] = null
				grid[write_row][col] = tile
				tile.grid_pos = Vector2i(col, write_row)
				var target_y = BOARD_OFFSET_Y + write_row * TILE_SIZE
				tween.tween_property(tile, "position:y", target_y, 0.2)
			else:
				grid[write_row][col] = tile
			write_row -= 1
		
		while write_row >= 0:
			var tile = preload("res://scenes/Tile.tscn").instantiate()
			tile.tile_type = _safe_refill_type(col, write_row)
			tile.grid_pos = Vector2i(col, write_row)
			tile.update_appearance()
			tile.clicked.connect(_on_tile_clicked)
			
			var spawn_y = BOARD_OFFSET_Y - ROWS * TILE_SIZE
			tile.position = Vector2(BOARD_OFFSET_X + col * TILE_SIZE, spawn_y)
			add_child(tile)
			grid[write_row][col] = tile
			
			var target_y = BOARD_OFFSET_Y + write_row * TILE_SIZE
			tween.tween_property(tile, "position:y", target_y, 0.2)
			
			write_row -= 1
	
	tween.set_parallel(false)
	tween.tween_callback(func():
		var leftover = find_matches()
		if leftover.is_empty():
			print("Refill: clean board, no accidental matches")
		else:
			print("Refill: ", leftover.size(), " accidental matches found")
		_ensure_playable_board()
		is_animating = false
	)

func _ensure_playable_board():
	if _has_possible_moves():
		print("Board has possible moves")
		return
	
	print("No possible moves found, reshuffling board")
	
	for attempt in range(20):
		_regenerate_tile_types_safely()
		if _has_possible_moves():
			print("Board reshuffled with possible moves")
			return
	
	print("WARNING: Could not generate playable board after 20 attempts")

func _regenerate_tile_types_safely():
	for row in range(ROWS):
		for col in range(COLS):
			var tile = grid[row][col]
			tile.tile_type = _safe_refill_type(col, row)
			tile.update_appearance()

func _has_possible_moves() -> bool:
	for row in range(ROWS):
		for col in range(COLS):
			if col < COLS - 1:
				if _test_swap(Vector2i(col, row), Vector2i(col + 1, row)):
					return true
			if row < ROWS - 1:
				if _test_swap(Vector2i(col, row), Vector2i(col, row + 1)):
					return true
	return false

func _test_swap(pos_a: Vector2i, pos_b: Vector2i) -> bool:
	var tile_a = grid[pos_a.y][pos_a.x]
	var tile_b = grid[pos_b.y][pos_b.x]
	
	grid[pos_a.y][pos_a.x] = tile_b
	grid[pos_b.y][pos_b.x] = tile_a
	
	var matches = find_matches()
	var found = false
	for tile in matches:
		if tile == tile_a or tile == tile_b:
			found = true
			break
	
	grid[pos_a.y][pos_a.x] = tile_a
	grid[pos_b.y][pos_b.x] = tile_b
	
	return found

func _are_adjacent(a, b) -> bool:
	var diff = (a.grid_pos - b.grid_pos).abs()
	return (diff.x == 1 and diff.y == 0) or (diff.x == 0 and diff.y == 1)

func _swap_tiles(tile_a, tile_b):
	is_animating = true
	var pos_a = tile_a.position
	var pos_b = tile_b.position
	
	selected_tile = null
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(tile_a, "position", pos_b, 0.15)
	tween.tween_property(tile_b, "position", pos_a, 0.15)
	tween.set_parallel(false)
	tween.tween_callback(_finish_swap.bind(tile_a, tile_b))

func _finish_swap(tile_a, tile_b):
	var a_col = tile_a.grid_pos.x
	var a_row = tile_a.grid_pos.y
	var b_col = tile_b.grid_pos.x
	var b_row = tile_b.grid_pos.y
	
	grid[a_row][a_col] = tile_b
	grid[b_row][b_col] = tile_a
	
	tile_a.grid_pos = Vector2i(b_col, b_row)
	tile_b.grid_pos = Vector2i(a_col, a_row)
	
	is_animating = false
	_check_matches_after_swap(tile_a, tile_b)
