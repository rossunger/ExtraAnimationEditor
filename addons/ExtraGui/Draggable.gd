tool
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

export (NodePath) var resizeHandlePath
export (NodePath) var moveHandlePath
var moveHandle
var resizeHandle

var parent
var closeButton:Button

var small = false

func _enter_tree():
	if Engine.editor_hint:
		_ready()
		
func _ready():				
	if has_node(resizeHandlePath) and !resizeHandle:
		resizeHandle = get_node(resizeHandlePath)	
		resizeHandle.connect("gui_input", self, "resize")	
		
		
	if has_node(moveHandlePath) and !moveHandle:
		moveHandle = get_node(moveHandlePath)	
		moveHandle.mouse_filter = MOUSE_FILTER_STOP
		if !moveHandle.is_connected("gui_input", self, "click"):
			moveHandle.connect("gui_input", self, "click")		
		
				
	add_to_group("draggable")	
	
	if !getParent().has_user_signal("startMoveResize"):
		getParent().add_user_signal("startMoveResize")
	if !getParent().has_user_signal("endMoveResize"):
		getParent().add_user_signal("endMoveResize")	
	if !getParent().has_user_signal("doRemove"):
		getParent().add_user_signal("doRemove")
	
	#if !getParent().is_connected("resized", self, "validate_size"):
	#	getParent().connect("resized", self, "validate_size")
	if !getParent().is_connected("doRemove", self, "doRemove"):
		getParent().connect("doRemove", self, "doRemove")	
	
	#grow_parent_as_needed()	
	
	#Create a close button
	if canClose && !closeButton:
		closeButton = Button.new()			
		closeButton.text = "X"		
		closeButton.rect_scale = Vector2(0.75, 0.65)	
		closeButton.visible = false		
		getParent().call_deferred("add_child", closeButton)		
		closeButton.set_anchors_and_margins_preset(Control.PRESET_TOP_RIGHT)
		closeButton.margin_top = 2
		closeButton.margin_left -= 3
		closeButton.margin_right -= 3
		closeButton.margin_bottom = -2
		closeButton.call_deferred("connect", "pressed", getParent(), "emit_signal", ["doRemove"])
		#connect("pressed", self, "doRemove")
		#Show [X] (close button) only when the mouse is over the move handle
		moveHandle.connect("mouse_entered", self, "showCloseButton")
		moveHandle.connect("mouse_exited", self, "showCloseButton")

#called automatically via signals / groups
func doRemove():	
	getParent().get_parent().call_deferred("remove_child", getParent())	
	
func showCloseButton():	
	if Rect2(moveHandle.rect_global_position, moveHandle.rect_min_size).has_point(get_global_mouse_position()):
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
			if is_instance_valid(egs.selectionController):
				egs.selectionController.interrupt()		
			if !get_tree().get_nodes_in_group("selected").has(getParent()):
				if Input.is_key_pressed(KEY_SHIFT):
					get_tree().call_group("selectable", "doSelect")
				else:
					get_tree().call_group("selectable", "select_one", getParent())
			get_tree().call_group("draggable", "startMove")			
		
#called when you click on the resize handle
func resize(event):	
	if !canResizeX && !canResizeY:		
		return		
	if event as InputEventMouseButton && event.button_index == 1:		
		#on Mouse Down...
		if event.is_pressed():			
			if !get_tree().get_nodes_in_group("selected").has(getParent()):
				if Input.is_key_pressed(KEY_SHIFT):
					get_tree().call_group("selectable", "doSelect")
				else:
					get_tree().call_group("selectable", "select_one", getParent())
			get_tree().call_group("draggable", "startResizing")
			egs.selectionController.interrupt()	#interrupt the selection controller because we're actually resizing, not selecting
		#on Mouse Up...	
		else:
			get_tree().call_group("draggable", "endResizing")

#startResizing, endResizing, startMove, and endMove are all called via get_tree().call_group() from elsewhere
func startResizing():	
	if getParent().is_in_group("selected"):
		getParent().emit_signal("startMoveResize", getParent().get_rect())		
		resizing = true
		
func endResizing():
	getParent().emit_signal("endMoveResize")
	resizing = false


func startMove():
	if getParent().is_in_group("selected"):
		if canMoveX || canMoveY:
			getParent().emit_signal("startMoveResize", getParent().get_rect())		
			moving = true							
			#g.undo.add({"Type": "Move", "Who": parent, "Rect": parent.get_rect()})
	
func endMove():
	moving = false
	getParent().emit_signal("endMoveResize")

func _input(event):
	if event is InputEventMouseMotion:
		if resizing:		
			if canResizeX:
				getParent().rect_min_size.x = max(getParent().rect_min_size.x+event.relative.x, minWidth) 				
			if canResizeY:
				print("resizing Y")
				getParent().rect_min_size.y = max(getParent().rect_min_size.y+event.relative.y, minHeight) 
			grow_parent_as_needed()		
			validate_size()	
		elif moving:
			if canMoveX:
				getParent().rect_position.x += event.relative.x				
			if canMoveY:
				getParent().rect_position.y += event.relative.y
			grow_parent_as_needed()
			
	if Input.is_key_pressed(KEY_DELETE):
		if getParent().is_in_group("selected"):			
			getParent().emit_signal("doRemove")
			
# As we move/resize, adjust the parent so that we are always completely inside our parent 
# ie. push the parent's boundaries as needed
# p.s. parent = this component's parent, and par is technically the grandparent
func grow_parent_as_needed():
	if !getParent().get_parent().has_node("Draggable"):			
		return
	var par:Control = getParent().get_parent()
	var parRect = Rect2(par.rect_global_position, par.rect_min_size)
	var myRect = Rect2(getParent().rect_global_position, getParent().rect_min_size)
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
		par.rect_min_size = newRect.size	

# Hide the children if we're too small
func validate_size():
	if getParent().rect_min_size.x < minWidth or getParent().rect_min_size.y < minHeight:
		becomeSmall()
	else:
		becomeBig()
		
func becomeSmall():
	if !small:
		for c in getParent().get_children():
			if c as Control:
				c.visible = false
		moveHandle.visible = true
		small = true

func becomeBig():
	if small:
		for c in getParent().get_children():
			if c as Control:
				c.visible = true		
		small = false
		
func getParent():
	if !is_instance_valid(parent):
		parent = get_parent()
	return parent
	

		
		
	
