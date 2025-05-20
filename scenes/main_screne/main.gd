extends Node2D


const MENU_ITEM = preload('res://scenes/menu_item/menu_item.tscn')
const CANVAS_ITEM = preload('res://scenes/canvas_item/canvas_item.tscn')


@onready var canvas_item_collection: Node2D = $canvas_item_collection
@onready var canvas_connection_collection: Node2D = $canvas_connection_collection


var is_mouse_busy : bool = false
var is_drawing : bool = false
var selected_item : Canvas_Item


var lp1 : Vector2 = Vector2.ZERO 
var lp2 : Vector2 = Vector2.ZERO


func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	dropitem()
	create_connection()

func dropitem():
	if is_mouse_busy and not is_drawing :
		selected_item.global_position = get_global_mouse_position()
		if Input.is_action_just_released('left_click') :
			selected_item.opacity = 1.0
			is_mouse_busy = false
			selected_item = null


func create_connection():
	#if not is_mouse_busy and Input.is_action_just_pressed('right_click') :
		#is_mouse_busy = true
		#lp1 = get_global_mouse_position()
		#if Input.is_action_just_pressed('right_click'):
			#lp2 = get_global_mouse_position()
			#is_mouse_busy = false
	#elif lp1 > Vector2.ZERO and lp2 > Vector2.ZERO :
		#var line2d = Line2D.new()
		#line2d.add_point(lp1)
		#line2d.add_point(lp2)
		#canvas_connection_collection.add_child(line2d)
		#lp1 = Vector2.ZERO
		#lp2 = Vector2.ZERO
	if Input.is_action_just_pressed('right_click'):
		is_drawing = true
		if not is_mouse_busy:
			is_mouse_busy = true
			lp1 = get_global_mouse_position()
		else:
			is_mouse_busy = false
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




func _on_menu_layer_item_selected(item_name: String) -> void:
	if not is_mouse_busy :
		#var item_instance = MENU_ITEM.instantiate() as MenuItem
		var item_instance = CANVAS_ITEM.instantiate() as Canvas_Item
		item_instance.itself = item_instance
		item_instance.connect('item_selected', _on_canvas_item_item_selected)
		item_instance.myname = item_name
		item_instance.opacity = 0.5
		item_instance.position = get_global_mouse_position()
		canvas_item_collection.add_child(item_instance)
		selected_item = item_instance
		is_mouse_busy = true


 
func _on_canvas_item_item_selected(_item_name: String, itself: Canvas_Item) -> void:
	selected_item = itself
	print(itself)
	selected_item.opacity = 0.5
	is_mouse_busy = true
