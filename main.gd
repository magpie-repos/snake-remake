extends Node2D

var snake_length = 5
var snake_segment = preload("res://snake_segment.tscn")
var snake_segments = []
@onready var window_size = get_viewport().get_visible_rect().size
@onready var head_position = window_size / 2

var move_dir = Vector2.LEFT
var last_dir = Vector2.LEFT

var scale_factor = 8
var game_over = false

var pellet_value = 1
var pellet_scene = preload("res://pellet.tscn")
var speed_factor = 0.005

var new_game_flag = false

##UI Refs
@onready var ui_score = $UI/MarginContainer/Score
@onready var ui_game_over = $UI/MarginContainer/CenterContainer

func update_player_input():
	if Input.is_action_pressed("up") && last_dir != Vector2.DOWN:
		move_dir = Vector2.UP
	if Input.is_action_pressed("down") && last_dir != Vector2.UP:
		move_dir = Vector2.DOWN
	if Input.is_action_pressed("left") && last_dir != Vector2.RIGHT:
		move_dir = Vector2.LEFT
	if Input.is_action_pressed("right") && last_dir != Vector2.LEFT:
		move_dir = Vector2.RIGHT
		
	##Game State Management
	if Input.is_action_pressed("reset"):
		new_game()

func spawn_new_snake_segment():
	head_position += move_dir * scale_factor
	
	##Loop around game borders
	if head_position.x < 0:
		head_position.x += window_size.x
	if head_position.x > window_size.x:
		head_position.x = 0	
	if head_position.y < 0:
		head_position.y += window_size.y
	if head_position.y > window_size.y:
		head_position.y = 0	
	
	var new_segment = snake_segment.instantiate()
	new_segment.position = head_position
	new_segment.decay_time = snake_length
	add_child(new_segment)

func update_snake_segments():
	##Update decay timers for all segments
	snake_segments = get_tree().get_nodes_in_group("snake")
	for seg in snake_segments:
		if seg.decay_time <= 0:
			seg.queue_free()
			
		seg.decay_time -= 1
		
		##Update Backmove Protector
		last_dir = move_dir
		
		##Check for collision with self
		if seg.colliding_with_self:
			end_game()
			game_over = true
			
			$LooseSFX.play()
		
		if seg.collected_pellet:
			snake_length += 1
			#$GameCycle.wait_time -= speed_factor
			ui_score.text = str(snake_length - 5)
			spawn_pellet()
			seg.collected_pellet = false
			
			$PelletGetSFX.play()	
			
		
		
func end_game():
	#Delete snake segments
	snake_segments = get_tree().get_nodes_in_group("snake")
	ui_game_over.show()
	for seg in snake_segments:
		seg.queue_free()
	for pel in get_tree().get_nodes_in_group("pellets"):
		pel.queue_free()

	
	game_over = true
		
func new_game():
	snake_length = 5
	ui_game_over.hide()
	
	for seg in get_tree().get_nodes_in_group("snake"):
		seg.queue_free()
	for pel in get_tree().get_nodes_in_group("pellets"):
		pel.queue_free()
		
	move_dir = Vector2.LEFT
	last_dir = Vector2.LEFT
	
	head_position = window_size / 2
	new_game_flag = true
	game_over = false
	
	
		
func spawn_pellet():
	##Get random cords for spawn
	var pellet_spawn_loc = Vector2(
		snapped(randf_range(0, window_size.x / scale_factor - scale_factor), 1),
		snapped(randf_range(0, window_size.x / scale_factor - scale_factor), 1)
	)
	pellet_spawn_loc *= 8
	
	var new_pellet = pellet_scene.instantiate()
	new_pellet.position = pellet_spawn_loc
	add_child(new_pellet)

func _ready():
	ui_score.text = str(snake_length - 5)
	
	ui_game_over.hide()
	spawn_pellet()

func _process(delta: float) -> void:
	update_player_input()	
	
func _on_game_cycle_timeout() -> void:
	if not game_over:
		spawn_new_snake_segment()
		update_snake_segments()
	if new_game_flag:
		new_game_flag = false
		spawn_pellet()
	
		
		
	
