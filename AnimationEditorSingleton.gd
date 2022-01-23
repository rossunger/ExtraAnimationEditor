extends Node

signal keyframeChanged #for editing 
signal frameChanged #for playback
signal contextChanged
signal animationChanged
signal play
signal stop
var previewContext: PackedScene

#func createNewAnimation(name="NewAnimation"):
#	var newAnimation = Resource.new()
	
func frameChanged(position):
	emit_signal("frameChanged", position)
