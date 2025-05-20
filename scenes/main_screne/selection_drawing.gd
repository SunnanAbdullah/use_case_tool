extends Node2D


var dragging : bool = false
var dragging_start : Vector2 = Vector2.ZERO
@export var is_mouse_busy : bool = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not is_mouse_busy:
		if event.pressed:
			dragging = true
			dragging_start = get_global_mouse_position()
		elif dragging :
			dragging = false
			queue_redraw()
	if event is InputEventMouseMotion and dragging and not is_mouse_busy:
		queue_redraw()



func _draw() -> void:
	if dragging and not is_mouse_busy:
		draw_rect(Rect2(dragging_start,get_global_mouse_position() - dragging_start),Color(Color.CRIMSON,0.25),5.0)
