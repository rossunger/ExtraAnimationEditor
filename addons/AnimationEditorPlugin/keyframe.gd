tool
extends ColorRect
class_name Keyframe

signal keyframeChanged
#DATA
export (float) var time setget setTime #in seconds
export var relative = false #absolute or relative
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
	if not is_in_group("Keyframe"):
		add_to_group("Keyframe")

func rect_changed():
	if self.time == rect_position.x / TimelineEditor.zoom.x -  TimelineEditor.scroll.x:
		return
	
	if oldZoomX == TimelineEditor.zoom.x and oldScrollX == TimelineEditor.scroll.x:
		setTimeFromX()
		return
	else:
		setXFromTime()
		oldScrollX = TimelineEditor.scroll.x
		oldZoomX = TimelineEditor.zoom.x
		if rect_position.y != 5:
			set_deferred("rect_position",Vector2(rect_position.x, 5))	
			
func setTimeFromX():
	var newTime = rect_position.x / TimelineEditor.zoom.x -  TimelineEditor.scroll.x
	if TimelineEditor.snap > 0:		
		newTime = floor(newTime / TimelineEditor.snap) * TimelineEditor.snap #todo: fix snapping	
	self.time = max(0, newTime)
	TimelineEditor.keyframeChanged(self)
		
func setXFromTime():
	var newX = self.time * TimelineEditor.zoom.x - TimelineEditor.scroll.x
	if TimelineEditor.snap > 0:
		newX = floor(newX / TimelineEditor.snap) * TimelineEditor.snap
	rect_position.x = newX	
	
func setTime(newTime):
	time = newTime 
	setXFromTime()

func reparent(newParent):
	print(newParent.name)
	var currentParent = get_parent()
	if currentParent != newParent:
		currentParent.remove_child(self)
		newParent.add_child(self)
