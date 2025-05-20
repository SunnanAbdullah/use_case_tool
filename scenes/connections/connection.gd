class_name Connection extends Line2D

@export var connection_1 : Canvas_Item
@export var connection_2 : Canvas_Item


@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D


func _ready() -> void:
	if connection_1 and connection_2 :
		points[0] = connection_1.global_position
		points[1] = connection_2.global_position
		collision_shape_2d.shape.a = points[0]
		collision_shape_2d.shape.b = points[1]


func _process(delta: float) -> void:
	if connection_1 and connection_2 :
		points[0] = connection_1.global_position
		points[1] = connection_2.global_position
		collision_shape_2d.shape.a = points[0]
		collision_shape_2d.shape.b = points[1]


func _on_area_2d_mouse_entered() -> void:
	print("enterrrrrrrrrrrrrrrrrrrrrrrrr")
