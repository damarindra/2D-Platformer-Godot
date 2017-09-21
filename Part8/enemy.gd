extends "res://Part8/character_controller.gd"

export var initial_movement = 1
var move_dir = 0
export var damage_given = 1

var last_anim = ""
onready var anim = get_node("anim")
onready var hole_raycaster = RayCast2D.new()
export var RAY_LENGTH = 5

func _ready():
	move_dir = sign(initial_movement)
	
	add_child(hole_raycaster)
	hole_raycaster.add_exception(self)
	hole_raycaster.set_pos(get_node("CollisionShape2D").get_pos() + Vector2(move_dir, 0) * get_node("CollisionShape2D").get_shape().get_extents().x)
	hole_raycaster.set_cast_to(Vector2(0, get_node("CollisionShape2D").get_shape().get_extents().y + RAY_LENGTH))
	hole_raycaster.set_enabled(true)
	
	set_fixed_process(true)

func _fixed_process(delta):
	var remaining_movement = calculate_movement(move_dir == 1, move_dir == -1, false, delta)
	if is_colliding():
		if get_collision_normal() == Vector2(move_dir * -1, 0):
			move_dir *= -1
	
	#if no collider detected
	#or if reach at the levelbound.right
	#or if reach at the levelbound.left
	if (!hole_raycaster.is_colliding() 
	or (round(get_center_pos().x + get_node("CollisionShape2D").get_shape().get_extents().x) >= round(get_node("../Bounds").get_right()) and move_dir == 1) 
	or (round(get_center_pos().x - get_node("CollisionShape2D").get_shape().get_extents().x) <= round(get_node("../Bounds").get_left())  and move_dir == -1)):
		move_dir *= -1
	
	collision_handling(remaining_movement)
	
	if (facing_dir == 1) != sprite.is_flipped_h():
		sprite.set_flip_h(facing_dir == 1)
	
	hole_raycaster.set_pos(get_node("CollisionShape2D").get_pos() + Vector2(move_dir, 0) * get_node("CollisionShape2D").get_shape().get_extents().x)
	
	var new_anim = "Idle"
	if last_frame_grounded:
		if velocity.x != 0:
			new_anim = "Move"
	#apply animation
	if new_anim != last_anim:
		anim.play(new_anim)
		last_anim = new_anim
			