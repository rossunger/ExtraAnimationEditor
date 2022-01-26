tool
extends ColorRect
class_name Keyframe

signal keyframeChanged()
#DATA
export (float) var time setget setTime #in seconds
export var absolute = true setget setAbsolute #absolute or relative
export var value = 0 setget setValue

export var curve: Curve = Curve.new() setget setCurve

#PLAYBACK
var startingValue

func setTime(newValue):
	time = newValue
	if is_inside_tree():
		get_tree().call_group("AnimationEditorPlugin", "editKeyframe", {"key": self, "time": time})
func setValue(newValue):
	value = newValue
	if is_inside_tree():
		get_tree().call_group("AnimationEditorPlugin", "editKeyframe", {"key": self, "value": value})
func setAbsolute(newValue):
	absolute = newValue
	if is_inside_tree():
		get_tree().call_group("AnimationEditorPlugin", "editKeyframe", {"key": self, "absolute": absolute})
func setCurve(newValue):
	curve = newValue
	if is_inside_tree():
		get_tree().call_group("AnimationEditorPlugin", "editKeyframe", {"key": self, "curve": curve})

func _init():
	add_to_group("keyframe")
	
func _ready():	
	connect("item_rect_changed", self, "rect_changed")
	time = rect_position.x /20

func rect_changed():
	self.time = rect_position.x /20
	if rect_position.y != 5:
		set_deferred("rect_position",Vector2(rect_position.x, 5))
	property_list_changed_notify()		
