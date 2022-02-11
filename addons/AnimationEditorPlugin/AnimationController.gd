extends Node
class_name AnimationController

func play(who):
	get_node(who).play()
	
func stop(who):	
	if who:		
		get_child(who).stop()
	else:		
		for child in get_children():
			child.stop()
