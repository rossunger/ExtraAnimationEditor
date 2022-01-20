tool
extends Panel
class_name Track

export (Array, String) var Parameters

func _init():
	#rect_size = Vector2(1000, 20)	
	if !is_in_group("AnimationTracks"):
		add_to_group("AnimationTracks")
