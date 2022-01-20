extends Node
class_name Saveable, "save_icon.png"

#this control makes it's parent's data saveable. 
#To save more data, add a child node that has 
# getDataToSave and processLoadData functions
# NOTE: you MUST override the _ready() function in the child 


var parent
func _ready():
	parent = get_parent()
	add_to_group("saveable")

func processLoadData(data:Dictionary):
	for c in get_children():
		if c.has_method("processLoadData"):
			c.processLoadData(data)
	
func getDataToSave() -> Dictionary:
	var r: Dictionary = {}
	r.name = parent.name
	r.rect_position = parent.rect_position
	r.rect_size = parent.rect_size
	r.path_to_parent = parent.get_parent().get_path()
	r.scene = parent.filename
	for c in get_children():
		if c.has_method("getDataToSave"):
			r = egs.merge(r, c.getDataToSave())
	return r


