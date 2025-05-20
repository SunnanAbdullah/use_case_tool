extends Camera2D


var position_percentage : Vector2i
#@onready var pp: Label = $CanvasLayer/PP
#@onready var ds: Label = $CanvasLayer/DS
#@onready var gp: Label = $CanvasLayer/GP
var ep
var event_relative_screen
#Viewport
#Window



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#limit_left = -100
	#limit_right = 2000
	editor_draw_limits = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#pp.text = "Percentage_Position : " + str(position_percentage)
	#ds.text = "Display_Server : " + str(DisplayServer.window_get_size())
	#gp.text = "Global_Position : " + str(ep)


	#if position_percentage.x >= 95 :
		#position.x += 4
	#elif position_percentage.x <= 5 :
		#position.x += -4
#
	#if position_percentage.y >= 95 :
		#position.y += 4
	#elif position_percentage.y <= 5 :
		#position.y += -4
	
	#if position.y > -100:
		#position.y = -99
	#elif position.y < 1400 :
		#position.y = 1399



	if Input.is_action_just_pressed('wheel_up') and zoom < Vector2(4,4):
		zoom += Vector2(.1,.1)
	elif Input.is_action_just_pressed('wheel_down') and zoom > Vector2(0.5,0.5):
		zoom -= Vector2(.1,.1)
	elif Input.is_action_pressed('mouse_middle_button') :
		position += (event_relative_screen * 8)/ zoom
		#if position.x > -100:
			#position.x = -99
		#elif position.x < 2000 :
			#position.x = 1999
	else:
		event_relative_screen = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion :
		#position += event.screen_relative.normalized()
		event_relative_screen = event.screen_relative.normalized()
		ep = event.global_position
		position_percentage = Vector2i(
			int(100 * (event.global_position.x / DisplayServer.window_get_size().x) ),
			int(100 * (event.global_position.y / DisplayServer.window_get_size().y) )
		)
		#print(position_percentage)#1152 x 648
		#print(DisplayServer.window_get_size())
