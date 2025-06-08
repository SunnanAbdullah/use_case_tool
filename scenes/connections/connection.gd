class_name Connection extends Line2D

@export var connection_1 : Canvas_Item
@export var connection_2 : Canvas_Item
@export var main_node : Node2D
@export var is_selected : bool = true
@export var connection_type : String = ""


@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var option_button: OptionButton = $OptionButton
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2


const DOTTED_LINE_TEST_32_PX = preload('res://graphics/dotted_line_test_32px.png')
const DOTTED_LINE_TEST_32_PX_WHITE = preload('res://graphics/dotted_line_test_32px_white.png')

func _input(event: InputEvent) -> void:
	if event is InputEvent and event.is_action_pressed('delete') and is_selected :
		self.queue_free()
	if event is InputEventMouseButton and is_selected and event.button_index == MOUSE_BUTTON_RIGHT :
		is_selected = false




func _ready() -> void:
	if connection_type == "include" :
		option_button.selected = 1
		texture = DOTTED_LINE_TEST_32_PX_WHITE
		width = 32
	else :
		texture = null
		width = 10
		option_button.selected = 0
	if main_node :
		option_button.visible = false
		main_node.connect("send_reqtangle_coord",_on_send_rectangle_cord)
	#if connection_1 and connection_2 :
		#points[0] = connection_1.global_position
		#points[1] = connection_2.global_position
		#collision_shape_2d.shape.a = points[0]
		#collision_shape_2d.shape.b = points[1]
	if connection_1 and connection_2:
		var center1 = connection_1.global_position
		var center2 = connection_2.global_position
		var dir = center2 - center1
		var size1 = connection_1.collision_shape_2d.shape.get_rect().size
		var size2 = connection_2.collision_shape_2d.shape.get_rect().size
		var point1 = get_boundary_point(center1, size1, dir)
		var point2 = get_boundary_point(center2, size2, -dir)
		points[0] = point1
		points[1] = point2



func _process(_delta: float) -> void:
	#if connection_1 and connection_2 :
		#points[0] = connection_1.global_position
		#points[1] = connection_2.global_position
		#collision_shape_2d.shape.a = points[0]
		#collision_shape_2d.shape.b = points[1]
	if connection_1 and connection_2:
		var center1 = connection_1.global_position
		var center2 = connection_2.global_position
		var dir = center2 - center1
		var size1 = connection_1.collision_shape_2d.shape.get_rect().size
		var size2 = connection_2.collision_shape_2d.shape.get_rect().size
		var point1 = get_boundary_point(center1, size1, dir)
		var point2 = get_boundary_point(center2, size2, -dir)
		points[0] = point1
		points[1] = point2
		var direction = point2 - point1
		var angle = direction.angle()
		sprite_2d.position = point1
		sprite_2d_2.position = point2
		sprite_2d.rotation = angle + (PI/2)
		#print("angle"+ str(type_string(angle)))
		sprite_2d_2.rotation = angle + ((3 * PI)/2) 
		option_button.position = (point1 + point2)/2

	if is_selected :
		option_button.visible = true
		self.default_color = Color.RED
	else :
		option_button.visible = false
		self.default_color = Color.WHITE


func _on_area_2d_mouse_entered() -> void:
	print("enterrrrrrrrrrrrrrrrrrrrrrrrr")



func get_boundary_point(center: Vector2, size: Vector2, direction: Vector2) -> Vector2:
	var half_size = size / 2.0
	var dx = direction.x
	var dy = direction.y

	if dx == 0:
		return center + Vector2(0, half_size.y * sign(dy))
	if dy == 0:
		return center + Vector2(half_size.x * sign(dx), 0)

	var scale_x = half_size.x / abs(dx)
	var scale_y = half_size.y / abs(dy)

	var scale_t = min(scale_x, scale_y)
	return center + direction * scale_t




#func _on_send_rectangle_cord(starting_coord:Vector2,ending_coord:Vector2):
	#var min_x = min(starting_coord.x,ending_coord.x)
	#var max_x = max(starting_coord.x,ending_coord.x)
	#var min_y = min(starting_coord.y,ending_coord.y)
	#var max_y = max(starting_coord.y,ending_coord.y)
	#
	#if points[0].x >= min_x and points[1].x <= max_x and points[0].y >= min_y and points[1].y <= max_y :
			#is_selected = true



func _on_send_rectangle_cord(starting_coord: Vector2, ending_coord: Vector2):
	var min_x = min(starting_coord.x, ending_coord.x)
	var max_x = max(starting_coord.x, ending_coord.x)
	var min_y = min(starting_coord.y, ending_coord.y)
	var max_y = max(starting_coord.y, ending_coord.y)

	var rect = Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

	var A = points[0]
	var B = points[1]
	is_selected = false

	# Case 1: One of the points is inside the rectangle
	if rect.has_point(A) or rect.has_point(B):
		is_selected = true
		return

	# Case 2: Check if line AB intersects any side of the rectangle
	var rect_edges = [
		[Vector2(min_x, min_y), Vector2(max_x, min_y)], # top
		[Vector2(max_x, min_y), Vector2(max_x, max_y)], # right
		[Vector2(max_x, max_y), Vector2(min_x, max_y)], # bottom
		[Vector2(min_x, max_y), Vector2(min_x, min_y)]  # left
	]

	for edge in rect_edges:
		if Geometry2D.segment_intersects_segment(A, B, edge[0], edge[1]) != null:
			is_selected = true
			return


func _on_option_button_item_selected(index: int) -> void:
	if index == 0 :
		texture = null
		width = 10
	elif index == 1 :
		texture = DOTTED_LINE_TEST_32_PX_WHITE
		width = 32
