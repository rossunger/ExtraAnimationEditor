tool
extends Control

var resizing =false

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			resizing = true
		else: 
			resizing = false
		
func _input(event):
	if event is InputEventMouseMotion and resizing:
		get_parent().rect_min_size.y += event.relative
	
