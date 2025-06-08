extends Node2D



const MENU_ITEM = preload('res://scenes/menu_item/menu_item.tscn')
const CANVAS_ITEM = preload('res://scenes/canvas_item/canvas_item.tscn')
const CONNECTION = preload('res://scenes/connections/connection.tscn')


@onready var canvas_item_collection: Node2D = $canvas_item_collection
@onready var canvas_connection_collection: Node2D = $canvas_connection_collection
@onready var selection_drawing: Node2D = $selection_drawing
@onready var main: Node2D = $'.'
@onready var properties_panel: PropertiesPanel = $CanvasLayer/Properties_panel


var is_mouse_busy : bool = false
var is_drawing : bool = false
var selected_item : Canvas_Item
var property_selected_item : Canvas_Item
var previous_property_selected_item : Canvas_Item

var connection_array : Array[Canvas_Item] = []

var lp1 : Vector2 = Vector2.ZERO 
var lp2 : Vector2 = Vector2.ZERO


var bounding_box_properties : Rect2 
const BOUNDING_BOX_PADDING : Vector2 = Vector2(100,100)

func _ready() -> void:
	#capture_subviewport_image()
	#pass # Replace with function body.
	if canvas_item_collection.get_children():
		bounding_box_properties = get_bounding_box(canvas_item_collection.get_children() as Array[Canvas_Item])


func _process(_delta: float) -> void:
	if canvas_item_collection.get_children():
		bounding_box_properties = get_bounding_box(canvas_item_collection.get_children() )
	queue_redraw()
	if Input.is_action_just_pressed('save'):
		s()
		capture_subviewport_region(Vector2(50, 30), Vector2(2000, 1500))
	dropitem()
	create_connectiona()
	#create_connection()
	#if selected_item :
		#print(str(selected_item)+ " : "+ str(selected_item.is_selected))
	#if selected_item and selected_item.is_selected :
		#previous_selected_item = selected_item
		#properties_panel.line_edit.text = selected_item.label.text 
	#elif selected_item and  (selected_item.is_selected != true or selected_item != previous_selected_item ) :
		#properties_panel.line_edit.text = ""
	if property_selected_item :
		previous_property_selected_item = property_selected_item
		if selected_item and selected_item.is_selected:
			properties_panel.line_edit.text = property_selected_item.label.text
		elif selected_item and selected_item.is_selected == false:
			properties_panel.line_edit.text = ""
		print (str(property_selected_item)+ " : "+ str(property_selected_item.is_selected) )
		print ("prev : " + str(previous_property_selected_item)+ " : "+ str(previous_property_selected_item.is_selected) )


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
		#item_instance.connect('request_for_properties_panel',_on_canvas_item_request_for_properties_panel)
		item_instance.myname = item_name
		item_instance.opacity = 0.5
		item_instance.position = get_global_mouse_position()
		canvas_item_collection.add_child(item_instance)
		selected_item = item_instance
		is_mouse_busy = true
		selection_drawing.is_mouse_busy = is_mouse_busy

 
func _on_canvas_item_item_selected(_item_name: String, itself: Canvas_Item) -> void:
	selected_item = itself
	#print(itself)
	selected_item.opacity = 0.5
	is_mouse_busy = true
	selection_drawing.is_mouse_busy = is_mouse_busy


#func _on_canvas_item_request_for_properties_panel(itself: Canvas_Item):
	#property_selected_item = itself


func _on_canvas_item_request_for_connection(itself: Canvas_Item):
	if connection_array.is_empty() :
		connection_array.append(itself)
	elif connection_array.find(itself) == -1 :
		connection_array.append(itself)








var occupied_areas := []
var current_col := 0
var current_row := 0
const start_x := 100
const start_y := 100
const padding := 40
const column_width := 300
const row_height := 180
var actor_left := true # Set to false to place actors on the right side

# Helper: Get a valid, non-overlapping position for use cases
func get_valid_position(item_size: Vector2) -> Vector2:
	while true:
		var pos = Vector2(start_x + current_col * column_width, start_y + current_row * row_height)
		var item_rect = Rect2(pos, item_size)
		var overlaps = false
		for rect in occupied_areas:
			if rect.intersects(item_rect):
				overlaps = true
				break
		if not overlaps:
			occupied_areas.append(item_rect)
			return pos
		current_col += 1
		if current_col > 4:
			current_col = 0
			current_row += 1
	return Vector2.ZERO

# Helper: Get position for vertically stacked actors on left or right
func get_actor_position(index: int) -> Vector2:
	var x = 50 if actor_left else (start_x + 4 * column_width)
	var y = start_y + index * (130 + padding)
	var pos = Vector2(x, y)
	var actor_rect = Rect2(pos, Vector2(130, 130))  # Actors are fixed size
	occupied_areas.append(actor_rect)  # Mark area as occupied
	return pos

# Helper: Create and position an item
func create_item(canvas_item_name: String, is_dynamic: bool, type: String, index := 0) -> Canvas_Item:
	var item_instance = CANVAS_ITEM.instantiate() as Canvas_Item
	item_instance.itself = item_instance
	item_instance.main_node = main
	item_instance.connect("item_selected", _on_canvas_item_item_selected)
	item_instance.connect("request_for_connection", _on_canvas_item_request_for_connection)
	item_instance.myname = type
	item_instance.text_display = canvas_item_name

	var item_size : Vector2 = Vector2.ZERO
	if is_dynamic:
		item_size = Vector2(50 + canvas_item_name.length() * 10, 100)
	elif not is_dynamic:
		item_size = Vector2(130, 130)

	if type == "stickman":
		item_instance.position = get_actor_position(index)
	else:
		item_instance.position = get_valid_position(item_size)

	canvas_item_collection.add_child(item_instance)
	return item_instance

# Main Function: Populate the canvas
func populate_canvas(use_case_array: Array, actor_array: Array, connection_item_array: Array) -> void:
	occupied_areas.clear()
	current_col = 0
	current_row = 0
	var object_map  = {}

	# Add actors (fixed), vertically aligned on left or right
	for i in actor_array.size():
		var actor_item = create_item(actor_array[i], false, "stickman", i)
		object_map[actor_array[i]] = actor_item

	# Add use cases (dynamic)
	for usecase_name in use_case_array:
		var usecase_item = create_item(usecase_name, true, "use_case")
		object_map[usecase_name] = usecase_item

	print(object_map)
	# Add connections
	for conn in connection_item_array:
		var from_name = conn.get("from_node")
		var to_name = conn.get("to_node")
		var connection_type = conn.get("connection_type")

		if object_map.has(from_name) and object_map.has(to_name):
			var connection_instance = CONNECTION.instantiate() as Connection
			connection_instance.main_node = main
			connection_instance.connection_1 = object_map[from_name]
			connection_instance.connection_2 = object_map[to_name]
			connection_instance.connection_type = connection_type
			canvas_connection_collection.add_child(connection_instance)

#var occupied_areas := []
#var current_col := 0
#var current_row := 0
#const start_x := 100
#const start_y := 100
#const padding := 40
#const column_width := 300
#const row_height := 180
#
## Helper: Get a valid, non-overlapping position
#func get_valid_position(item_size: Vector2) -> Vector2:
	#while true:
		#var pos = Vector2(start_x + current_col * column_width, start_y + current_row * row_height)
		#var item_rect = Rect2(pos, item_size)
		#var overlaps = false
		#for rect in occupied_areas:
			#if rect.intersects(item_rect):
				#overlaps = true
				#break
		#if not overlaps:
			#occupied_areas.append(item_rect)
			#return pos
		#current_col += 1
		#if current_col > 4:
			#current_col = 0
			#current_row += 1
	#return Vector2.ZERO
#
## Helper: Create and position an item
#func create_item(canvas_item_name: String, is_dynamic: bool, type: String) -> Canvas_Item:
	#var item_instance = CANVAS_ITEM.instantiate() as Canvas_Item
	#item_instance.itself = item_instance
	#item_instance.main_node = main
	#item_instance.connect("item_selected", _on_canvas_item_item_selected)
	#item_instance.connect("request_for_connection", _on_canvas_item_request_for_connection)
	#if type == "stickman":
		#item_instance.myname = type
		#item_instance.text_display = canvas_item_name
	#elif type == "use_case":
		#item_instance.myname = type
		#item_instance.text_display = canvas_item_name
	#var item_size : Vector2 = Vector2.ZERO
	#if is_dynamic :
		#item_size = Vector2(50 + canvas_item_name.length() * 10, 100)
	#elif  not is_dynamic :
		#item_size = Vector2(130, 130)
	##var item_size: Vector2 = is_dynamic \
		##? Vector2(50 + name.length() * 10, 100) \
		##: Vector2(130, 130)
#
	#item_instance.position = get_valid_position(item_size)
	#canvas_item_collection.add_child(item_instance)
	#return item_instance
#
## Main Function: Populate the canvas
#func populate_canvas(use_case_array: Array, actor_array: Array, connection_item_array: Array) -> void:
	#occupied_areas.clear()
	#current_col = 0
	#current_row = 0
	#var object_map = {}
#
	## Add actors (fixed)
	#for actor_name in actor_array:
		#var actor_item = create_item(actor_name, false,"stickman")
		#object_map[actor_name] = actor_item
#
	## Add use cases (dynamic)
	#for usecase_name in use_case_array:
		#var usecase_item = create_item(usecase_name, true,"use_case")
		#object_map[usecase_name] = usecase_item
#
	## Add connections
	#for conn in connection_item_array:
		#var from_name = conn.get("from_node")
		#var to_name = conn.get("to_node")
		#var connection_type = conn.get("connection_type")
#
		#if object_map.has(from_name) and object_map.has(to_name):
			#var connection_instance = CONNECTION.instantiate() as Connection
			#connection_instance.main_node = main
			#connection_instance.connection_1 = object_map[from_name]
			#connection_instance.connection_2 = object_map[to_name]
			#connection_instance.connection_type = connection_type
			#canvas_connection_collection.add_child(connection_instance)













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
	draw_rect(
		bounding_box_properties,
		Color(Color.AQUA ,1),5.0
	)
	if dragging and not is_mouse_busy:
		start_coord = dragging_start
		end_coord = dragging_start + (get_global_mouse_position() - dragging_start)
		draw_rect(Rect2(dragging_start,get_global_mouse_position() - dragging_start),Color(Color.CRIMSON,1),5.0)
		emit_signal('send_reqtangle_coord',start_coord,end_coord)
	elif not dragging:
		pass














# Each object is a dictionary with `center`, `vertical`, `horizontal`
#var objects = [
	#{ "center": Vector2(100, 100), "vertical": 20, "horizontal": 30 },
	#{ "center": Vector2(200, 150), "vertical": 50, "horizontal": 40 },
	#{ "center": Vector2(150, 80),  "vertical": 25, "horizontal": 35 },
#]


func get_bounding_box(objects: Array) -> Rect2:
	if objects.size() == 0:
		return Rect2()

	var first = objects[0]
	var center = first.position
	var h = int(first.collision_shape_2d.shape.size.x / 2)
	var v = int(first.collision_shape_2d.shape.size.y / 2)

	var min_x = center.x - h
	var max_x = center.x + h
	var min_y = center.y - v
	var max_y = center.y + v

	for obj in objects:
		var c = obj.position
		var hor = int(first.collision_shape_2d.shape.size.x / 2)
		var ver = int(first.collision_shape_2d.shape.size.y / 2)

		min_x = min(min_x, c.x - hor)
		max_x = max(max_x, c.x + hor)
		min_y = min(min_y, c.y - ver)
		max_y = max(max_y, c.y + ver)

	var top_left = Vector2(min_x, min_y) - BOUNDING_BOX_PADDING
	var size = Vector2(max_x - min_x, max_y - min_y) + BOUNDING_BOX_PADDING * 2

	return Rect2(top_left, size)
	#return [top_left, size]





func capture_subviewport_image():
	var subviewport := $SubViewport  # Reference your SubViewport node
	var image = subviewport.get_texture().get_image()
	image.save_png("user://snapshot.png")
	print("Saved SubViewport snapshot!")


func s():
	get_tree().root.get_texture().get_image().save_png("res://snapshot23.png")
	# Create the SubViewport 
	var sub_viewport = SubViewport.new()
	# Add the SubViewport to the tree
	add_child(sub_viewport)
	# Use the same World2D as the main Viewport
	sub_viewport.world_2d = get_viewport().world_2d
	# Set its size
	sub_viewport.size = Vector2(6000, 6000)
	# We only need it to update once for the screenshoot
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	# Move it to the place we want to take the screenshoot
	sub_viewport.canvas_transform.origin = Vector2(0, 0)
	# Wait for the next frame to render
	await RenderingServer.frame_post_draw
	# Grab the image, save it and free the SubViewport
	var img = sub_viewport.get_texture().get_image()
	img.save_png("res://screenshot33.png")
	sub_viewport.queue_free()
	#var n = get_tree().root as Viewport
	#n.set_min_size(Vector2(4096,4096))
	#n.get_texture().get_image().save_png("user://snapshotNN.png")

func capture_subviewport_region(region_position: Vector2, region_size: Vector2):
	var subviewport : SubViewport = $CanvasLayer/SubViewportContainer/SubViewport
	var rect = ColorRect.new()
	rect.color = Color.RED
	rect.size = Vector2(200, 200)
	subviewport.add_child(rect)

	var full_image = subviewport.get_texture().get_image()

	# Ensure the image is loaded properly
	if full_image.is_empty():
		print("Failed to get image from SubViewport.")
		return

	# Crop the image to the specified region
	var cropped_image = full_image.get_region(Rect2(region_position, region_size))

	# Save the cropped image
	cropped_image.save_png("user://snapshot_region.png")
	print("Saved cropped region snapshot!")





#func _on_properties_panel_text_change(new_text: String) -> void:
	##pass
	#if property_selected_item.is_selected :
		#property_selected_item.label.text = new_text
	#else :
		#property_selected_item.label.text = ""


func _on_code_writer_and_pasrser_send_parsed_data_to_main_scene(use_case_array: Array, actor_array: Array, connection_item_array: Array) -> void:
	populate_canvas(use_case_array,actor_array,connection_item_array)
	#print("Usecase : " , use_case_array)
	#print("actor : " , actor_array)
	#print("Connection : " , connection_item_array)
