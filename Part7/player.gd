extends "res://Part7/character_controller.gd"

var last_anim = ""
onready var anim = get_node("anim")
onready var sprite = get_node("Sprite")

# Called when the node is "ready", that means called when the game started.
# Use this function for initialize
func _ready():
	last_anim = anim.get_current_animation()
	# makes `_fixed_process(delta)` running
	set_fixed_process(true)

# Called during the fixed processing step of the main loop.
# Fixed processing means that the frame rate is synced to the physics,
# i.e. the delta variable should be constant.
# only active when set_fixed_process(true) is called

func _fixed_process(delta):
	#input
	var right_input = Input.is_action_pressed("right")
	var left_input = Input.is_action_pressed("left")
	var jump_input = Input.is_action_pressed("jump")

	var remaining_movement = calculate_movement(right_input, left_input, jump_input, delta)
	collision_handling(remaining_movement)

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