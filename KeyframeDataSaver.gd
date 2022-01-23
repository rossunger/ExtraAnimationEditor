extends Node

onready var parent = get_parent().get_parent()

func processLoadData(data:Dictionary):	
	parent.time = data.time
	parent.absolute = data.absolute
	parent.type = data.type
	parent.curve = str2var(data.curve)
	
	
func getDataToSave() -> Dictionary:
	var r: Dictionary = {}
	r["what"] = "keyframe"
	r["time"] = parent.time
	r["absolute"] = parent.absolute	
	r["type"] = parent.type	
	r["curve"] = var2str(parent.curve) 
	return r
