
# Overlay for 2d viewport
tool
extends EditorPlugin

var animations = []
var currentAnimation
var objectAtMouse = null
var hover = null
var dragging=null
var dragStartX = null
var drawGrid = false
var tools
	
var toolsScene = preload("interface.tscn")
var TrackScene = preload("res://Track.tscn")
var KeyframeScene = preload("res://Keyframe.tscn")
var previewContainer = Control.new()
var contextCanvas

var previousMainScreen = null


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
	
	if !is_instance_valid(tools):
		tools = toolsScene.instance()	
	add_control_to_bottom_panel(tools, "Timeline")
	
func _exit_tree():
	#UNREGISTER MAIN SCREEN
	previewContainer.queue_free()
	
	if is_instance_valid(tools):
		remove_control_from_bottom_panel(tools)
		tools.queue_free()
		
func make_visible(visible: bool) -> void:
	if is_instance_valid(previewContainer):		
		previewContainer.show()
	update_overlays()	
	

func handles(object: Object) -> bool:	
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	if selection.size() == 1:				
		var obj = selection[0]
		if obj is Keyframe:
			obj = obj.get_parent().get_parent()
		if obj is Track:
			obj = obj.get_parent()			
		if obj is ExtraAnimation:
			var s = get_current_main_screen_name() 
			if s != "Animation": previousMainScreen = s
			get_editor_interface().call_deferred("set_main_screen_editor", "Animation")
			#LOAD ANIMATION DATA
			currentAnimation = obj
			tools.setAnimation(currentAnimation)
			if File.new().file_exists(currentAnimation.defaultPreviewScene):
				loadPreviewFromFile(currentAnimation.defaultPreviewScene)				
			return true	
	if previousMainScreen:
		print(previousMainScreen)			
		get_editor_interface().call_deferred("set_main_screen_editor", previousMainScreen)
		previousMainScreen = null
	
	if is_instance_valid(currentAnimation):		
		currentAnimation = null
	if is_instance_valid(tools):	
		tools.clearAnimation()
	clearPreview()	
	return false

################################
#### ANIMATION RELATED FUNCTIONS
################################

func newAnimation():	
	#TO DO:
	# - figure out how to instance a packed scene so it stays linked the original file			
	var newAnimation = ExtraAnimation.new()			
	newAnimation.name = "NewAnimation"
	var packedScene = PackedScene.new()
	packedScene.pack(newAnimation) 
	
	var path = "res://Animations/" + newAnimation.name + ".tscn"
	var file2Check = File.new()
	var i = 0
	if file2Check.file_exists(path):
		while file2Check.file_exists("res://Animations/" + newAnimation.name + "_" + str(i) + ".tscn"):		
			i += 1
		path = "res://Animations/" + newAnimation.name + "_" + str(i) + ".tscn"	
	ResourceSaver.save(path, packedScene)
	newAnimation.filename = path
	get_editor_interface().get_edited_scene_root().add_child(newAnimation)		
	newAnimation.owner = get_editor_interface().get_edited_scene_root()
	

func saveChanges(timeline):
	
		
	for track in currentAnimation.get_children():
		track.queue_free()
	for track in timeline.get_children():
		if !track is Track:
			continue
		track.get_parent().remove_child(track)
		currentAnimation.add_child(track)	
		track.owner = currentAnimation
		for child in track.get_children():
			child.owner = currentAnimation
			
	var packedScene = PackedScene.new()
	packedScene.pack(currentAnimation) 
	currentAnimation.owner = get_editor_interface().get_edited_scene_root()
	ResourceSaver.save(currentAnimation.filename, packedScene)
	
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

func loadPreviewFromScene(obj):	
	var p = PackedScene.new()
	p.pack(obj)
	loadPreview(p.instance())

func loadPreview(obj):
	clearPreview()
	previewContainer.add_child(obj)
	get_editor_interface().set_main_screen_editor("Animation")

func getRect(node):
	var transform_viewport = node.get_viewport_transform()			
	var transform_global = node.get_canvas_transform()
	var pos = Vector2(transform_viewport * (transform_global * node.rect_global_position))
	var scale = node.rect_size * transform_viewport.get_scale() * transform_global.get_scale()
	return Rect2(pos, scale)		

func getZoom(node):
	return node.get_viewport_transform().get_scale() * node.get_canvas_transform().get_scale()



func showTrackOptions():
	pass

func selectKeyframes(keys):
	get_editor_interface().get_selection().clear()
	for key in keys:
		get_editor_interface().get_selection().add_node(key)

func editKeyframe(data):
	if "time" in data:
		
		data.key.get_pa
		pass	
	if "value" in data:
		pass
	if "absolute" in data:
		pass
	if "curve" in data:
		pass
		

func addKeyframe(parent):
	var k = KeyframeScene.instance()
	parent.add_child(k)	
	k.owner = currentAnimation #get_editor_interface().get_edited_scene_root()	
	tools.setAnimation(currentAnimation)
	
func addTrack():
	var t = TrackScene.instance()	
	currentAnimation.add_child(t)	
	t.owner = currentAnimation #get_editor_interface().get_edited_scene_root()	
	tools.setAnimation(currentAnimation)
	
func editTrack():
	pass
	
func removeTrack():
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
