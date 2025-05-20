extends Node2D


signal item_selected(item_name:String)


var items : Array = [Color.PURPLE, Color.RED, Color.DEEP_PINK]




func _ready() -> void:
	pass
	#for item in items :
		#var item_instance = MENU_ITEM.instantiate() 
		##item_instance.color = item
		#v_scroll_bar.add_child(item_instance)


func _process(_delta: float) -> void:
	pass


func _on_menu_item_selected(itemname: String) -> void:
	emit_signal('item_selected',itemname)
