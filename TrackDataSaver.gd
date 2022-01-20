extends Node
	
onready var parent = get_parent().get_parent()

func processLoadData(data:Dictionary):
	return
	
func getDataToSave() -> Dictionary:
	var r: Dictionary = {}
	r["what"] = "track"
	return r
