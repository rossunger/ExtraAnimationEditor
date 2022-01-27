tool
extends ColorRect

func _ready():
	if !Engine.editor_hint:
		queue_free()
		
	owner.connect("frameChanged", self, "updatePosition")
	if ! TimelineEditor.is_connected("zoomChanged", self, "updatePosition"):
		TimelineEditor.connect("zoomChanged", self, "updatePosition")

	
	
func updatePosition():	
	rect_position.x = TimelineEditor.animation.position * TimelineEditor.zoom.x -  TimelineEditor.scroll.x
