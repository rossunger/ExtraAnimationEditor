tool
extends ColorRect


func _enter_tree():
	print(get_path())
	get_viewport().add_child(self)
	#self["rect_position"]["x"] = 600
	print(self["rect_position"]["x"])
