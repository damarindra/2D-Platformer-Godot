extends Node2D

export var left_stop = true
export var right_stop = true
export var top_stop = true

func get_left():
	return get_node("Left").get_global_pos().x

func get_right():
	return get_node("Right").get_global_pos().x

func get_top():
	return get_node("Top").get_global_pos().y

func get_bottom():
	return get_node("Bottom").get_global_pos().y