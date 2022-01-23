extends BaseButton
class_name OpacityButton
export var opacityNormal = 0.35
export var opacityHover = 0.8

func _ready():
	connect("mouse_entered", self, "mouse_entered")
	connect("mouse_exited", self, "mouse_exited")
	modulate.a = opacityNormal	
	
func mouse_entered():
	modulate.a = opacityHover

func mouse_exited():
	modulate.a = opacityNormal		
