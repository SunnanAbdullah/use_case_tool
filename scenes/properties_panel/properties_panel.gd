class_name PropertiesPanel extends Node2D


signal text_change(new_text:String)


@onready var line_edit: LineEdit = $Control/VBoxContainer/HBoxContainer2/LineEdit
@onready var label: Label = $Control/VBoxContainer/HBoxContainer/Label
var text : String = ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func _on_line_edit_text_changed(new_text: String) -> void:
	print("sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss")
	emit_signal('text_change',new_text)
