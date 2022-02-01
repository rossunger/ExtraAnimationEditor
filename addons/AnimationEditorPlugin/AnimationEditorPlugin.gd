tool
extends EditorPlugin

var animations = []
var currentAnimation
var objectAtMouse = null
var hover = null
var dragging=null
var dragStartX = null
var drawGrid = false
var timelineEditor
var timelineEditorParent
var timelineButton
var debug
	

	
var previewContainer = Control.new()
var contextCanvas

var previousMainScreen = null


#var objectSelectorScene = preload("res://addons/AnimationEditorPlugin/ObjectPicker.tscn")
#var propertySelectorScene = preload("res://addons/AnimationEditorPlugin/PropertyPicker.tscn")
############################
##PLUGIN RELATED FUNCTIONS##
############################
func has_main_screen():
	return true	
func get_plugin_name():
	return "Animation"

func _enter_tree():	
		
	##REGISTER MAIN SCREEN
	get_editor_interface().get_editor_viewport().add_child(previewContainer)	
	if !is_in_group("AnimationEditorPlugin"):
		add_to_group("AnimationEditorPlugin")	
	
	add_autoload_singleton("TimelineEditor", "res://addons/AnimationEditorPlugin/TimelineEditor.tscn")	
	#add_autoload_singleton("debug", "res://addons/AnimationEditorPlugin/DebugPanel.tscn")	
	add_autoload_singleton("inputManager", "res://addons/AnimationEditorPlugin/InputManager.gd")	
	
	
	#call_deferred("initTimeline")
	
	
func initTimeline(timeline):
	if is_instance_valid(timelineEditor):		
		return
	timelineEditor = timeline
	timelineEditorParent = timelineEditor.get_parent()
	timelineEditorParent.remove_child(timelineEditor)	
	timelineButton = add_control_to_bottom_panel(timelineEditor, "Timeline")
	timelineEditor.rect_position = Vector2(0,0)		
	
func initDebug(who):
	if is_instance_valid(debug):
		return
	debug = who
	debug.get_parent().remove_child(debug)	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, debug)
	debug.show()
	
func _exit_tree():		
	#UNREGISTER MAIN SCREEN
	previewContainer.queue_free()	
			
	if is_instance_valid(timelineEditor):		
		remove_control_from_bottom_panel(timelineEditor)
		timelineEditorParent.add_child(timelineEditor)
		#timelineEditor.queue_free()
		remove_autoload_singleton("TimelineEditor")
	else:
		print("NO TIMELINE EDITOR")
		
	if is_instance_valid(debug):		
		remove_control_from_docks(debug)	
		debug.add_child(debug)
		remove_autoload_singleton("debug")
	
	remove_autoload_singleton("inputManager")
		
func make_visible(visible: bool) -> void:
	if is_instance_valid(previewContainer):		
		previewContainer.show()
	update_overlays()	
	

func handles(object: Object) -> bool:		
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	if selection.size() == 1:	
		if timelineEditor.handleSelection(selection[0]):			
			var s = get_current_main_screen_name() 
			if s != "Animation": previousMainScreen = s
			get_editor_interface().call_deferred("set_main_screen_editor", "Animation")			
			timelineButton.pressed = true
			#LOAD ANIMATION DATA
			currentAnimation = selection[0]		
			timelineEditor.setAnimation(currentAnimation)					
			if File.new().file_exists(timelineEditor.animation.defaultPreviewScene):
				loadPreviewFromFile(timelineEditor.animation.defaultPreviewScene)
			else:
				print("context file doesn't exist: ", currentAnimation.name, " : ", currentAnimation.defaultPreviewScene)
			return true	
	if previousMainScreen:		
		get_editor_interface().call_deferred("set_main_screen_editor", previousMainScreen)
		previousMainScreen = null
	
	if is_instance_valid(currentAnimation):		
		currentAnimation = null
	if is_instance_valid(timelineEditor):	
		timelineEditor.clearAnimation() #clearAnimation()
	clearPreview()	
	return false

################################
#### ANIMATION RELATED FUNCTIONS
################################

func newAnimation():	
	timelineEditor.newAnimation(get_editor_interface().get_edited_scene_root())	
	
func saveChanges(anim):
	var packedScene = PackedScene.new()	
	packedScene.pack(anim) 	
	#packedScene.owner = get_editor_interface().get_edited_scene_root()
	ResourceSaver.save(anim.filename, packedScene)
	get_editor_interface().get_edited_scene_root().property_list_changed_notify()	
	#get_editor_interface().reload_scene_from_path(anim.filename)
	
func changeContext():		
	var dialog: FileDialog	
	if !is_instance_valid(contextCanvas):
		contextCanvas = CanvasLayer.new()
		contextCanvas.layer = 100
		previewContainer.add_child(contextCanvas)	
	dialog = FileDialog.new()
	dialog.mode = FileDialog.MODE_OPEN_FILE
	dialog.invalidate()
	contextCanvas.add_child(dialog)
	dialog.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	dialog.add_filter("*.tscn ; PackedScene")
	dialog.connect("file_selected", self, "loadPreviewFromFile")
	dialog.popup()	
	
func clearPreview():
	for child in previewContainer.get_children():		
		child.queue_free()
		
func loadPreviewFromFile(path):			
	var newScene = load(path).instance()
	loadPreview(newScene)
	timelineEditor.previewContextChanged(path)

#I dont think we do this anymore...
func loadPreviewFromScene(obj):	
	var p = PackedScene.new()
	p.pack(obj)
	loadPreview(p.instance())

func loadPreview(obj):
	clearPreview()
	previewContainer.add_child(obj)
	timelineEditor.animation.currentScene = obj
	get_editor_interface().set_main_screen_editor("Animation")	

func getRect(node):
	var transform_viewport = node.get_viewport_transform()			
	var transform_global = node.get_canvas_transform()
	var pos = Vector2(transform_viewport * (transform_global * node.rect_global_position))
	var scale = node.rect_size * transform_viewport.get_scale() * transform_global.get_scale()
	return Rect2(pos, scale)		

func getZoom(node):
	return node.get_viewport_transform().get_scale() * node.get_canvas_transform().get_scale()

func editKeyframe(data):
	if "time" in data:		
		#data.key.get_pa
		pass	
	if "value" in data:
		pass
	if "absolute" in data:
		pass
	if "curve" in data:
		pass
		

func get_current_main_screen_name():
	var editor_base = get_editor_interface().get_base_control()
	if (!editor_base.is_inside_tree() || editor_base.get_child_count() == 0):
		return
	
	var editor_main_vbox
	for child_node in editor_base.get_children():
		if (child_node.get_class() == "VBoxContainer"):
			editor_main_vbox = child_node
			break
	if (!editor_main_vbox || !is_instance_valid(editor_main_vbox)):
		return
	if (editor_main_vbox.get_child_count() == 0):
		return
	
	var editor_menu_hb
	for child_node in editor_main_vbox.get_children():
		if (child_node.get_class() == "HBoxContainer"):
			editor_menu_hb = child_node
			break
	if (!editor_menu_hb || !is_instance_valid(editor_menu_hb)):
		return
	if (editor_menu_hb.get_child_count() == 0):
		return
	
	var match_counter = 0
	var editor_main_button_vb
	for child_node in editor_menu_hb.get_children():
		if (child_node.get_class() == "HBoxContainer"):
			match_counter += 1
		if (match_counter == 2):
			editor_main_button_vb = child_node
			break
	if (!editor_main_button_vb || !is_instance_valid(editor_main_button_vb)):
		return
	var main_screen_buttons = editor_main_button_vb.get_children()
	
	for button_node in main_screen_buttons:
		if !(button_node is ToolButton):
			continue
		if (button_node.pressed):
			return(button_node.text)			
