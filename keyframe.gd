extends ColorRect
class_name Keyframe

enum ValueTypes {
	Bool, Float, Vec2, Vec3, Vec4, Res #resource
}

#DATA
export var time:float # in seconds
export var absolute = true #absolute or relative

export (ValueTypes) var type = ValueTypes.Float

export var curve: Curve = Curve.new() 

#VISUALSATION


func _ready():
	connect("item_rect_changed", self, "rect_changed")
	rect_position.x = time * 20
	

func rect_changed():
	if !aes.AnimationEditor: return
	time = rect_position.x / 20	
	aes.AnimationEditor.emit_signal("keyframeChanged")
	#rect_position.y = 5
	#rect_position.x = time * 20
	
