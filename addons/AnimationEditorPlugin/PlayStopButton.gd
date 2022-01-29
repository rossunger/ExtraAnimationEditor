tool
extends Button

var stopIcon = preload("res://icons/icon_stop.svg")
var playIcon = preload("res://icons/icon_play.svg")

func _enter_tree():
	if not TimelineEditor.is_connected("animationChanged", self, "animationChanged"):
		 TimelineEditor.connect("animationChanged", self, "animationChanged")
func animationChanged():
	if not TimelineEditor.animation.is_connected("play", self, "play"):
		TimelineEditor.animation.connect("play", self, "play")
	if not TimelineEditor.animation.is_connected("stop", self, "stop"):
		TimelineEditor.animation.connect("stop", self, "stop")
	
func play():
	pressed = true	
	_on_PlayButton_pressed()
	
func stop():
	print("stopping playbutton")
	pressed = false
	_on_PlayButton_pressed()

func _on_PlayButton_pressed():	
	if pressed:		
		icon = stopIcon						
		#get_tree().call_group("AnimationEditorPlugin", "play")
	else:		
		icon = playIcon
		#get_tree().call_group("AnimationEditorPlugin", "stop")

