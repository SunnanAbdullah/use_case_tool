class_name Canvas_Item extends Area2D


signal item_selected(item_name:String, itself:Canvas_Item)
signal request_for_connection(itself:Canvas_Item)
#signal request_for_properties_panel(itself: Canvas_Item)


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $Label
@onready var properties_panel: PropertiesPanel = $Properties_panel


const STICKMAN = preload('res://graphics/stickman.png')
const USE_CASE = preload('res://graphics/use_case.png')

@export var text_display : String = ""
@export var main_node : Node2D
@export var padding: Vector2 = Vector2(20, 40) # extra space around the text
@export var opacity : float = 1.0
@export var color : Color = Color.WHITE
@export_enum(
	"white",
	"red",
	"green",
	"stickman",
	"use_case"
) var myname : String =  "white"



var is_mouse_entered : bool = false
var itself : Canvas_Item = null
var is_selected : bool = false

func _input(event: InputEvent) -> void:
	if event is InputEvent and event.is_action_pressed('delete') and is_selected :
		self.queue_free()
	if event is InputEventMouseButton and is_selected and event.button_index == MOUSE_BUTTON_RIGHT :
		is_selected = false
	if event is InputEventMouseButton  and is_mouse_entered:
		if event.is_action_pressed('left_click') :
			#print("llllllllllllllllllllllllllllllllllllllllll")
			is_selected = true
			emit_signal('item_selected',myname,itself)
		elif event.is_action_pressed('right_click') :
			#print("llllllllllllllllllllllllllllllllllllllllll")
			emit_signal('request_for_connection',itself)

func _ready() -> void:
	label.text = myname
	if not text_display.is_empty():
		label.text = text_display
## This below equation draws the collision shape for changing size of image
	if collision_shape_2d.shape != null :
		collision_shape_2d.shape = collision_shape_2d.shape.duplicate()
	if myname == "use_case":
		queue_redraw()  # correct in Godot 4
		collision_shape_2d.shape.size = calculate_ellipse_size()
	else :
		collision_shape_2d.shape.size = Vector2((sprite_2d.texture.get_width() * sprite_2d.scale.x),(sprite_2d.texture.get_height() * sprite_2d.scale.y))

	if main_node :
		main_node.connect("send_reqtangle_coord",_on_send_rectangle_cord)


	#queue_redraw()
	#collision_shape_2d.shape.size = Vector2((sprite_2d.texture.get_width() * sprite_2d.scale.x),(sprite_2d.texture.get_height() * sprite_2d.scale.y))
	item_type()
	#update_oval_size()
	_properties_panel_position()


func _properties_panel_position():
	if myname == "stickman":
		properties_panel.position.y = label.position.y + 16
	elif  myname == "use_case" :
		properties_panel.position.y = collision_shape_2d.shape.size.y 


func _process(_delta: float) -> void:
	#collision_shape_2d.shape.size = Vector2((sprite_2d.texture.get_width() * sprite_2d.scale.x),(sprite_2d.texture.get_height() * sprite_2d.scale.y))
	sprite_2d.modulate.a = opacity
	if is_selected :
		properties_panel.visible = true
		#if itself :
			#emit_signal("request_for_properties_panel",itself)
		label.modulate = Color.RED
	else :
		properties_panel.visible = false
		label.modulate = Color.BLACK


func item_type():
	if myname == "white":
		sprite_2d.modulate = Color.WHITE
	elif myname == "red":
		sprite_2d.modulate = Color.RED
	elif myname == "green":
		sprite_2d.modulate = Color.GREEN
	elif myname == "stickman":
		@warning_ignore("integer_division")
		label.position.y = sprite_2d.texture.get_height()/2 + 16
		sprite_2d.texture = STICKMAN
	elif  myname == "use_case" :
		sprite_2d.texture = null




func _on_mouse_entered() -> void:
	#print("mouse enter in "+ myname)
	is_mouse_entered = true

func _on_mouse_exited() -> void:
	is_mouse_entered = false







@export_group("Label Setting")
#@export var padding: Vector2 = Vector2(10, 5)
@export var ellipse_color: Color = Color.BLACK
@export var ellipse_thickness: float = 10.0
@export var segments: int = 64  # More segments = smoother ellipse


func _on_send_rectangle_cord(starting_coord: Vector2, ending_coord: Vector2):
	var min_x = min(starting_coord.x, ending_coord.x)
	var max_x = max(starting_coord.x, ending_coord.x)
	var min_y = min(starting_coord.y, ending_coord.y)
	var max_y = max(starting_coord.y, ending_coord.y)

# Get the collision shape position (center) and size
	var center = collision_shape_2d.global_position
	var rect_shape = collision_shape_2d.shape as RectangleShape2D
	var half_size = rect_shape.size / 2.0

	# Calculate the bounds of the box
	var box_min_x = center.x - half_size.x
	var box_max_x = center.x + half_size.x
	var box_min_y = center.y - half_size.y
	var box_max_y = center.y + half_size.y

# Full containment check
	if ( box_min_x >= min_x and box_max_x <= max_x and box_min_y >= min_y and box_max_y <= max_y):
		is_selected = true
		#print("Collision box is fully inside the custom rectangle.")
	# Partial intersection check
	elif not ( box_max_x < min_x or box_min_x > max_x or box_max_y < min_y or box_min_y > max_y ):
		is_selected = true
		#print("Collision box is partially inside the custom rectangle.")
	# No overlap
	else:
		is_selected = false
		#print("Collision box is completely outside the custom rectangle.")



func update_oval_size():
	var font := label.get_theme_font("font")
	if font == null or sprite_2d.texture == null:
		return

	# Get size of the text
	var text_size = font.get_string_size(label.text)

	# Add padding
	var target_size = text_size + padding * 2

	# Get texture size of the oval image
	var texture_size = sprite_2d.texture.get_size()

	if texture_size == Vector2.ZERO:
		return

	# Scale the sprite to fit the target size
	sprite_2d.scale = target_size / texture_size

	# Align sprite center with label center
	var label_center = label.global_position + (label.size / 2)
	sprite_2d.global_position = label_center
	sprite_2d.position -= (texture_size * sprite_2d.scale) / 2


func calculate_ellipse_size() -> Vector2:
	if label == null:
		return Vector2.ZERO
	var font := label.get_theme_font("font")
	if font == null:
		return Vector2.ZERO
	var text := label.text
	return font.get_string_size(text) + padding * 2


func _draw():
	if myname == "use_case":
		if label == null:
			return

		var font := label.get_theme_font("font")
		if font == null:
			return

		var text := label.text
		var text_size := font.get_string_size(text)
		var ellipse_size := text_size + padding * 2
		var center := label.global_position + (label.size / 2)

		# Convert to local coordinates of this node
		var local_center := to_local(center)

		# Simulate an ellipse using points
		var points := []
		for i in range(segments + 1):
			var angle := (TAU * i) / segments
			var x := (ellipse_size.x / 2) * cos(angle)
			var y := (ellipse_size.y / 2) * sin(angle)
			points.append(local_center + Vector2(x, y))

		# Now draw the ellipse as a polyline
		if points.size() >= 2:
			draw_polyline(points, ellipse_color, ellipse_thickness)


func _on_properties_panel_text_change(new_text: String) -> void:
	label.text = new_text
	if myname == "use_case":
		queue_redraw()  
		_properties_panel_position()
		collision_shape_2d.shape.size = calculate_ellipse_size()
