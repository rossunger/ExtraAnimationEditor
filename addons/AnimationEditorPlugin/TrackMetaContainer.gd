tool
extends Control

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.doubleclick:		
			get_parent().addTrack()
