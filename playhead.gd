extends ColorRect

func _ready():
	aes.connect("frameChanged", self, "updatePosition")
	
func updatePosition(position):
	rect_position.x = position * 100
