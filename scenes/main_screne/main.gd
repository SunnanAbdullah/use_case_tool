extends Node2D


const MENU_ITEM = preload('res://scenes/menu_item/menu_item.tscn')
const CANVAS_ITEM = preload('res://scenes/canvas_item/canvas_item.tscn')
const CONNECTION = preload('res://scenes/connections/connection.tscn')


@onready var canvas_item_collection: Node2D = $canvas_item_collection
@onready var canvas_connection_collection: Node2D = $canvas_connection_collection
@onready var selection_drawing: Node2D = $selection_drawing
@onready var main: Node2D = $'.'


var is_mouse_busy : bool = false
var is_drawing : bool = false
var selected_item : Canvas_Item


var connection_array : Array[Canvas_Item] = []

var lp1 : Vector2 = Vector2.ZERO 
var lp2 : Vector2 = Vector2.ZERO


func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	dropitem()
	create_connectiona()
	#create_connection()

func dropitem():
	if is_mouse_busy and not is_drawing :
		selected_item.global_position = get_global_mouse_position()
		if Input.is_action_just_released('left_click') :
			selected_item.opacity = 1.0
			is_mouse_busy = false
			selection_drawing.is_mouse_busy = is_mouse_busy
			selected_item = null


func create_connection():
	if Input.is_action_just_pressed('right_click'):
		is_drawing = true
		if not is_mouse_busy:
			is_mouse_busy = true
			selection_drawing.is_mouse_busy = is_mouse_busy
			lp1 = get_global_mouse_position()
		else:
			is_mouse_busy = false
			selection_drawing.is_mouse_busy = is_mouse_busy
			lp2 = get_global_mouse_position()
			if canvas_connection_collection != null: # Safely check if the target node exists
				var line2d = Line2D.new()
				line2d.add_point(lp1)
				line2d.add_point(lp2)
				line2d.default_color = Color(1, 1, 1, 1)  # set a default color
				line2d.width = 2 # set a default width
				canvas_connection_collection.add_child(line2d) # Add the line to the scene
			lp1 = Vector2.ZERO # Reset points after creating the line.
			lp2 = Vector2.ZERO
			is_drawing = false


func create_connectiona():
	if connection_array.size() >= 2 :
		var connection_instance = CONNECTION.instantiate() as Connection
		connection_instance.main_node = main
		connection_instance.connection_2 = connection_array.pop_back()
		connection_instance.connection_1 = connection_array.pop_back()
		canvas_connection_collection.add_child(connection_instance)



func _on_menu_layer_item_selected(item_name: String) -> void:
	if not is_mouse_busy :
		#var item_instance = MENU_ITEM.instantiate() as MenuItem
		var item_instance = CANVAS_ITEM.instantiate() as Canvas_Item
		item_instance.itself = item_instance
		item_instance.main_node = main
		item_instance.connect('item_selected', _on_canvas_item_item_selected)
		item_instance.connect('request_for_connection',_on_canvas_item_request_for_connection)
		item_instance.myname = item_name
		item_instance.opacity = 0.5
		item_instance.position = get_global_mouse_position()
		canvas_item_collection.add_child(item_instance)
		selected_item = item_instance
		is_mouse_busy = true
		selection_drawing.is_mouse_busy = is_mouse_busy

 
func _on_canvas_item_item_selected(_item_name: String, itself: Canvas_Item) -> void:
	selected_item = itself
	print(itself)
	selected_item.opacity = 0.5
	is_mouse_busy = true
	selection_drawing.is_mouse_busy = is_mouse_busy



func _on_canvas_item_request_for_connection(itself: Canvas_Item):
	if connection_array.is_empty() :
		connection_array.append(itself)
	elif connection_array.find(itself) == -1 :
		connection_array.append(itself)











var dragging : bool = false
var dragging_start : Vector2 = Vector2.ZERO
var rectangle_area : RectangleShape2D = RectangleShape2D.new()
var selected = []


signal send_reqtangle_coord(starting_coord:Vector2,ending_coord:Vector2)
var start_coord : Vector2 = Vector2.ZERO
var end_coord : Vector2 = Vector2.ZERO




func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not is_mouse_busy:
		if event.pressed:
			dragging = true
			dragging_start = get_global_mouse_position()
		elif dragging :
			dragging = false
			queue_redraw()
	if event is InputEventMouseMotion and dragging :
		queue_redraw()
	#label.text = "stating : " + str(dragging_start) + " Ending : "+ str(get_global_mouse_position() - dragging_start) + " Ending Refine : "+ str(get_global_mouse_position())




func _draw() -> void:
	if dragging and not is_mouse_busy:
		start_coord = dragging_start
		end_coord = dragging_start + (get_global_mouse_position() - dragging_start)
		draw_rect(Rect2(dragging_start,get_global_mouse_position() - dragging_start),Color(Color.CRIMSON,1),5.0)
		emit_signal('send_reqtangle_coord',start_coord,end_coord)
	elif not dragging:
		pass
