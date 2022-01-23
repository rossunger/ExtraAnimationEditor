tool
extends ColorRect
class_name Keyframe


#DATA
export (float) var time  #in seconds
export var absolute = true #absolute or relative
export var value = 0

export var curve: Curve = Curve.new() 

#PLAYBACK
var startingValue


func _ready():
	add_to_group("keyframe")
	connect("item_rect_changed", self, "rect_changed")
	time = rect_position.x /20

func rect_changed():
	time = rect_position.x /20
	if rect_position.y != 5:
		set_deferred("rect_position",Vector2(rect_position.x, 5))
	property_list_changed_notify()

