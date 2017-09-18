extends Camera2D
export var target = "../Player"
export var forward_offset = 60
export var max_y_offset = 5
export var x_smoothing = .05
export var y_smoothing = .1
onready var target_node = get_node(target)
onready var bounds = get_node("../Bounds")

func _ready():
	OS.set_window_size(OS.get_window_size() * 5)
	set_limit(0, bounds.get_left())
	set_limit(1, bounds.get_top())
	set_limit(2, bounds.get_right())
	set_limit(3, bounds.get_bottom())
	
	var pos = target_node.get_pos()
	pos = Vector2(round(pos.x), round(pos.y))
	set_pos(pos)
	set_fixed_process(true)

func _fixed_process(delta):
	var target_pos = target_node.controller.get_center_pos() + Vector2(1, 0) * target_node.controller.facing_dir * forward_offset
	target_pos.x = lerp(get_pos().x, target_pos.x, x_smoothing)
	#gap it when the next position is out of bound
	if abs(target_pos.x - target_node.controller.get_center_pos().x) > forward_offset:
		target_pos.x = target_node.controller.get_center_pos().x + target_node.controller.facing_dir * forward_offset * -1
	target_pos.y = lerp(get_pos().y, target_pos.y + max_y_offset, y_smoothing)
	if abs(target_pos.y - target_node.controller.get_center_pos().y) > max_y_offset:
		target_pos.y =  target_node.controller.get_center_pos().y + (sign(target_pos.y - target_node.controller.get_center_pos().y) * max_y_offset)
		
	set_pos(Vector2(round(target_pos.x), round(target_pos.y)))