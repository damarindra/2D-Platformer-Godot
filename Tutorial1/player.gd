extends KinematicBody2D
# defines GRAVITY
# `export` makes your variable editable in the editor
# `var GRAVITY = 10` defines a variable named GRAVITY and assign it 10
export var GRAVITY = 10
# set the maximum falling speed per frame
export var MAX_FALLING_SPEED = 15
# MOVE_SPEED
export var MOVE_SPEED = 5
# store the player velocity
var velocity = Vector2()
# Called when the node is "ready", that means called when the game started.
# Use this function for initialize
func _ready():
	# makes `_fixed_process(delta)` running
	set_fixed_process(true)
# Called during the fixed processing step of the main loop.
# Fixed processing means that the frame rate is synced to the physics,
# i.e. the delta variable should be constant.
# only active when set_fixed_process(true) is called
func _fixed_process(delta):
	# make a Vector2 variable movement and add gravity into y axis
	var movement = Vector2(0, velocity.y + GRAVITY * delta)
	#input
	var right_input = Input.is_action_pressed("right")
	var left_input = Input.is_action_pressed("left")
	#Apply the horizontal movement
	if right_input:
		movement.x = MOVE_SPEED
	elif left_input:
		movement.x = -MOVE_SPEED
	# set the velocity = movement
	velocity = movement
	# set the maximum falling speed
	if velocity.y > MAX_FALLING_SPEED:
		velocity.y = MAX_FALLING_SPEED
	# apply the movement by calling move(velocity) and store the remaining movement
	var remaining_movement = move(velocity)
	# collision handling
	if is_colliding():
		var normal = get_collision_normal()
		remaining_movement = normal.slide(remaining_movement)
		velocity = normal.slide(remaining_movement)
		move(remaining_movement)