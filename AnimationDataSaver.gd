extends Node

onready var parent = get_parent().get_parent() #the actual object whose data is being saved

func processLoadData(data:Dictionary):
	parent.duration = data.duration
	
func getDataToSave() -> Dictionary:
	var r: Dictionary = {}
	r.what = "Animation"
	r.duration = parent.duration
	return r
