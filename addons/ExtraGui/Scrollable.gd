extends Control
class_name Scrollable, "move_icon.png"

# This component makes the parent a scrollbox, allowing you to scroll it's children, and zoom in and out

export var canScrollX = true
export var canScrollY = true
export var canZoomX = true
export var canZoomY = true
export var onlyDraggables = true 

var bounds: Rect2
var x = 0
var y = 0
var w = 1
var h = 1
export var scroll_speed = 20
export var zoom_speed = 0.1

var parent #the actual Control that will be scrolled 

func _ready():	
	parent = get_parent()			
	if !parent as Control:
		queue_free()
	
func doScroll(delta):
	x += delta.x
	y += delta.y
	for c in parent.get_children():
		if onlyDraggables && !c.has_node("Draggable"):
			continue
		if c is Control:
			c.rect_position += delta


#Recursively zoom the children, but only if they have a "draggable" node
#This allows you to zoom without affecting the size of labels, etc. 
func doZoom(par, delta):	
	for c in par.get_children():		
		if c is Control && c.visible && c.has_node("Draggable"):			
			if canZoomX:
				c.rect_size.x *= delta 
				c.rect_position.x *=delta				
			if canZoomY:
				c.rect_size.y *= delta 
				c.rect_position.y *=delta				
																	
			#recursive zoom all the children
			doZoom(c, delta)			
	
func _input(event):		
	if !is_visible_in_tree():
		return
		
	#Frame all draggables so you can see them (i.e. zoom out/in and scroll as needed so that the bounding box of all the draggales combines is equal to the screen size)
	if Input.is_key_pressed(KEY_F) && Input.is_key_pressed(KEY_ALT):
		
		#Step 1: get the biggest bounding box of all this "scrollables" children combined
		bounds = getBounds()
		
		#Step 2: calculate how much we need to zoom
		var delta = bounds.size		
		var d = min(parent.rect_size.x/delta.x, parent.rect_size.y/ delta.y)
		
		#Step 3: Zoom and Pan
		doScroll(-bounds.position + Vector2(1,1))		
		doZoom(parent, d)		
		
	#mousehweel = scroll
	#Control + mousewheel = zoom		
	if event is InputEventMouseButton:		
		if Input.is_key_pressed(KEY_CONTROL):
			if event.button_index == BUTTON_WHEEL_UP && canZoomX:							
				doZoom(parent, 1 + zoom_speed)				
				doScroll( ( -event.position) / scroll_speed )
			if event.button_index == BUTTON_WHEEL_DOWN && canZoomX:				
				doZoom(parent, 1 - zoom_speed)
				doScroll( ( event.position) / scroll_speed )
		else:
			if event.button_index == BUTTON_WHEEL_RIGHT && canScrollX:
				doScroll(Vector2(0-scroll_speed,0))			
			if event.button_index == BUTTON_WHEEL_LEFT && canScrollX:
				doScroll(Vector2(scroll_speed,0))		
			if event.button_index == BUTTON_WHEEL_UP && canScrollY:
				doScroll(Vector2(0,scroll_speed))			
			if event.button_index == BUTTON_WHEEL_DOWN && canScrollY:
				doScroll(Vector2(0,0-scroll_speed))	

#Gets the biggeset bounding box of all the parent's children
func getBounds() -> Rect2:
	var topleft
	var bottomright
	for c in parent.get_children():
		if c.has_node("Draggable"):
			if !topleft:
				topleft = c.rect_global_position
			if !bottomright:
				bottomright = c.rect_global_position + c.rect_size
			topleft.x = min(topleft.x, c.rect_global_position.x)
			topleft.y = min(topleft.y, c.rect_global_position.y)				
			bottomright.x = max(bottomright.x, c.rect_global_position.x + c.rect_size.x )
			bottomright.y = max(bottomright.y, c.rect_global_position.y + c.rect_size.y )			
	return Rect2(topleft, bottomright-topleft)
		
