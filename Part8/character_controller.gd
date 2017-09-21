extends KinematicBody2D

#max health
export var MAX_HEALTH = 10
# current health
onready var current_health = MAX_HEALTH
# is currently invisible
var is_invisible = false
# total invisible time
export var INVISIBLE_TIME = 2.0
# flickering time step
const flicker_step = .1
# how far invisible has been done
var invisible_time_done = 0.0
# Timer for invisible timing
onready var timer = Timer.new()
# store if is bouncing
var is_bouncing = false
# bouncing direction, x will be automatically change depending on the damage factor and this character
export var bounce_dir = Vector2(3, -5)
# can't control character while taking damage
export(float, 0.0, 1.0, .01) var uncontrolable_invisible = 0.5
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
onready var sprite = get_node("Sprite")

func _ready():
	move_step = MOVE_SPEED / MOVE_SPEED_TIME_NEEDED
	dec_step = MOVE_SPEED / DECELERATION_TIME_NEEDED
	create_timer()

# Creating timer
func create_timer():
	timer = Timer.new()
	add_child(timer)
	timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
	timer.set_one_shot(false)
	timer.connect("timeout", self, "_flickering")

# Flickering, only caled when timeout fired
func _flickering():
	if invisible_time_done > INVISIBLE_TIME * uncontrolable_invisible and is_bouncing:
		is_bouncing = false
	
	if invisible_time_done == INVISIBLE_TIME:
		#set the sprite alpha = 1
		sprite.set_modulate(Color(1,1,1,1))
		# reset invisible_time_done
		invisible_time_done = 0
		# now character can take damage again
		is_invisible = false
		# stop the timer because flickering process done
		timer.stop()
	# When invisible_time_done + flicker_step is more than INVISIBLE_TIME
	elif invisible_time_done + flicker_step > INVISIBLE_TIME:
		# we need to calculate the time left, because time left is not equal than flicker time 
		var t = INVISIBLE_TIME - invisible_time_done
		# set this to catch the condition above (invisible_time_done == INVISIBLE_TIME)
		invisible_time_done = INVISIBLE_TIME
		# stop the timer since the flicker_step not the right value
		timer.stop()
		# re-start the flickering with proper time
		start_flickering(t)
		if sprite.get_modulate().a == 0:
			sprite.set_modulate(Color(1,1,1,1))
		else:
			sprite.set_modulate(Color(1,1,1,0))
	else:
		# this region is for flickering, nothing special
		if sprite.get_modulate().a == 0:
			sprite.set_modulate(Color(1,1,1,1))
		else:
			sprite.set_modulate(Color(1,1,1,0))
		invisible_time_done += flicker_step

func start_flickering(t):
	timer.set_wait_time(t)
	timer.start()

func calculate_movement(right_input, left_input, jump_input, delta):
	# make a Vector2 variable movement and add gravity into y axis
	var movement = Vector2(velocity.x, velocity.y + GRAVITY * delta)
	#Apply the horizontal movement
	if right_input and !is_bouncing:
		movement.x += move_step * delta
	elif left_input and !is_bouncing:
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
	
	if get_center_pos().x - get_node("CollisionShape2D").get_shape().get_extents().x + velocity.x < bounds.get_left() and bounds.left_stop:
		velocity.x = bounds.get_left()-get_center_pos().x + get_node("CollisionShape2D").get_shape().get_extents().x
	elif get_center_pos().x + get_node("CollisionShape2D").get_shape().get_extents().x + velocity.x > bounds.get_right() and bounds.right_stop:
		velocity.x = bounds.get_right()-get_center_pos().x - get_node("CollisionShape2D").get_shape().get_extents().x
	if get_center_pos().y - get_node("CollisionShape2D").get_shape().get_extents().y + velocity.y < bounds.get_top() and bounds.top_stop:
		velocity.y = bounds.get_top() - get_center_pos().y+ get_node("CollisionShape2D").get_shape().get_extents().x
	# apply the movement by calling move(velocity) and store the remaining movement
	return move(velocity)

func collision_handling(remaining_movement):
	if is_bouncing:
		return
		
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

func get_center_pos():
	return get_pos() + get_node("CollisionShape2D").get_pos()

func take_damage(value):
	if is_invisible:
		return
	
	current_health -= value
	if current_health < 0:
		current_health = 0
	else:
		is_bouncing = true
		var dir = sign(get_center_pos().x - get_collider().get_center_pos().x)
		velocity = bounce_dir * Vector2(dir, 1)
		is_invisible = true
		start_flickering(flicker_step)