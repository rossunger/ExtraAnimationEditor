tool
extends ColorRect
class_name Keyframe

signal keyframeChanged()
#DATA
export (float) var time #in seconds
export var absolute = true #absolute or relative
export var value = 0 

export var curve: Curve = Curve.new() 

#PLAYBACK
var startingValue

func _init():
	add_to_group("keyframe")
	
func _ready():	
	connect("item_rect_changed", self, "rect_changed")
	time = rect_position.x / TimelineEditor.zoom.x
	if !TimelineEditor.is_connected("zoomChanged", self, "rect_changed"):
		TimelineEditor.connect("zoomChanged", self, "rect_changed")

func rect_changed():
	self.time = rect_position.x / TimelineEditor.zoom.x
	if rect_position.y != 5:
		set_deferred("rect_position",Vector2(rect_position.x, 5))
	property_list_changed_notify()		
