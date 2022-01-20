extends Control
var tracks: Array
export var duration = 1

func _ready():	
	if !is_in_group("AnimationCollection"):
		add_to_group("AnimationCollection")	
	tracks = get_children()
	var offset = 0
	for track in tracks:
		if track.is_in_group("AnimationTracks"): 			
			track.rect_position.y = offset * 36
			offset +=1 
				 
