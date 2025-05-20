class_name Canvas_Item extends Area2D


signal item_selected(item_name:String, itself:Canvas_Item)

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var opacity : float = 1.0
@export var color : Color = Color.WHITE
@export_enum("white","red","green") var myname : String =  "white"

var is_mouse_entered : bool = false
var itself : Canvas_Item = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton  and is_mouse_entered:
		if event.is_action_pressed('left_click') :
			print("llllllllllllllllllllllllllllllllllllllllll")
			emit_signal('item_selected',myname,itself)


func _ready() -> void:
## This below equation draws the collision shape for changing size of image
	collision_shape_2d.shape.size = Vector2((sprite_2d.texture.get_width() * sprite_2d.scale.x),(sprite_2d.texture.get_height() * sprite_2d.scale.y))
	#sprite_2d.modulate = color
	#myname = name
	item_type()

func _process(_delta: float) -> void:
	#collision_shape_2d.shape.size = Vector2((sprite_2d.texture.get_width() * sprite_2d.scale.x),(sprite_2d.texture.get_height() * sprite_2d.scale.y))
	sprite_2d.modulate.a = opacity



func item_type():
	if myname == "white":
		sprite_2d.modulate = Color.WHITE
	elif myname == "red":
		sprite_2d.modulate = Color.RED
	elif myname == "green":
		sprite_2d.modulate = Color.GREEN


func _on_mouse_entered() -> void:
	print("mouse enter in "+ myname)
	is_mouse_entered = true

func _on_mouse_exited() -> void:
	is_mouse_entered = false
