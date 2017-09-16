extends KinematicBody2D
# defines GRAVITY
# `export` makes your variable editable in the editor
# `var GRAVITY = 10` defines a variable named GRAVITY and assign it 10
export var GRAVITY = 10
# set the maximum falling speed per frame
export var MAX_FALLING_SPEED = 15
# MOVE_SPEED
export var MOVE_SPEED = 5
export var MOVE_SPEED_TIME_NEEDED = .15
var move_step = 0
export var DECELERATION_TIME_NEEDED = .15
var dec_step = 0
# jump power
export var MAX_JUMP_POWER = 5
export var MIN_JUMP_POWER = 2
export var MAX_AIR_JUMP_POWER = 3
export var MIN_AIR_JUMP_POWER = 1
export var MAX_AIR_JUMP_COUNT = 2
# store the player velocity
var velocity = Vector2()
# store status of jump input
var is_jump_pressed = false
# store status if last frame grounded
var last_frame_grounded = false
#store jump counter
var air_jump_count = 0
var facing_dir = 1
var last_anim = ""
onready var anim = get_node("anim")
onready var sprite = get_node("Sprite")
onready var bounds = get_node("../Bounds")
# Called when the node is "ready", that means called when the game started.
# Use this function for initialize
func _ready():
	move_step = MOVE_SPEED / MOVE_SPEED_TIME_NEEDED
	dec_step = MOVE_SPEED / DECELERATION_TIME_NEEDED
	last_anim = anim.get_current_animation()
	# makes `_fixed_process(delta)` running
	set_fixed_process(true)
	
# Called during the fixed processing step of the main loop.
# Fixed processing means that the frame rate is synced to the physics,
# i.e. the delta variable should be constant.
# only active when set_fixed_process(true) is called
func _fixed_process(delta):
	# make a Vector2 variable movement and add gravity into y axis
	var movement = Vector2(velocity.x, velocity.y + GRAVITY * delta)
	#input
	var right_input = Input.is_action_pressed("right")
	var left_input = Input.is_action_pressed("left")
	var jump_input = Input.is_action_pressed("jump")
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
	
	if get_center_pos().x + velocity.x < bounds.get_left() and bounds.left_stop:
		velocity.x = bounds.get_left()-get_center_pos().x
	elif get_center_pos().x + velocity.x > bounds.get_right() and bounds.right_stop:
		velocity.x = bounds.get_right()-get_center_pos().x
	if get_center_pos().y + velocity.y < bounds.get_top() and bounds.top_stop:
		velocity.y = bounds.get_top() - get_center_pos().y
	
	# apply the movement by calling move(velocity) and store the remaining movement
	var remaining_movement = move(velocity)
	# collision handling
	if is_colliding():
		var normal = get_collision_normal()
		
		remaining_movement = normal.slide(remaining_movement)
		velocity = normal.slide(velocity)
		move(remaining_movement)
		# if normal is floor, then set as grounded
		if normal == Vector2(0, -1):
			last_frame_grounded = true
			air_jump_count = 0
	elif last_frame_grounded:
		last_frame_grounded = false
	
	if velocity.x != 0:
		facing_dir = sign(velocity.x)
	
	sprite.set_flip_h(facing_dir != 1)
	
	var new_anim = "Idle"
	if last_frame_grounded:
		if velocity.x != 0:
			new_anim = "Move"
	else:
		new_anim = "Jump"
	
	#apply animation
	if new_anim != last_anim:
		anim.play(new_anim)
		last_anim = new_anim

func get_center_pos():
	return get_pos() + get_node("CollisionShape2D").get_pos()