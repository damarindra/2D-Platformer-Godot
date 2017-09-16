extends Camera2D
export var target = "../Player"
export var forward_offset = 60
export var max_y_offset = 5
export var x_smoothing = .05
export var y_smoothing = .1
onready var target_node = get_node(target)
onready var bounds = get_node("../Bounds")

func _ready():
	OS.set_window_size(OS.get_window_size() * 4)
	var pos = target_node.get_pos()
	pos = Vector2(round(pos.x), round(pos.y))
	set_pos(pos)
	set_fixed_process(true)
func _fixed_process(delta):
	var target_pos = target_node.get_center_pos() + Vector2(1, 0) * target_node.facing_dir * forward_offset
	target_pos.x = lerp(get_pos().x, target_pos.x, x_smoothing)
	#gap it when the next position is out of bound
	if abs(target_pos.x - target_node.get_center_pos().x) > forward_offset:
		target_pos.x = target_node.get_center_pos().x + target_node.facing_dir * forward_offset * -1
	target_pos.y = lerp(get_pos().y, target_pos.y + max_y_offset, y_smoothing)
	if abs(target_pos.y - target_node.get_center_pos().y) > max_y_offset:
		target_pos.y =  target_node.get_center_pos().y + (sign(target_pos.y - target_node.get_center_pos().y) * max_y_offset)
	
	if (target_pos.x + get_offset().x - get_viewport_rect().size.x/2 < bounds.get_left()):
		target_pos.x = bounds.get_left() - get_offset().x + get_viewport_rect().size.x/2 
	elif (target_pos.x + get_offset().x + get_viewport_rect().size.x/2 > bounds.get_right()):
		target_pos.x = bounds.get_right() - get_offset().x - get_viewport_rect().size.x/2
	
	if (target_pos.y + get_offset().y - get_viewport_rect().size.y/2 < bounds.get_top()):
		target_pos.y = bounds.get_top() - get_offset().y + get_viewport_rect().size.y/2
	elif (target_pos.y + get_offset().y + get_viewport_rect().size.y/2 > bounds.get_bottom()):
		target_pos.y = bounds.get_bottom() - get_offset().y - get_viewport_rect().size.y/2
	
	set_pos(Vector2(round(target_pos.x), round(target_pos.y)))