tool
extends Button

var stopIcon = preload("res://icons/icon_stop.svg")
var playIcon = preload("res://icons/icon_play.svg")

func _on_PlayButton_pressed():	
	if pressed:		
		icon = stopIcon						
		#get_tree().call_group("AnimationEditorPlugin", "play")
	else:		
		icon = playIcon
		#get_tree().call_group("AnimationEditorPlugin", "stop")

