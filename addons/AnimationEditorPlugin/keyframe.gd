tool
extends ColorRect
class_name Keyframe

signal keyframeChanged
#DATA
export (float) var time #in seconds
export var absolute = true #absolute or relative
export var value = 0 

export var curve: Curve = Curve.new() 

#PLAYBACK
var startingValue

#EDITING
var oldZoomX
var oldScrollX

func _init():
	add_to_group("keyframe")
	
func _ready():	
	connect("item_rect_changed", self, "rect_changed")
	time = rect_position.x / TimelineEditor.zoom.x -  TimelineEditor.scroll.x
	if !TimelineEditor.is_connected("zoomChanged", self, "rect_changed"):
		TimelineEditor.connect("zoomChanged", self, "rect_changed")

func rect_changed():
	if self.time == rect_position.x / TimelineEditor.zoom.x -  TimelineEditor.scroll.x:
		return
	
	if oldZoomX == TimelineEditor.zoom.x and oldScrollX == TimelineEditor.scroll.x:
		self.time =  rect_position.x / TimelineEditor.zoom.x -  TimelineEditor.scroll.x
		TimelineEditor.keyframeChanged()
		return
	else:
		rect_position.x =  self.time * TimelineEditor.zoom.x - TimelineEditor.scroll.x
		oldScrollX = TimelineEditor.scroll.x
		oldZoomX = TimelineEditor.zoom.x
		if rect_position.y != 5:
			set_deferred("rect_position",Vector2(rect_position.x, 5))	
