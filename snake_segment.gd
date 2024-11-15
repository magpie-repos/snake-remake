class_name SnakeSegment
extends Sprite2D

var decay_time = 0;
var colliding_with_self = false
var collected_pellet = false

func _ready():
	add_to_group("snake")

func constructor(decay_time_val, spawn_position):
	decay_time = decay_time_val
	position = spawn_position
	
func update_cycle():
	##Delete segment if decay timer has run out
	if decay_time <= 0:
		queue_free()
	else:
		decay_time -= 1
		
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("snake"):
		colliding_with_self = true
	
	if area.get_parent().is_in_group("pellets"):
		collected_pellet = true
		area.get_parent().queue_free()
		
		
		
		
		
		
