extends Control
class_name Draggable, "move_icon.png"

# This component makes it's parent draggable, resizeable, and deleteable

var resizing = false
var moving = false
var renaming = false

export var canResizeX = true
export var canResizeY = true
export var canMoveX = true
export var canMoveY = true
export var canReceiveDrop = true
export var canBeDragged = true
export var canClose = true

export var minWidth = 60
export var minHeight = 60

export (NodePath) var resizeHandle
export (NodePath) var moveHandle

var parent
var closeButton:Button

var small = false

func _ready():			
	parent = get_parent()
	
	if has_node(resizeHandle):
		resizeHandle = get_node(resizeHandle)	
		resizeHandle.connect("gui_input", self, "resize")	
		
		
	if has_node(moveHandle):
		moveHandle = get_node(moveHandle)	
		moveHandle.mouse_filter = MOUSE_FILTER_STOP
		moveHandle.connect("gui_input", self, "click")		
		
				
	add_to_group("draggable")	
	
	parent.add_user_signal("startMoveResize")
	parent.add_user_signal("endMoveResize")	
	parent.add_user_signal("doRemove")
	
	parent.connect("resized", self, "validate_size")
	parent.connect("doRemove", self, "doRemove")	
	
	grow_parent_as_needed()	
	
	#Create a close button
	if canClose && !closeButton:
		closeButton = Button.new()			
		closeButton.text = "X"		
		closeButton.rect_scale = Vector2(0.75, 0.65)	
		closeButton.visible = false		
		parent.call_deferred("add_child", closeButton)		
		closeButton.set_anchors_and_margins_preset(Control.PRESET_TOP_RIGHT)
		closeButton.margin_top = 2
		closeButton.margin_left -= 3
		closeButton.margin_right -= 3
		closeButton.margin_bottom = -2
		closeButton.call_deferred("connect", "pressed", parent, "emit_signal", ["doRemove"])
		#connect("pressed", self, "doRemove")
		#Show [X] (close button) only when the mouse is over the move handle
		moveHandle.connect("mouse_entered", self, "showCloseButton")
		moveHandle.connect("mouse_exited", self, "showCloseButton")

#called automatically via signals / groups
func doRemove():	
	parent.get_parent().call_deferred("remove_child", parent)	
	
func showCloseButton():	
	if Rect2(moveHandle.rect_global_position, moveHandle.rect_size).has_point(get_global_mouse_position()):
		closeButton.visible = true		
	else:
		closeButton.visible = false

#called when you click on the move handle
func click(event:InputEvent):	
	if event as InputEventMouseButton:				
		if event.button_index == 1 and !event.is_pressed():
			if moving:
				get_tree().call_group("draggable", "endMove")				
		if event.button_index == 1 and event.is_pressed():			
			egs.selectionController.interrupt()		
			if !get_tree().get_nodes_in_group("selected").has(parent):
				if Input.is_key_pressed(KEY_SHIFT):
					get_tree().call_group("selectable", "doSelect")
				else:
					get_tree().call_group("selectable", "select_one", parent)
			get_tree().call_group("draggable", "startMove")			
		
#called when you click on the resize handle
func resize(event):
	if !canResizeX && !canResizeY:		
		return	
	if event as InputEventMouseButton && event.button_index == 1:		
		#on Mouse Down...
		if event.is_pressed():			
			if !get_tree().get_nodes_in_group("selected").has(parent):
				if Input.is_key_pressed(KEY_SHIFT):
					get_tree().call_group("selectable", "doSelect")
				else:
					get_tree().call_group("selectable", "select_one", parent)
			get_tree().call_group("draggable", "startResizing")
			egs.selectionController.interrupt()	#interrupt the selection controller because we're actually resizing, not selecting
		#on Mouse Up...	
		else:
			get_tree().call_group("draggable", "endResizing")

#startResizing, endResizing, startMove, and endMove are all called via get_tree().call_group() from elsewhere
func startResizing():	
	if parent.is_in_group("selected"):
		parent.emit_signal("startMoveResize", parent.get_rect())		
		resizing = true
		
func endResizing():
	parent.emit_signal("endMoveResize")
	resizing = false


func startMove():
	if parent.is_in_group("selected"):
		if canMoveX || canMoveY:
			parent.emit_signal("startMoveResize", parent.get_rect())		
			moving = true							
			#g.undo.add({"Type": "Move", "Who": parent, "Rect": parent.get_rect()})
	
func endMove():
	moving = false
	parent.emit_signal("endMoveResize")

func _input(event):
	if event is InputEventMouseMotion:
		if resizing:		
			if canResizeX:
				parent.rect_size.x = max(parent.rect_size.x+event.relative.x, minWidth) 				
			if canResizeY:
				parent.rect_size.y = max(parent.rect_size.y+event.relative.y, minHeight) 
			grow_parent_as_needed()		
			validate_size()	
		elif moving:
			if canMoveX:
				parent.rect_position.x += event.relative.x				
			if canMoveY:
				parent.rect_position.y += event.relative.y
			grow_parent_as_needed()
			
	if Input.is_key_pressed(KEY_DELETE):
		if parent.is_in_group("selected"):			
			parent.emit_signal("doRemove")
			
# As we move/resize, adjust the parent so that we are always completely inside our parent 
# ie. push the parent's boundaries as needed
# p.s. parent = this component's parent, and par is technically the grandparent
func grow_parent_as_needed():
	if !parent.get_parent().has_node("Draggable"):			
		return
	var par:Control = parent.get_parent()
	var parRect = Rect2(par.rect_global_position, par.rect_size)
	var myRect = Rect2(parent.rect_global_position, parent.rect_size)
	if !parRect.encloses(myRect):
		var newRect = parRect.merge(myRect) #.grow(1)
				
		#if the parent is growing to the left or upward, adjust the childrens position accordingly
		var deltaX = par.rect_global_position.x - newRect.position.x 		
		var deltaY = par.rect_global_position.y - newRect.position.y		
		if deltaY > 0 or deltaX > 0:
			for c in par.get_children():			
				if c.has_node("Draggable"):											
					c.rect_global_position.x += (deltaX ) 
					c.rect_global_position.y += (deltaY )					
		par.rect_global_position = newRect.position
		par.rect_size = newRect.size	

# Hide the children if we're too small
func validate_size():
	if parent.rect_size.x < minWidth or parent.rect_size.y < minHeight:
		becomeSmall()
	else:
		becomeBig()
		
func becomeSmall():
	if !small:
		for c in parent.get_children():
			if c as Control:
				c.visible = false
		moveHandle.visible = true
		small = true

func becomeBig():
	if small:
		for c in parent.get_children():
			if c as Control:
				c.visible = true		
		small = false
			
	
		
		
	
