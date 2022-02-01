tool
extends Node
class_name Scrollable

var x = 0
var y = 0
var w = 1
var h = 1
export var scroll_speed = 20
export var zoom_speed = 0.1

var parent #the actual Control that will be scrolled 

func _ready():	
	parent = get_parent()			
	if !parent is Control:
		queue_free()
	
func doScroll(delta):
	x += delta.x
	y += delta.y
	for c in parent.get_children():
		if c is Control:
			c.rect_position += delta


#Recursively zoom the children, but only if they have a "draggable" node
#This allows you to zoom without affecting the size of labels, etc. 
func doZoom(par, delta):	
	for c in par.get_children():								
		c.rect_size.y *= delta 
		c.rect_position.y *=delta				
																
		#recursive zoom all the children
		doZoom(c, delta)			
	
func _input(event):			
	if event is InputEventMouseButton:		
		if event.button_index == BUTTON_WHEEL_UP:							
			if Input.is_key_pressed(KEY_CONTROL):
				doZoom(parent, 1 + zoom_speed)				
			else:
				doScroll(Vector2(0,scroll_speed))						
		elif event.button_index == BUTTON_WHEEL_DOWN:				
			if Input.is_key_pressed(KEY_CONTROL):
				doZoom(parent, 1 + zoom_speed)				
			else:
				doScroll(Vector2(0,scroll_speed))			
