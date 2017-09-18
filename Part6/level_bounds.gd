extends Node2D

export var left_stop = true
export var right_stop = true
export var top_stop = true

func get_left():
	return get_pos().x - get_scale().x * 32

func get_right():
	return get_pos().x + get_scale().x * 32

func get_top():
	return get_pos().y - get_scale().y * 32

func get_bottom():
	return get_pos().y + get_scale().y * 32