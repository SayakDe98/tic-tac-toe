extends Node

@export var circle_scene: PackedScene
@export var cross_scene: PackedScene

var moves: int
var temp_marker
var player_panel_pos: Vector2i # 2 means 2d vector, i means int type values inside vector
var player: int
var grid_data: Array
var grid_pos: Vector2i
var board_size: int
var cell_size: int
var row_sum: int
var col_sum: int
var diag1_sum: int
var diag2_sum: int
var winner: int

func _ready():
	board_size = $Board.texture.get_width()
	# divide board size by 3 to get individual cell size
	cell_size = board_size / 3	
	# get coordinates of player panel on right side of window
	player_panel_pos = $PlayerPanel.get_position()
	new_game()
	
func _input(event): # _ is present because it is already present(godot function) and we are modifying the func
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# check if mouse is inside the game board
			if int(event.position.x) < board_size:
				grid_pos = Vector2i(event.position) / cell_size
				if grid_data[grid_pos.y][grid_pos.x] == 0: # don't allow reediting cells
					moves += 1
					grid_data[grid_pos.y][grid_pos.x] = player
					# place that player's marker
					create_marker(player, grid_pos * cell_size + Vector2i(cell_size / 2, cell_size / 2)) # offset by half a cell
					if check_winner() != 0 || moves == 9:
						show_game_over_menu()
					player *= -1
					# delete previous player panel marker
					temp_marker.queue_free()
					#update player panel marker
					create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)

func new_game():
	moves = 0
	winner = 0
	player = 1
	grid_data = [
		[0,0,0],
		[0,0,0],
		[0,0,0]
	]
	row_sum = 0 
	col_sum = 0
	diag1_sum = 0
	diag2_sum = 0
	# clear existing markers
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	# create a marker to show starting player's turn:
	create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
	$GameOverMenu.hide()
	get_tree().paused = false

func check_winner():
	for i in len(grid_data):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diag1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diag2_sum = grid_data[2][0] + grid_data[1][1] + grid_data[0][2]
		if row_sum == 3 or col_sum == 3 or diag1_sum == 3 or diag2_sum == 3:
			winner = 1
		elif row_sum == -3 or col_sum == -3 or diag1_sum == -3 or diag2_sum == -3:
			winner = -1
	
	return winner	
		
func create_marker(player, position, temp = false):
	if player == 1:
		var circle = circle_scene.instantiate()
		circle.position = position
		add_child(circle)
		if temp: temp_marker = circle
	else:
		var cross = cross_scene.instantiate()
		cross.position = position
		add_child(cross)
		if temp: temp_marker = cross

func show_game_over_menu():
	get_tree().paused = true # pause the game
	if winner == 1:
		$GameOverMenu.get_node("ResultLabel").text = "Player 1 Wins!!"
	elif winner == -1:
		$GameOverMenu.get_node("ResultLabel").text = "Player 2 Wins!!"
	elif moves == 9:
		$GameOverMenu.get_node("ResultLabel").text = "Game Tied!!"
	$GameOverMenu.show()
		
func _on_game_over_menu_restart() -> void:
	new_game()
