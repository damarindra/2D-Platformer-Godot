extends Node

# defines GRAVITY
# `export` makes your variable editable in the editor
# `var GRAVITY = 10` defines a variable named GRAVITY and assign it 10
export var GRAVITY = 10.0
# set the maximum falling speed per frame
export var MAX_FALLING_SPEED = 15.0
# MOVE_SPEED
export var MOVE_SPEED = 5.0
export var MOVE_SPEED_TIME_NEEDED = .15
var move_step = 0.0
export var DECELERATION_TIME_NEEDED = .15
var dec_step = 0.0
# jump power
export var MAX_JUMP_POWER = 5.0
export var MIN_JUMP_POWER = 2.0
export var MAX_AIR_JUMP_POWER = 3.0
export var MIN_AIR_JUMP_POWER = 1.0
export var MAX_AIR_JUMP_COUNT = 2.0
# store the player velocity
var velocity = Vector2()
# store status of jump input
var is_jump_pressed = false
# store status if last frame grounded
var last_frame_grounded = false
#store jump counter
var air_jump_count = 0
var facing_dir = 1
onready var bounds = get_node("/root").get_child(0).get_node("Bounds")
onready var kb = get_node("..")
func _ready():
	move_step = MOVE_SPEED / MOVE_SPEED_TIME_NEEDED
	dec_step = MOVE_SPEED / DECELERATION_TIME_NEEDED
func move(right_input, left_input, jump_input, delta):
	if !verify():
		print("Parent is invalid! Parent must be KinematicBody2D")
		return 0
	# make a Vector2 variable movement and add gravity into y axis
	var movement = Vector2(velocity.x, velocity.y + GRAVITY * delta)
	#Apply the horizontal movement
	if right_input:
		movement.x += move_step * delta
	elif left_input:
		movement.x -= move_step * delta
	elif movement.x != 0:
		#get the direction of movement
		var _dir = sign(movement.x)
		#calculate deceleration amount and direction
		var _dec = _dir * -1 * dec_step * delta
		# apply to movement
		movement.x += _dec
		# stop it when reached 0
		if _dir == 1 && movement.x < 0:
			movement.x = 0
		elif _dir == -1 && movement.x > 0:
			movement.x = 0
	#if the movement.x more that max_speed, gap it
	if abs(movement.x) > MOVE_SPEED:
		movement.x = sign(movement.x) * MOVE_SPEED
	#Apply jumping
	if jump_input:
		if !is_jump_pressed && last_frame_grounded:
			movement.y = -MAX_JUMP_POWER
		elif !is_jump_pressed && !last_frame_grounded && air_jump_count < MAX_AIR_JUMP_COUNT:
			movement.y = -MAX_AIR_JUMP_POWER
			air_jump_count += 1
		is_jump_pressed = true
	elif !jump_input && is_jump_pressed:
		if air_jump_count != 0 && movement.y < -MIN_AIR_JUMP_POWER:
			movement.y = -MIN_AIR_JUMP_POWER
		elif movement.y < -MIN_JUMP_POWER:
			movement.y = -MIN_JUMP_POWER
		is_jump_pressed = false
	# set the velocity = movement
	velocity = movement

	if get_center_pos().x - kb.get_node("CollisionShape2D").get_shape().get_extents().x + velocity.x < bounds.get_left() and bounds.left_stop:
		velocity.x = bounds.get_left()-get_center_pos().x + kb.get_node("CollisionShape2D").get_shape().get_extents().x
	elif get_center_pos().x + kb.get_node("CollisionShape2D").get_shape().get_extents().x + velocity.x > bounds.get_right() and bounds.right_stop:
		velocity.x = bounds.get_right()-get_center_pos().x - kb.get_node("CollisionShape2D").get_shape().get_extents().x
	if get_center_pos().y - kb.get_node("CollisionShape2D").get_shape().get_extents().y + velocity.y < bounds.get_top() and bounds.top_stop:
		velocity.y = bounds.get_top() - get_center_pos().y+ kb.get_node("CollisionShape2D").get_shape().get_extents().x
	# apply the movement by calling move(velocity) and store the remaining movement
	return kb.move(velocity)

func collision_handling(remaining_movement):
	# collision handling
	if kb.is_colliding():
		var normal = kb.get_collision_normal()
		remaining_movement = normal.slide(remaining_movement)
		velocity = normal.slide(velocity)
		kb.move(remaining_movement)
		# if normal is floor, then set as grounded
		if normal == Vector2(0, -1):
			last_frame_grounded = true
			air_jump_count = 0
	elif last_frame_grounded:
		last_frame_grounded = false
	if velocity.x != 0:
		facing_dir = sign(velocity.x)

func verify():
	if kb.is_type("KinematicBody2D"):
		return true 
	else:
		print("Failed to verify")
		return false

func get_center_pos():
	if verify():
		return kb.get_pos() + kb.get_node("CollisionShape2D").get_pos()
	return Vector2()