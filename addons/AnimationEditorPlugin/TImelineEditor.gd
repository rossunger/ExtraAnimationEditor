tool
extends Control

#onready var timeValueLabel = $HBoxContainer/TimeValue
#onready var ValueValueLabel = $HBoxContainer/ValueValue

signal zoomChanged
signal animationChanged

var grid = true		
var snap = 0.25
var zoom = Vector2(100,1)
var scroll = Vector2(0,0)
var offset = Vector2(-12,-12)
var showTimeline = true
var timeline = null
var trackContainer = null
var animation

#STATUS BAR
onready var KeyframeData = $VBoxContainer/StatusBarBackground/KeyframeData
onready var keyframeTime = $VBoxContainer/StatusBarBackground/KeyframeData/KeyframeTime
onready var keyframeValue = $VBoxContainer/StatusBarBackground/KeyframeData/KeyframeValue
onready var keyframeRelative = $VBoxContainer/StatusBarBackground/KeyframeData/KeyframeRelative

onready var animationSpeed = $VBoxContainer/StatusBarBackground/AnimationSettings/Control/AnimationSpeed
onready var loopButton = $VBoxContainer/StatusBarBackground/AnimationSettings/LoopButton
onready var autoPlayButton = $VBoxContainer/StatusBarBackground/AnimationSettings/AutoPlayButton
onready var previewContextLabel = $VBoxContainer/StatusBarBackground/AnimationSettings/previewContextLabel

#EDITING VARS
var clipboard = [] #for copy and paste
var focusedTrack #for copy paste and drag-duplicate 
var lastKeyCommandTime = 0
var clickedKey = null
var draggingKeys = false
var scrolling =false
var undos = []
var redos = []
var groupTrack = false

enum undoTypes{ 	create, delete, keyframe, track, animation 		}

#func debugGuiFocus(who):
	#print(who.name, " : ", who.get_path())
	
func _enter_tree():	
	#if not get_viewport().is_connected("gui_focus_changed", self, "debugGuiFocus"):
	#	get_viewport().connect("gui_focus_changed", self, "debugGuiFocus")
	set_focus_mode(Control.FOCUS_ALL)
	if !Engine.editor_hint:
		queue_free()	
	get_tree().call_group("AnimationEditorPlugin", "initTimeline", self)	
	
func handleSelection(obj):	
	if obj.get_script() and obj.get_script().get_path().find("ExtraAnimation.gd") != -1:	
		return true	
	
func newAnimation(editedSceneRoot):
	var newAnimation = preload("res://addons/AnimationEditorPlugin/AnimationTemplate.tscn").instance()			
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
	editedSceneRoot.add_child(newAnimation)		
	newAnimation.owner = editedSceneRoot
	
func setAnimation(obj= animation):
	scroll = Vector2(0,0)
	if !obj:
		return
	if is_instance_valid(animation):
		if obj.name==animation.name:
			return
	clearAnimation()	
	animation = load(obj.filename).instance()
	animation.filename = obj.filename
	$VBoxContainer.add_child(animation)	
	trackContainer = get_node("VBoxContainer/" + animation.name + "/TrackMeta")		
	timeline = get_node("VBoxContainer/" + animation.name + "/Timeline")		
	if not animation.is_connected("frameChanged", self, "frameChanged"):
		animation.connect("frameChanged", self, "frameChanged")
	
	animationSpeed.text = str(animation.speed)
	loopButton.pressed = animation.looping
	autoPlayButton.pressed = animation.autoPlay
	previewContextLabel.text = animation.defaultPreviewScene
	animation.show()
	emit_signal("animationChanged")	
		
func clearAnimation():			
	if is_instance_valid(animation):
		animation.queue_free()			
	if is_instance_valid(previewContextLabel):
		previewContextLabel.text = ""
		
	KeyframeData.hide()



		
func _on_toggleTimelineButton_pressed():
	showTimeline = !showTimeline
	if showTimeline:		
		if is_instance_valid(animation):
			animation.show()
		rect_min_size.y = 250
	else:
		if is_instance_valid(animation):
			animation.hide()		
		rect_min_size.y = 45
		rect_size.y = 0

func _on_ChangeContextButton_pressed():
	get_tree().call_group("AnimationEditorPlugin", "changeContext")			


func _on_SaveButton_pressed():
	if !animation:
		return	
	get_tree().call_group("AnimationEditorPlugin", "saveChanges", animation)			


func _on_NewAnimationButton_pressed():
	get_tree().call_group("AnimationEditorPlugin", "newAnimation")

func _on_PlayButton_pressed():
	animation.togglePlay()	
	
func _on_ZoomInButton_pressed():
	setZoom(zoom.x * 1.05)		

func _on_ZoomOutButton_pressed():
	setZoom(zoom.x / 1.05)
	
func setZoom(value):
	zoom.x = max(2, min(200, value))
	$VBoxContainer/StatusBarBackground/ZoomControls/ZoomLabel.text = str(floor(zoom.x)) + "%"
	emit_signal("zoomChanged")	
	
func frameChanged():	
	$VBoxContainer/StatusBarBackground/AnimationSettings/TimeValue.text = str(stepify(animation.position, 0.1))
	
func keyframeChanged(who):	
	who.get_parent().validateKeyframeOrder()	
	animation.setDurationToLatestKeyframe()
	keyframeTime.text = str(who.time)
	keyframeValue.setValue(who)
	keyframeRelative.pressed = who.relative

func _on_SpinBox_value_changed(value):
	animation.speed = value

func selectionChanged(who):	
	if who and who.get_script() and who.get_script().get_path().find("keyframe.gd") != -1:
		KeyframeData.show()
		keyframeValue.setValue(who)
		keyframeTime.text = str( who.time )
		keyframeRelative.pressed = who.relative
	else:
		#print(who.get_script().get_path())
		KeyframeData.hide()

func previewContextChanged(path):
	animation.defaultPreviewScene = path	
	previewContextLabel.text = path

func _on_KeyframeValue_gui_input(event):
	if not is_instance_valid(animation) or not get_tree().get_nodes_in_group("selected").size()>0:
		return
	if event is InputEventMouseButton and event.is_pressed():
		keyframeValue.showSelector()

func _on_KeyframeTime_text_entered(new_text):		
	var regex = RegEx.new()
	regex.compile("[0-9]*\\.?[0-9]+")
	var result = regex.search(new_text)
	if result:					
		var sel = get_tree().get_nodes_in_group("selected")
		if sel.size() == 0:			
			return		
		var val = float(result.get_string())	
		var delta = val - sel.back().time 		
		if new_text.find("+") != -1:
			delta = val
		elif new_text.find("-") != -1:
			delta = -val		
		for key in sel:			
			if new_text.find("x") != -1:
				key.time *= val
			elif new_text.find("/") != -1:
				key.time /= val
			else:		
				key.time += delta				
		keyframeTime.text = str(sel.back().time)
	grab_focus()


func _on_AnimationSpeed_text_entered(new_text):
	if float(new_text):
		animation.speed = float(new_text)


func _on_KeyframeTime_focus_entered():
	if get_tree().get_nodes_in_group("selected").size() == 0:
		release_focus()


func _on_ValueLabel_pressed():
	keyframeValue.showSelector()


func _on_LoopButton_pressed():
	animation.looping = loopButton.pressed
	grab_focus()

#func _input(event):
#	inputManager.handleInput(event, self)
	
func _gui_input(event):
	if event is InputEventMouse and event.is_pressed():
		grab_focus()		

func _on_KeyframeRelative_toggled(button_pressed):
	for key in get_tree().get_nodes_in_group("selected"):
		key.relative = button_pressed

func _on_AutoPlayButton_pressed():
	animation.autoPlay = autoPlayButton.pressed
	grab_focus()

func _on_ZoomLabel_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		setZoom(100)
		scroll.x = 0 
#TO DO: fix undo system... deleting and creating especially...
#works to undo, but redo does something weird
func addUndo(type, who, undo=true, clearRedos=true):	
	if not is_instance_valid(who):
		return
	var data = {}
	if type == undoTypes.animation:
		data.looping = animation.looping
		data.autoPlay = animation.autoPlay
		data.speed = animation.speed
		data.defaultPreviewScene = animation.defaultPreviewScene
		
	elif type == undoTypes.track:		
		data.name = who.name
		data.index = who.get_index()
		data.type = who.type
		data.object = who.object
		data.property = who.property
		
	elif type == undoTypes.keyframe:				
		data.time = who.time
		data.value = who.value
		data.relative = who.relative
		data.curve = who.curve
		data.parent = who.get_parent()
		data.index = who.get_index()		
		data.selected = who.selected
	elif type == undoTypes.create:
		data.parent = who.get_parent()		
		data.who = who
		if who.get_script().get_path().find("TrackMeta.gd") != -1:
			data.who2 = who.owner.get_node(who.track)		
			
	elif type == undoTypes.delete:
		data.parent = who.get_parent()
		#print("Duplicating who: ", who.name)
		data.who = who.duplicate(DUPLICATE_GROUPS + DUPLICATE_SIGNALS + DUPLICATE_SCRIPTS )						
		if who.get_script().get_path().find("TrackMeta.gd") != -1:
			data.who2 = who.owner.get_node(who.track).duplicate(DUPLICATE_GROUPS + DUPLICATE_SIGNALS + DUPLICATE_SCRIPTS )
	if undo:	
		if clearRedos:
			redos.clear()				
		undos.push_back({
			time = OS.get_system_time_msecs(),
			who = who,
			type = type,	
			data = data
		})
	else:				
		redos.push_back({			
			time = OS.get_system_time_msecs(),
			who = who,
			type = type,	
			data = data
		})
	
func doUndo(doUndo = true):	
	var undoRedo
	if doUndo:
		undoRedo = undos
	else:		
		undoRedo = redos
	
	if undoRedo.size() == 0:
		return	
	#print("redos left: ", redos.size())	
	var first = undoRedo.back().time
	while undoRedo.size() > 0 and abs(undoRedo.back().time - first) < 100:			
		var undo = undoRedo.pop_back()				
		var data = undo.data		
		#Add to redo
		if undo.type == undoTypes.create:						
			#print("undoing create") if doUndo else print("redoing delete")
			addUndo(undoTypes.delete, undo.data.who, !doUndo, false)									
			if undo.data.who.get_script().get_path().find("TrackMeta.gd") != -1:
				undo.data.who2.queue_free()
			undo.data.who.queue_free()			
		elif undo.type == undoTypes.delete:					
			#print("undoing delete") if doUndo else print("redoing create")
			addUndo(undoTypes.create, undo.who, !doUndo, false)						
			undo.data.parent.add_child(undo.data.who)
			undo.data.who.owner = animation
			if undo.data.who.get_script().get_path().find("TrackMeta.gd") != -1:
				animation.timeline.add_child(undo.data.who2)
				undo.data.who2.owner = animation
		else:
			if not is_instance_valid(undo.who):				
				continue
			addUndo(undo.type, undo.who, !doUndo)						
			if undo.type == undoTypes.animation:
				animation.looping = data.looping
				animation.autoPlay = data.autoPlay
				animation.speed = data.speed
				animation.defaultPreviewScene = data.defaultPreviewScene
						
			elif undo.type == undoTypes.track:
				var who = undo.who
				who.name = data.name			
				#TODO: allow reordering tracks
				#elif data.index != who.get_index():
				#	who.get_parent().move_child().data.index = data.get_index()
				who.type = data.type
				who.object = data.object
				who.property = data.property
				
			elif undo.type == undoTypes.keyframe:			
				var who = undo.who
				var parent = data.parent			
				who.value = data.value
				who.relative = data.relative
				who.curve = data.curve					
				who.time = data.time
				if who.selected:
					if not data.selected:
						who.deselect()
				else:
					if data.selected:
						who.doSelect()
				
				if who.get_parent() != parent:
					who.reparent(parent)

func _on_groupTracksButton_pressed():
	groupTrack = true

func _on_TimelineEditor_visibility_changed():
	if visible:
		grab_focus()

func doZoomY(out = false):
	if out:
		zoom.y *= 1.01
	else:
		zoom.y /= 1.01
	get_tree().call_group("Tracks", "updateZoomY")

func doScrollY(down = true):
	if down:
		scroll.y += 20
	else:
		scroll.y -= 20
	scroll.y = max(0, scroll.y)	
	#animation.trackMeta.rect_position.y = -scroll.y
	#animation.timeline.rect_position.y = -scroll.y	
