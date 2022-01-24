
# Overlay for 2d viewport
tool
extends EditorPlugin

var animations = []

var obj: Node
var objectAtMouse = null
var hover = null
var dragging=null
var dragStartX = null
var drawGrid = false
var toolsScene = preload("interface.tscn")
var tools
var interface

func _enter_tree():
	var animations = get_tree().get_nodes_in_group("animations")		
	interface = get_editor_interface()
	if !get_tree().is_connected("node_added", self, "node_added"):
		get_tree().connect("node_added", self, "node_added", [], CONNECT_PERSIST)
	if !get_tree().is_connected("node_removed", self, "node_removed"):
		get_tree().connect("node_removed", self, "node_removed", [], CONNECT_PERSIST)	
	#tools = toolsScene.instance()	
	#add_control_to_bottom_panel(tools, "AnimationEditor")

func _exit_tree():
	if get_tree().is_connected("node_added", self, "node_added"):
		get_tree().disconnect("node_added", self, "node_added")
	if get_tree().is_connected("node_removed", self, "node_removed"):
		get_tree().disconnect("node_removed", self, "node_removed")	
	#remove_control_from_bottom_panel(tools)

func node_added(node):
	if !animations.has(node) and node is ExtraAnimation and str(node.get_path()).find("/context/") == -1:
		animations.push_back(node)		
		print(animations.size())

func node_removed(node):
	if animations.has(node):
		animations.erase(node)
		
func edit(object: Object) -> void:	
	#print("edit %s" % object.get_path())
	obj = object	
	"""
	if object is ExtraAnimation:				
		if !is_instance_valid(tools):
			tools = toolsScene.instance()	
		if !tools.is_inside_tree():
			get_editor_interface().get_edited_scene_root().add_child(tools)										
	else:
		if is_instance_valid(tools) and tools.is_inside_tree():			
			get_editor_interface().get_edited_scene_root().remove_child(tools)		
	"""
func make_visible(visible: bool) -> void:	
	# Called when the editor is requested to become visible.
	if not obj:
		return
	if not visible:
		obj = null
	
	update_overlays()

func handles(object: Object) -> bool:
	# Required to use forward_canvas_draw_... below		
	return object is Keyframe or object is Track or object is ExtraAnimation


func forward_canvas_draw_over_viewport(overlay: Control) -> void:
	if obj and obj is Keyframe:
		overlay.draw_rect(getRect(obj), Color.dodgerblue, false, 4)  
	if hover && obj != objectAtMouse:
		overlay.draw_rect(getRect(objectAtMouse), Color.goldenrod, false, 4) 
		
func forward_canvas_gui_input(event: InputEvent) -> bool:
	
	#if not obj or not obj.visible:
	#	return false

	# Clicking and releasing the click
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and objectAtMouse:
		var undo := get_undo_redo()
		if event.is_pressed():
			get_editor_interface().get_selection().clear()
			get_editor_interface().get_selection().add_node(objectAtMouse)
			dragging = objectAtMouse		
			dragStartX = objectAtMouse.rect_position.x						
			return true
		else:
			undo.create_action("Drag keyframe")		
			undo.add_do_property(dragging, "rect_position", dragging.rect_position)
			undo.add_undo_property(dragging, "rect_position", Vector2(dragStartX, dragging.rect_position.y))	
			undo.commit_action()
			dragging = null	
			dragStartX = null									
			return true
	# Dragging
	if event is InputEventMouseMotion:		
		if dragging:
			dragging.rect_position.x += event.relative.x / max(getZoom(dragging).x, 0.01)
			return true
		for node in get_tree().get_nodes_in_group("keyframe"):			
			if getRect(node).has_point(event.position):									
				objectAtMouse = node
				hover =true
				#do drag then update
				update_overlays()
				return true	
		hover =false	
		objectAtMouse = null
						
	# Cancelling with ui_cancel
	if event.is_action_pressed("ui_cancel"):		
		return true
	return false

func getRect(node):
	var transform_viewport = node.get_viewport_transform()			
	var transform_global = node.get_canvas_transform()
	var pos = Vector2(transform_viewport * (transform_global * node.rect_global_position))
	var scale = node.rect_size * transform_viewport.get_scale() * transform_global.get_scale()
	return Rect2(pos, scale)		

func getZoom(node):
	return node.get_viewport_transform().get_scale() * node.get_canvas_transform().get_scale()
