extends CharacterBody3D

class_name Player

@export_group("movement")
@export var max_speed : float
@export var acc_speed : float
@export var gravity : float

@export_group("reference")
@export var dialogue_system : Node

@onready var interact_area : Area3D = $InteractArea

var move : Vector3 = Vector3.ZERO
var y_vel : float = 0.0
var input_enabled : bool = true


func _process(delta: float) -> void:
	move_player(delta)
	check_for_interaction()


func move_player(delta: float) -> void:
	if not input_enabled:
		return
	
	# get input vector
	var input = Input.get_vector("left", "right", "up", "down")
	var input3d = Vector3(input.x, 0, input.y).normalized();
	
	# acceleration / deceleration
	move = move.move_toward(input3d * max_speed, acc_speed * delta)
	
	# increase y velocity by gravity if body is in the air
	if not is_on_floor():
		y_vel += gravity * delta
	else:
		y_vel = 0.0
	
	# set velocity
	velocity = move + Vector3.DOWN * y_vel
	
	# move player
	move_and_slide()


func check_for_interaction():
	if not Input.is_action_just_pressed("interact") or not input_enabled:
		return
	
	var area = interact_area.get_overlapping_areas()[0]
	
	if area == null:
		return
	
	input_enabled = false
	dialogue_system.trigger(area.get_parent().text)
