extends Control
var tracks: Array

func _ready():
	if !is_in_group("AnimationCollection"):
		add_to_group("AnimationCollection")	
	tracks = get_children()
	for i in tracks.size():
		tracks[i].rect_position.y = i * 21
