tool
extends ColorRect
class_name Playhead

func _enter_tree():
	if !Engine.editor_hint:
		queue_free()
	call_deferred("doInit")
	
func doInit():		
	if not owner.is_connected("frameChanged", self, "updatePosition"):
		owner.connect("frameChanged", self, "updatePosition")
	if not TimelineEditor.is_connected("zoomChanged", self, "updatePosition"):
		TimelineEditor.connect("zoomChanged", self, "updatePosition")
	rect_size = Vector2(1,3000)
	color = Color(1,1,1,0.3)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	name = "Playhead"
	
func updatePosition():	
	rect_position.x = TimelineEditor.animation.position * TimelineEditor.zoom.x -  TimelineEditor.scroll.x
