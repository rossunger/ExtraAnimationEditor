tool
extends Control

#onready var timeValueLabel = $HBoxContainer/TimeValue
#onready var ValueValueLabel = $HBoxContainer/ValueValue

signal zoomChanged
signal animationChanged

var grid = true		
var snap = 0
var zoom = Vector2(100,1)
var scroll = Vector2(0,0)
var offset = Vector2(-12,-12)
var showTimeline = true
var timeline = null
var trackContainer = null
var animation

#STATUS BAR
onready var keyframeTime = $VBoxContainer/StatusBarBackground/KeyframeData/KeyframeTime
onready var animationSpeed = $VBoxContainer/StatusBarBackground/AnimationSettings/Control/AnimationSpeed
onready var loopButton = $VBoxContainer/StatusBarBackground/AnimationSettings/LoopButton
onready var keyframeValue = $VBoxContainer/StatusBarBackground/KeyframeData/KeyframeValue
onready var keyframeRelative = $VBoxContainer/StatusBarBackground/KeyframeData/KeyframeRelative
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
	emit_signal("animationChanged")
		
func clearAnimation():			
	if is_instance_valid(animation):
		animation.queue_free()			



		
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
	zoom.x *= 1.05
	$VBoxContainer/StatusBarBackground/ZoomControls/ZoomLabel.text = str(floor(zoom.x)) + "%"
	emit_signal("zoomChanged")

func _on_ZoomOutButton_pressed():
	zoom.x /= 1.05
	$VBoxContainer/StatusBarBackground/ZoomControls/ZoomLabel.text = str(floor(zoom.x)) + "%"
	emit_signal("zoomChanged")	
	
func frameChanged():	
	$VBoxContainer/StatusBarBackground/AnimationSettings/TimeValue.text = str(stepify(animation.position, 0.1))
	
func keyframeChanged(who):
	who.get_parent().reorderKeyByTime(who)	
	animation.setDurationToLatestKeyframe()
	keyframeTime.text = str(who.time)
	keyframeValue.setValue(who)
	keyframeRelative.pressed = who.relative

func _on_SpinBox_value_changed(value):
	animation.speed = value

func selectionChanged(who):	
	if who and who.get_script() and who.get_script().get_path().find("keyframe.gd") != -1:
		$VBoxContainer/StatusBarBackground/KeyframeData.show()
		keyframeValue.setValue(who)
		keyframeTime.text = str( who.time )
		keyframeRelative.pressed = who.relative
	else:
		#print(who.get_script().get_path())
		$VBoxContainer/StatusBarBackground/KeyframeData.hide()

func previewContextChanged(path):
	animation.defaultPreviewScene = path	
	$VBoxContainer/StatusBarBackground/AnimationSettings/previewContextLabel.text = path





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

func _input(event):
	if Input.is_key_pressed(KEY_SPACE):
		if has_focus():
			animation.togglePlay()
		
func _gui_input(event):
	if event is InputEventMouse and event.is_pressed():
		grab_focus()		



func _on_KeyframeRelative_toggled(button_pressed):
	for key in get_tree().get_nodes_in_group("selected"):
		key.relative = button_pressed

