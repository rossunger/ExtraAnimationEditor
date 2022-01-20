extends ColorRect
class_name Keyframe

enum ValueTypes {
	Bool, Float, Vec2, Vec3, Vec4, Res #resource
}

#DATA
export var time:float setget timeChanged # in seconds
export var absolute = true setget absoluteChanged #absolute or relative

export (ValueTypes) var type = ValueTypes.Float

export var curve: Curve = Curve.new() 

#VISUALSATION


func _ready():
	connect("item_rect_changed", self, "rect_changed")
	rect_position.x = time * 20
	

func rect_changed():
	if is_inside_tree():
		time = rect_position.x / 20	
		aes.emit_signal("animationChanged")
	#rect_position.y = 5
	#rect_position.x = time * 20
	
func timeChanged(newtime):	
	if !time == newtime:
		time = newtime
	if is_inside_tree():
		aes.emit_signal("animationChanged")
	
func absoluteChanged(newvalue):
	if !absolute == newvalue:
		absolute = newvalue
	if is_inside_tree():		
		aes.emit_signal("animationChanged")
	
